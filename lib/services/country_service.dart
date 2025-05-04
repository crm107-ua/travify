import 'package:travify/models/country.dart';
import 'package:travify/database/dao/country_dao.dart';

/// Servicio para operaciones relacionadas con Countries.
/// Internamente usa el CountryDao para interactuar con la base de datos.
class CountryService {
  final CountryDao _countryDao = CountryDao();

  /// Crea o inserta un nuevo [Country] en la BD.
  /// Retorna el ID generado (o 0 si falló).
  Future<int> createCountry(Country country) async {
    // Aquí podrías añadir validaciones o lógica de negocio antes de insertar.
    return await _countryDao.insertCountry(country);
  }

  /// Obtiene un [Country] por su ID.
  /// Retorna una lista con un solo elemento (o vacía si no existe).
  Future<List<Country>> getCountryById(int id) async {
    return await _countryDao.getCountryById(id);
  }

  /// Obtiene todos los países ordenados por ID (DESC).
  Future<List<Country>> getAllCountries() async {
    return await _countryDao.getCountries();
  }

  /// Actualiza un [Country] existente.
  /// Retorna el número de filas afectadas (1 si éxito, 0 si no existe).
  Future<int> updateCountry(Country country) async {
    // Puedes agregar validaciones, por ejemplo comprobar si el país existe.
    return await _countryDao.updateCountry(country);
  }

  /// Elimina un [Country] por su ID.
  /// Retorna el número de filas afectadas (1 si éxito, 0 si no existe).
  Future<int> deleteCountry(int id) async {
    // Podrías verificar dependencias, por ejemplo si hay trips asociados.
    return await _countryDao.deleteCountry(id);
  }

  /// Obtiene una lista de idiomas soportados.
  static List<Map<String, String>> getLanguages() {
    return [
      {'code': 'es', 'label': 'Español', 'flag': '🇪🇸'},
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
      {'code': 'de', 'label': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'it', 'label': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'pt', 'label': 'Português', 'flag': '🇵🇹'},
      {'code': 'zh', 'label': '中文', 'flag': '🇨🇳'},
      {'code': 'ja', 'label': '日本語', 'flag': '🇯🇵'},
      {'code': 'ru', 'label': 'Русский', 'flag': '🇷🇺'},
      {'code': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
    ];
  }
}
