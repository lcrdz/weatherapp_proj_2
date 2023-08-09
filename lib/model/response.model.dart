import 'package:weather_app_v2_proj/model/location_model.dart';

class LocationResponse {
  bool hasError;
  List<Location> locations;

  LocationResponse({
    this.hasError = false,
    this.locations = const [],
  });
}
