import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/notifiers/trip_notifier.dart';
import 'package:travify/screens/trip_screen.dart';

class SearchContent extends StatefulWidget {
  const SearchContent({super.key});

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Trip> _filteredTrips = [];

  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _onlyOpen;
  final List<String> _selectedCountries = [];

  Set<String> _allCountries = {};

  List<Trip> _getFilteredTrips(List<Trip> trips) {
    final searchLower = _searchQuery.toLowerCase();

    final filtered = trips.where((trip) {
      final matchesCountry = _selectedCountries.isEmpty ||
          trip.countries.any((c) => _selectedCountries.contains(c.name));
      final matchesTitle = trip.title.toLowerCase().contains(searchLower);
      final matchesDestination =
          trip.destination.toLowerCase().contains(searchLower);
      final matchesDate =
          (_startDate == null || !trip.dateStart.isBefore(_startDate!)) &&
              (_endDate == null ||
                  (trip.dateEnd ?? trip.dateStart)
                      .isBefore(_endDate!.add(const Duration(days: 1))));
      final matchesOpen = _onlyOpen == null || trip.open == _onlyOpen;

      return matchesCountry &&
          matchesDate &&
          matchesOpen &&
          (matchesTitle || matchesDestination);
    }).toList();

    filtered.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    return filtered;
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _resetDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<TripNotifier>(builder: (context, notifier, _) {
      final trips = notifier.allTrips;
      _allCountries =
          trips.expand((t) => t.countries.map((c) => c.name)).toSet();
      _filteredTrips = _getFilteredTrips(trips);
      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 76.0, left: 16.0),
              child: Text(
                "Historial",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por título o destino...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[850],
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 28),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _allCountries.map((country) {
                        final isSelected = _selectedCountries.contains(country);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(
                              country,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor:
                                const Color.fromARGB(255, 106, 145, 251),
                            backgroundColor: Colors.grey[850],
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCountries.add(country);
                                } else {
                                  _selectedCountries.remove(country);
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color.fromARGB(255, 254, 255, 255)
                                  : Colors.white24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _pickDate(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 52, 53, 53),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 0.5,
                              // Ancho del borde
                            ),
                          ),
                          child: Text(
                            _startDate == null
                                ? 'Fecha desde'
                                : DateFormat('dd/MM/yyyy').format(_startDate!),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _pickDate(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 52, 53, 53),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 0.5,
                              // Ancho del borde
                            ),
                          ),
                          child: Text(
                            _endDate == null
                                ? 'Fecha hasta'
                                : DateFormat('dd/MM/yyyy').format(_endDate!),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (_startDate != null || _endDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.redAccent),
                          onPressed: _resetDates,
                          tooltip: 'Borrar fechas',
                        ),
                      ],
                      const SizedBox(width: 30),
                      DropdownButton<bool?>(
                        value: _onlyOpen,
                        dropdownColor: Colors.grey[900],
                        underline: Container(), // Quitamos línea
                        hint: const Text('Estado',
                            style: TextStyle(color: Colors.white)),
                        onChanged: (value) {
                          setState(() => _onlyOpen = value);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Todos',
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Abiertos',
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Cerrados',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredTrips.isEmpty
                  ? const Center(
                      child: Text('No hay viajes encontrados',
                          style: TextStyle(color: Colors.white70)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = _filteredTrips[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white, // Color del borde
                              width: 1, // Grosor del borde
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Card(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(trip.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis),
                                  maxLines: 1),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Destino: ${trip.destination}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(trip.dateStart),
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14),
                                      ),
                                      if (trip.dateEnd != null) ...[
                                        const SizedBox(width: 3),
                                        const Icon(Icons.arrow_forward,
                                            size: 15, color: Colors.white70),
                                        const SizedBox(width: 3),
                                        Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(trip.dateEnd!),
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Países: ${trip.countries.map((c) => c.name).join(', ')}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    trip.open
                                        ? 'Estado: Abierto'
                                        : 'Estado: Cerrado',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: trip.open
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TripDetailPage(trip: trip),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      );
    });
  }
}
