import 'package:flutter/foundation.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/services/trip_service.dart';

class TripNotifier extends ChangeNotifier {
  final TripService _tripService = TripService();

  Trip? _currentTrip;
  List<Trip> _upcomingTrips = [];
  List<Trip> _allTrips = [];

  Trip? get currentTrip => _currentTrip;
  List<Trip> get upcomingTrips => _upcomingTrips;
  List<Trip> get allTrips => _allTrips;

  Future<void> loadCurrentTripAndUpcoming() async {
    _currentTrip = await _tripService.getCurrentTripOrNextTrip();
    _upcomingTrips = await _tripService.getUpcomingTrips();
    _allTrips = await _tripService.getAllTrips();
    notifyListeners();
  }

  Future<void> _refreshAll() async {
    await loadCurrentTripAndUpcoming();
  }

  Future<void> addTrip(Trip trip) async {
    await _tripService.createTrip(trip);
    await _refreshAll();
  }

  Future<void> updateTrip(Trip trip) async {
    await _tripService.updateTrip(trip);
    await _refreshAll();
  }

  Future<void> deleteTrip(int id) async {
    await _tripService.deleteTrip(id);
    await _refreshAll();
  }

  Future<bool> tripExistsWithDate(DateTime startDate,
      {int? excludeTripId}) async {
    return _tripService.checkTripExistWithDate(startDate,
        excludeTripId: excludeTripId);
  }

  Future<bool> tripExistsWithDateNotNull(DateTime startDate,
      {int? excludeTripId}) async {
    return _tripService.tripExistsWithDateNotNull(startDate,
        excludeTripId: excludeTripId);
  }

  Future<bool> tripExists(DateTime startDate, DateTime endDate,
      {int? excludeTripId}) async {
    return _tripService.checkTripExists(startDate, endDate,
        excludeTripId: excludeTripId);
  }

  Trip getRefreshedTrip(Trip updatedTrip) {
    return _allTrips.firstWhere(
      (t) => t.id == updatedTrip.id,
      orElse: () => updatedTrip,
    );
  }
}
