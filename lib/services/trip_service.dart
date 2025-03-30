import '../../models/trip.dart';
import 'package:travify/database/dao/trip_dao.dart';

class TripService {
  final TripDao _tripDao = TripDao();

  /// Crea un nuevo viaje en la base de datos.
  /// Retorna el ID del viaje insertado, o 0 si falla.
  Future<int> createTrip(Trip trip) async {
    // Aquí puedes realizar validaciones/lógica adicional antes de insertar.
    return await _tripDao.insertViaje(trip);
  }

  Future<List<Trip>> getUpcomingTrips() async {
    return await _tripDao.getUpcomingTrips();
  }

  /// Verifica si existe un viaje con las mismas fechas, excluyendo opcionalmente un viaje.
  Future<bool> checkTripExists(DateTime dateStart, DateTime dateEnd,
      {int? excludeTripId}) async {
    return await _tripDao.checkTripExists(dateStart, dateEnd,
        excludeTripId: excludeTripId);
  }

  /// Comprobar conflictos con fecha de inicio sin fecha de fin, excluyendo opcionalmente un viaje.
  Future<bool> checkTripExistWithDate(DateTime date,
      {int? excludeTripId}) async {
    return await _tripDao.checkTripExistWithDate(date,
        excludeTripId: excludeTripId);
  }

  /// Obtiene todos los viajes ordenados por ID descendente.
  Future<List<Trip>> getAllTrips() async {
    return await _tripDao.gettrips();
  }

  /// Obtiene un viaje por su ID.
  Future<Trip?> getTripById(int id) async {
    return await _tripDao.getTripById(id);
  }

  // Obtener trip actual o el siguiente trip
  Future<Trip?> getCurrentTripOrNextTrip() async {
    return await _tripDao.getCurrentTripOrNextTrip();
  }

  /// Actualiza un viaje existente.
  /// Retorna la cantidad de filas afectadas (1 si éxito, 0 si no existe).
  Future<int> updateTrip(Trip trip) async {
    // Puedes hacer validaciones aquí si lo necesitas.
    return await _tripDao.updateViaje(trip);
  }

  /// Elimina un viaje por su ID.
  /// Retorna el número de filas eliminadas (1 si éxito, 0 si no existe).
  Future<int> deleteTrip(int id) async {
    // También podrías verificar si existen transacciones relacionadas, etc.
    return await _tripDao.deleteViaje(id);
  }

  /// Cierra la conexión con la base de datos (si es necesario).
  Future<void> closeDatabase() async {
    await _tripDao.close();
  }
}
