import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_v2_proj/model/weather_model.dart';

Future<Weather> fetchCurrentWeatherData(String? lat, String? long) async {
  String url =
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current_weather=true';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return Weather.fromJson(jsonData['current_weather']);
  } else {
    debugPrint('Request failed with status: ${response.statusCode}');
    return Weather();
  }
}
