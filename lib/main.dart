import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // โหลด dotenv ก่อน
  await dotenv.load(fileName: ".env");
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: CityListPage(),
    );
  }
}

class CityListPage extends StatelessWidget {
  final List<String> cities = ['Bangkok', 'New York', 'Tokyo', 'London'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cities[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherDetailPage(city: cities[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WeatherDetailPage extends StatefulWidget {
  final String city;

  const WeatherDetailPage({Key? key, required this.city}) : super(key: key);

  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  late Future<Map<String, dynamic>> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = fetchWeather(widget.city);
  }

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    String apiKey = dotenv.env['API_KEY'] ?? ''; // โหลด API Key จาก .env
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // ฟังก์ชันสำหรับเลือกภาพตามสภาพอากาศ
  String getWeatherIcon(String weatherCondition) {
    if (weatherCondition == 'Rain') {
      return 'assets/rain.png';
    } else if (weatherCondition == 'Clouds') {
      return 'assets/cloudy.png';
    } else if (weatherCondition == 'Clear') {
      return 'assets/sunny.png';
    }
    return 'assets/unknown.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var weather = snapshot.data!;
            var main = weather['main'];
            var sys = weather['sys'];
            var clouds = weather['clouds'];
            var weatherCondition = weather['weather'][0]['main'];
            var rain = weather['rain'] != null ? weather['rain']['1h'] : '0';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150, // กำหนดขนาดความกว้างของรูป
                    height: 150, // กำหนดขนาดความสูงของรูป
                    child: Image.asset(
                      getWeatherIcon(weatherCondition),
                      fit: BoxFit.cover, // จัดการให้รูปพอดีในขนาดที่กำหนด
                    ),
                  ),
                  const SizedBox(
                      height: 16), // เพิ่มพื้นที่ระหว่างภาพกับข้อความ
                  Text('City: ${weather['name']}',
                      style: const TextStyle(fontSize: 24)),
                  Text('Temperature: ${main['temp']}°C'),
                  Text('Min Temp: ${main['temp_min']}°C'),
                  Text('Max Temp: ${main['temp_max']}°C'),
                  Text('Pressure: ${main['pressure']} hPa'),
                  Text('Humidity: ${main['humidity']}%'),
                  Text('Sea Level: ${main['sea_level'] ?? 'N/A'} m'),
                  Text('Clouds: ${clouds['all']}%'),
                  Text('Rain (last hour): $rain mm'),
                  Text(
                      'Sunset: ${DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000)}'),
                ],
              ),
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}
