import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5/group?id=5128581,2643743,2950159&units=metric&appid=4f45361596deace30adda7f5c31a813a';

  Future<List<dynamic>> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list']; // Ambil daftar kota dari response
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }
}