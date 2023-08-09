import 'package:weather_app_v2_proj/extensions.dart';

class DailyWeather {
  List<DateTime> time;
  List<double> temperature;
  List<int> weathercode;
  List<double> windspeed;

  DailyWeather({
    this.time = const [],
    this.temperature = const [],
    this.weathercode = const [],
    this.windspeed = const [],
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      temperature: (json['temperature_2m'] as List<dynamic>).toDouble(),
      time: (json['time'] as List<dynamic>).toDateTime(),
      weathercode: (json['weathercode'] as List<dynamic>).toInt(),
      windspeed: (json['windspeed_10m'] as List<dynamic>).toDouble(),
    );
  }
}
