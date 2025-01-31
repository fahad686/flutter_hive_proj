import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

const String apiKey = "c5f45987c9af92c50048ac77e4733f60"; // Replace with your API Key

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "Loading...";
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    try {
      Position position = await _determinePosition();
      String url =
          "https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey";

      Response response = await Dio().get(url);
      print("API Response: ${response.data}");  // Debugging Line

      weatherData = response.data;
      city = weatherData!['city']['name'];

      var box = Hive.box('weatherBox');
      await box.put('weatherData', weatherData);
    } catch (e) {
      print("API Error: $e");  // Debugging Line

      var box = Hive.box('weatherBox');
      weatherData = box.get('weatherData');

      if (weatherData != null) {
        city = weatherData!['city']['name'];
      } else {
        city = "No Data";
      }
    }


    setState(() {
      isLoading = false;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather App")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : weatherData == null
          ? Center(child: Text("No Weather Data Available"))
          : Column(
        children: [
          Text(city, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Today's Temperature: ${weatherData!['list'][0]['main']['temp']}°C"),
          SizedBox(height: 10),
          Text("Tomorrow's Temperature: ${weatherData!['list'][8]['main']['temp']}°C"),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: weatherData?.length,
              itemBuilder: (context, index) {
                int dataIndex = index * 8;
                String day = DateFormat('EEEE').format(
                  DateTime.parse(weatherData?['list'][dataIndex]['dt_txt']),
                );

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white.withOpacity(0.8),
                  child: ListTile(
                    leading: Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 32),
                    title: Text(day, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                    subtitle: Text("${weatherData?['list'][dataIndex]['main']['temp']}°C"),
                  ),
                );
              },
            ),
          ),

          // Expanded(
          //   child: ListView.builder(
          //     itemCount: weatherData?.length,
          //     itemBuilder: (context, index) {
          //       int dataIndex = index * 8; // Get every 24-hour interval
          //       return ListTile(
          //         title: Text("Day ${index + 1}"),
          //         subtitle: Text("${weatherData!['list'][dataIndex]['main']['temp']}°C"),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
