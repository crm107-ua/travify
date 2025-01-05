import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/pin_login_screen.dart';
import 'services/settings_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App con PIN opcional y barra persistente',
      debugShowCheckedModeBanner: false,

      // -------------------------
      // 1. Definimos el Tema Claro
      // -------------------------
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          // Ejemplo: bodyMedium, titleLarge, etc.
          // Ajusta las propiedades (color, fontSize, etc.) a tu gusto
          headlineMedium: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 17),
          titleLarge: TextStyle(
              color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),

      // -------------------------
      // 2. Definimos el Tema Oscuro
      // -------------------------
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          headlineMedium: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 17),
          titleLarge: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),

      // -------------------------
      // 3. Cómo decides el tema
      // -------------------------
      // - ThemeMode.system: sigue la configuración del dispositivo
      // - ThemeMode.light: fuerza el tema claro
      // - ThemeMode.dark: fuerza el tema oscuro
      themeMode: ThemeMode.dark,

      // -------------------------
      // 4. Lógica de PIN opcional
      // -------------------------
      home: FutureBuilder<String?>(
        future: SettingsService.getPin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Si existe PIN, primero validarlo
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return PinLoginScreen();
          } else {
            // Si no hay PIN, directamente a la MainScreen
            return MainScreen();
          }
        },
      ),
    );
  }
}
