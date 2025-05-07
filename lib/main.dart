import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'notifiers/trip_notifier.dart';
import 'screens/main_screen.dart';
import 'screens/pin_login_screen.dart';
import 'services/settings_service.dart';
import 'database/helpers/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // English
        Locale('fr'), // Français
        Locale('de'), // Deutsch
        Locale('it'), // Italiano
        Locale('pt'), // Português
        Locale('zh'), // 中文
        Locale('ja'), // 日本語
        Locale('ru'), // Русский
        Locale('ar'), // العربية
      ],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripNotifier()),
      ],
      child: MaterialApp(
        title: 'travify',
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.black, fontSize: 17),
            titleLarge: TextStyle(
                color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey,
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.white, fontSize: 17),
            titleLarge: TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
