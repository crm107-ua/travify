import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:travify/notifiers/trip_notifier.dart';
import 'screens/main_screen.dart';
import 'screens/pin_login_screen.dart';
import 'services/settings_service.dart';
import 'database/helpers/database_helper.dart';
import 'package:travify/services/official_rates_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TripNotifier()),
        ],
        child: MaterialApp(
          title: 'travify',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(
              headlineMedium: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              bodyMedium: TextStyle(color: Colors.black, fontSize: 17),
              titleLarge: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[900],
            textTheme: TextTheme(
              headlineMedium: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              bodyMedium: TextStyle(color: Colors.white, fontSize: 17),
              titleLarge: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
          ),
          themeMode: ThemeMode.dark,
          home: FutureBuilder<String?>(
            future: SettingsService.getPin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                return PinLoginScreen();
              } else {
                return MainScreen();
              }
            },
          ),
        ));
  }
}
