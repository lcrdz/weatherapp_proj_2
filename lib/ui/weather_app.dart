import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app_v2_proj/extensions.dart';
import 'package:weather_app_v2_proj/model/daily_weather.model.dart';
import 'package:weather_app_v2_proj/model/location_model.dart';
import 'package:weather_app_v2_proj/model/response.model.dart';
import 'package:weather_app_v2_proj/model/weather_model.dart';
import 'package:weather_app_v2_proj/model/weekly_weather.model.dart';
import 'package:weather_app_v2_proj/service/get_location.dart';
import 'package:weather_app_v2_proj/service/get_current_weather.dart';
import 'package:weather_app_v2_proj/service/get_today_weather.dart';
import 'package:weather_app_v2_proj/service/get_weekly_weather.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<StatefulWidget> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String _geolocationIsUnavailable = "";
  String _apiError = "";
  List<String> errorMessages = [];
  bool _locationIsEmpty = false;
  List<Location> _locations = List.empty();
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Location _location = Location();
  Weather _weather = Weather();
  DailyWeather _dailyWeather = DailyWeather();
  WeeklyWeather _weeklyWeather = WeeklyWeather();

  void selectLocation(Location location) {
    setState(() {
      _geolocationIsUnavailable = "";
      updatEerrorMessages();
      _location = location;
      _searchController.clear();
      _isSearching = false;
    });
    fetchCurrentlyWeather();
    fetchTodayWeather();
    fetchWeeklyWeather();
  }

  void _onSearchTextChanged() async {
    String searchText = _searchController.text;
    LocationResponse fetchedWeatherList = await fetchLocationData(searchText);
    setState(() {
      if (fetchedWeatherList.hasError) {
        _apiError =
            "The service connection is lost, please check your internet connnection or try again later.";
        updatEerrorMessages();
      } else {
        _apiError = "";
        updatEerrorMessages();
        if (_searchController.text.isEmpty) {
          _isSearching = false;
        } else {
          _isSearching = true;
          _locations = fetchedWeatherList.locations;
        }
        _locationIsEmpty = _locations.isEmpty;
        updatEerrorMessages();
      }
    });
  }

  void fetchCurrentlyWeather() async {
    Weather currentlyWeather = await fetchCurrentWeatherData(
      _location.latitude.toString().orEmpty(),
      _location.longitude.toString().orEmpty(),
    );
    setState(() {
      _weather = currentlyWeather;
    });
  }

  void fetchTodayWeather() async {
    DailyWeather dailyWeather = await fetchTodayWeatherData(
      _location.latitude.toString().orEmpty(),
      _location.longitude.toString().orEmpty(),
    );
    setState(() {
      _dailyWeather = dailyWeather;
    });
  }

  void fetchWeeklyWeather() async {
    WeeklyWeather weeklyWeather = await fetchWeeklyWeatherData(
      _location.latitude.toString().orEmpty(),
      _location.longitude.toString().orEmpty(),
    );
    setState(() {
      _weeklyWeather = weeklyWeather;
    });
  }

  void checkPermission() async {
    if (_permissionStatus.isGranted) {
      getLocation();
    } else if (_permissionStatus.isPermanentlyDenied) {
      setState(() {
        _geolocationIsUnavailable =
            "geolocation is unavailable, please enable in your app settings.";
        updatEerrorMessages();
      });
    } else {
      requestLocationPermission();
    }
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      selectLocation(Location(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    });
  }

  @override
  void initState() {
    checkPermission();
    _searchController.addListener(_onSearchTextChanged);
    super.initState();
  }

  void updatEerrorMessages() {
    errorMessages = [
      if (_geolocationIsUnavailable != "") _geolocationIsUnavailable,
      if (_apiError != "") _apiError,
      if (_locationIsEmpty)
        "Could not find any result for the supplied address or coordinates."
    ];
  }

  @override
  Widget build(BuildContext context) {
    var currentlyScreen = tabScreen([
      ...errorMessages,
      _location.name,
      _location.region,
      _location.country,
      _weather.temperature.toTemperatureFormat(),
      _weather.weathercode.currentWeather(),
      _weather.windSpeed.toWindSpeedFormat(),
    ]);

    var todayScreen = tabScreen([
      ...errorMessages,
      _location.name,
      _location.region,
      _location.country,
    ],
        extraWidget: dataColumn(combineList([
          _dailyWeather.time.map((e) => DateFormat('HH:mm').format(e)).toList(),
          _dailyWeather.temperature
              .map((e) => e.toTemperatureFormat())
              .toList(),
          _dailyWeather.weathercode.map((e) => e.currentWeather()).toList(),
          _dailyWeather.windspeed.map((e) => e.toWindSpeedFormat()).toList()
        ])));

    var weeklyScreen = tabScreen([
      ...errorMessages,
      _location.name,
      _location.region,
      _location.country,
    ],
        extraWidget: dataColumn(combineList([
          _weeklyWeather.time
              .map((e) => DateFormat('dd/MM/yyyy').format(e))
              .toList(),
          _weeklyWeather.minTemperature
              .map((e) => e.toTemperatureFormat())
              .toList(),
          _weeklyWeather.maxTemperature
              .map((e) => e.toTemperatureFormat())
              .toList(),
          _weeklyWeather.weatherCode.map((e) => e.currentWeather()).toList(),
        ])));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => selectLocation(_locations.first)),
          title: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'search location...',
                border: InputBorder.none,
              ),
              onSubmitted: (value) => selectLocation(_locations.first)),
          actions: [
            IconButton(
              icon: const Icon(Icons.location_pin),
              tooltip: 'geolocalização',
              onPressed: () => checkPermission(),
            )
          ],
        ),
        body: _isSearching
            ? ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      title: Text(_locations[index].toString()),
                      onTap: () => selectLocation(_locations[index]));
                },
              )
            : TabBarView(
                children: [currentlyScreen, todayScreen, weeklyScreen],
              ),
        bottomNavigationBar: const BottomAppBar(
          child: TabBar(
            tabs: [
              Tab(
                text: 'Currently',
                icon: Icon(Icons.sunny),
              ),
              Tab(
                text: 'Today',
                icon: Icon(Icons.today),
              ),
              Tab(
                text: 'Weekly',
                icon: Icon(Icons.calendar_month),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget tabScreen(List<String> texts, {Widget? extraWidget}) {
  texts.removeWhere((element) => element.trim().isEmpty);
  return Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...texts.map(
            (text) => Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Text(text),
            ),
          ),
          if (extraWidget != null) extraWidget
        ],
      ),
    ),
  );
}

Widget dataRow(List<dynamic> list) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list
          .map((e) => Text(
                e.toString(),
                textAlign: TextAlign.center,
              ))
          .toList(),
    ),
  );
}

Widget dataColumn(List<List<dynamic>> list) {
  return Column(
    children: list.map((e) => dataRow(e)).toList(),
  );
}

List<List<dynamic>> combineList(List<List<dynamic>> lists) {
  if (lists.isEmpty) {
    return [];
  }

  int length = lists[0].length;
  List<List<dynamic>> combinedList = [];

  for (int i = 0; i < length; i++) {
    List<dynamic> combinedElement = [];
    for (var list in lists) {
      combinedElement.add(list[i]);
    }
    combinedList.add(combinedElement);
  }

  return combinedList;
}
