import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_v2_proj/extensions.dart';
import 'package:weather_app_v2_proj/model/weekly_weather.model.dart';

Future<WeeklyWeather> fetchWeeklyWeatherData(String? lat, String? long) async {
  DateTime now = DateTime.now();
  String start = now.format();
  String end = now.add(const Duration(days: 7)).format();

  String url =
      'https://api.open-meteo.com/v1/gem?latitude=$lat&longitude=$long&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=America%2FSao_Paulo&start_date=$start&end_date=$end';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body)['daily'] as dynamic;
    return WeeklyWeather.fromJson(jsonData);
  } else {
    debugPrint('Request failed with status: ${response.statusCode}');
    return WeeklyWeather();
  }
}
