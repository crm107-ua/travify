import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/trip_screen.dart';

class HorizontalGridWithIndicator extends StatefulWidget {
  final List<Trip> trips;
  const HorizontalGridWithIndicator({super.key, required this.trips});

  @override
  // ignore: library_private_types_in_public_api
  _HorizontalGridWithIndicatorState createState() =>
      _HorizontalGridWithIndicatorState();
}

class _HorizontalGridWithIndicatorState
    extends State<HorizontalGridWithIndicator> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (widget.trips.length / 3).ceil();

    List<List<Trip>> paginatedTrips = List.generate(
      totalPages,
      (index) {
        int start = index * 3;
        int end = (start + 3).clamp(0, widget.trips.length);
        return widget.trips.sublist(start, end);
      },
    );

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              final pageTrips = paginatedTrips[pageIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: List.generate(
                    pageTrips.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: _buildTripCard(pageTrips[i]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Indicador de páginas
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : const Color.fromARGB(255, 119, 118, 118),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(Trip trip) {
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
            // Info izquierda
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
                    trip.countries.map((c) => c.name).join(', '),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            // Info derecha
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(trip.dateStart!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (trip.dateEnd != null) ...[
                    const SizedBox(height: 3),
                    const Icon(Icons.arrow_downward,
                        color: Colors.white, size: 18),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('dd/MM/yyyy').format(trip.dateEnd!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
