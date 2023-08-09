import 'package:weather_app_v2_proj/extensions.dart';

class Weather {
  double temperature;
  int weathercode;
  double windSpeed;

  Weather({
    this.temperature = invalidDouble,
    this.weathercode = invalidInt,
    this.windSpeed = invalidDouble,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['temperature'],
      weathercode: json['weathercode'],
      windSpeed: json['windspeed'],
    );
  }
}
