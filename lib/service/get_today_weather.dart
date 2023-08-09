import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app_v2_proj/model/daily_weather.model.dart';

Future<DailyWeather> fetchTodayWeatherData(String? lat, String? long) async {
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String url =
      'https://api.open-meteo.com/v1/dwd-icon?latitude=$lat&longitude=$long&hourly=temperature_2m,weathercode,windspeed_10m&timezone=America%2FSao_Paulo&start_date=$date&end_date=$date';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body)['hourly'] as dynamic;
    return DailyWeather.fromJson(jsonData);
  } else {
    debugPrint('Request failed with status: ${response.statusCode}');
    return DailyWeather();
  }
}
