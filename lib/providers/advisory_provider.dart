// advisory_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _geminiKey = 'YOUR_GEMINI_API_KEY';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class WeatherData {
  final int temp;
  final int humidity;
  final int windSpeed;
  final String description;
  final String location;
  WeatherData({
    required this.temp,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.location,
  });
}

class AdvisoryProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  WeatherData? _weather;
  bool _isLoading = false;
  String _selectedCrop = 'Wheat';
  String _selectedSeason = 'Winter (Rabi)';

  List<ChatMessage> get messages => _messages;
  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String get selectedCrop => _selectedCrop;
  String get selectedSeason => _selectedSeason;

  void setCrop(String crop) { _selectedCrop = crop; notifyListeners(); }
  void setSeason(String season) { _selectedSeason = season; notifyListeners(); }

  Future<void> fetchWeather(String location) async {
    try {
      final geoRes = await http.get(Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$location&count=1'));
      if (geoRes.statusCode == 200) {
        final geoData = jsonDecode(geoRes.body);
        if (geoData['results'] != null && geoData['results'].isNotEmpty) {
          final lat = geoData['results'][0]['latitude'];
          final lon = geoData['results'][0]['longitude'];
          final res = await http.get(Uri.parse(
              'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'));
          if (res.statusCode == 200) {
            final d = jsonDecode(res.body)['current'];
            _weather = WeatherData(
              temp: (d['temperature_2m'] as num).round(),
              humidity: (d['relative_humidity_2m'] as num).round(),
              windSpeed: (d['wind_speed_10m'] as num).round(),
              description: 'Clear',
              location: location,
            );
            notifyListeners();
            return;
          }
        }
      }
    } catch (_) {}
    _weather = WeatherData(temp: 32, humidity: 65, windSpeed: 12,
        description: 'partly cloudy', location: location);
    notifyListeners();
  }

  Future<void> getInitialAdvice(String location) async {
    await fetchWeather(location);
    _messages = [];
    final prompt = '''
You are an expert agricultural advisor for Indian farmers.
Crop: $_selectedCrop | Season: $_selectedSeason | Location: $location
Weather: ${_weather?.temp}°C, Humidity: ${_weather?.humidity}%, Wind: ${_weather?.windSpeed} km/h

Give 3 short practical tips:
1. Fertilizer advice (NPK, quantity)
2. Irrigation schedule (based on weather)
3. Pest/disease risk alert (if any)
Keep each to 1-2 sentences. Use simple language.
''';
    await _sendToGemini(prompt, isInitial: true);
  }

  Future<void> sendMessage(String text) async {
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();
    final history = _messages
        .map((m) => '${m.isUser ? "Farmer" : "Advisor"}: ${m.text}')
        .join('\n');
    final prompt = '''
You are AgriConnect's AI farming advisor for Indian farmers.
Context - Crop: $_selectedCrop, Season: $_selectedSeason
Conversation so far:
$history

Answer the farmer's latest question in 2-3 simple sentences.
''';
    await _sendToGemini(prompt);
  }

  Future<void> _sendToGemini(String prompt, {bool isInitial = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'] as String;
        _messages.add(ChatMessage(text: reply.trim(), isUser: false));
      } else {
        _messages.add(ChatMessage(
            text: 'Could not fetch advice. Please check your internet connection.',
            isUser: false));
      }
    } catch (_) {
      _messages.add(ChatMessage(
          text: 'Something went wrong. Please try again.',
          isUser: false));
    }
    _isLoading = false;
    notifyListeners();
  }
}
