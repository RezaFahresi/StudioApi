import 'package:flutter/material.dart';
import 'weather_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService apiService = WeatherService();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Data'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by city name...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<dynamic> weatherData = snapshot.data!;

            // Filter berdasarkan pencarian
            if (_searchQuery.isNotEmpty) {
              weatherData = weatherData.where((item) {
                final cityName = item['name'].toString().toLowerCase();
                return cityName.contains(_searchQuery);
              }).toList();
            }

            // Urutkan berdasarkan nama kota
            weatherData.sort((a, b) => a['name'].compareTo(b['name']));

            // Hitung rata-rata suhu
            final double avgTemp = weatherData.isNotEmpty
                ? weatherData
                .map((item) => item['main']['temp'] as double)
                .reduce((a, b) => a + b) /
                weatherData.length
                : 0.0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Average Temperature: ${avgTemp.toStringAsFixed(1)} °C',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherData.length,
                    itemBuilder: (context, index) {
                      final item = weatherData[index];
                      final cityName = item['name'];
                      final weatherDesc = item['weather'][0]['description'];
                      final temperature = item['main']['temp'].toStringAsFixed(1);

                      return ListTile(
                        title: Text(cityName),
                        subtitle: Text(
                            'Weather: $weatherDesc\nTemp: $temperature °C'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
