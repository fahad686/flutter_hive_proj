import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_test_proj/weather_screen.dart';

import 'home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("shopping_box");
  await Hive.openBox('weatherBox'); // Open Hive box for storage
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Example',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.yellow))
        ),
        iconButtonTheme: IconButtonThemeData(style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.yellow))),
        appBarTheme: AppBarTheme(
          color: Colors.yellow,
        ),

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),

      home: WeatherScreen(),
    );
  }
}


