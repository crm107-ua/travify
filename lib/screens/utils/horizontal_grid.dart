import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/trip_screen.dart';

class HorizontalGridWithIndicator extends StatefulWidget {
  final List<Trip> trips;
  const HorizontalGridWithIndicator({Key? key, required this.trips})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HorizontalGridWithIndicatorState createState() =>
      _HorizontalGridWithIndicatorState();
}

class _HorizontalGridWithIndicatorState
    extends State<HorizontalGridWithIndicator> {
  final ScrollController _gridController = ScrollController();
  int _currentPage = 0;

  final double pageWidth = 400 + 16;
  final int totalPages = 0;

  @override
  void dispose() {
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (widget.trips.length / 3).ceil().clamp(1, 3);
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: GridView.builder(
            controller: _gridController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: widget.trips.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 filas (por columna horizontal)
              mainAxisSpacing: 16, // Espaciado horizontal entre celdas
              crossAxisSpacing: 16, // Espaciado vertical entre celdas
              mainAxisExtent: 400, // Ancho fijo para cada celda
            ),
            itemBuilder: (context, index) {
              final trip = widget.trips[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailPage(trip: trip),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sección 1: Destino y países
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.destination,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              trip.countries
                                  .map((country) => country.name)
                                  .join(', '),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      // Sección 2: Fechas
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(trip.dateStart!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (trip.dateEnd != null) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(trip.dateEnd!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Indicador de páginas (3 puntos)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 119, 118, 118),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
