import 'package:weather_app_v2_proj/extensions.dart';

class WeeklyWeather {
  final List<DateTime> time;
  final List<int> weatherCode;
  final List<double> maxTemperature;
  final List<double> minTemperature;

  WeeklyWeather({
    this.time = const [],
    this.weatherCode = const [],
    this.maxTemperature = const [],
    this.minTemperature = const [],
  });

  factory WeeklyWeather.fromJson(Map<String, dynamic> json) {
    return WeeklyWeather(
      time: (json['time'] as List<dynamic>).toDateTime(),
      weatherCode: (json['weathercode'] as List<dynamic>).toInt(),
      maxTemperature: (json['temperature_2m_max'] as List<dynamic>).toDouble(),
      minTemperature: (json['temperature_2m_min'] as List<dynamic>).toDouble(),
    );
  }
}
