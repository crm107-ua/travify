import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _pinKey = '';
  static const String _darkModeKey = '';

  /// Guarda el PIN en el dispositivo
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  /// Devuelve el PIN almacenado (o null si no existe)
  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  /// Elimina el PIN
  static Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  /// Activa o desactiva modo oscuro
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  /// Devuelve si está activo el modo oscuro
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
}
