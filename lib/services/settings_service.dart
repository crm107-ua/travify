import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _pinKey = 'user_pin';
  static const String _darkModeKey = 'dark_mode';
  static const String _defaultCurrencyKey = 'default_currency';

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

  /// Guarda la moneda por defecto (ej: 'EUR', 'USD')
  static Future<void> setDefaultCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCurrencyKey, code);
  }

  /// Devuelve la moneda por defecto (null si no hay)
  static Future<String?> getDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCurrencyKey);
  }

  /// Elimina la moneda por defecto
  static Future<void> clearDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_defaultCurrencyKey);
  }
}
