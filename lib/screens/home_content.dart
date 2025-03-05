import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/utils/horizontal_grid.dart';
import 'package:travify/services/trip_service.dart';

class HomeContent extends StatelessWidget {
  HomeContent({Key? key}) : super(key: key);

  final TripService _tripService = TripService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: _tripService.getAllTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://wallpapercat.com/w/full/7/9/c/293012-3840x2160-desktop-4k-new-york-wallpaper.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/fondo.png',
                      width: MediaQuery.of(context).size.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                    Transform.translate(
                      offset: const Offset(0,
                          -100), // Ajusta este valor para mover el texto hacia arriba
                      child: const Text(
                        '¡Crea tu primer viaje!',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final trips = snapshot.data!;

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  expandedHeight: 340,
                  collapsedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.black,
                  flexibleSpace: FutureBuilder<Trip?>(
                    future: _tripService.getCurrentTripOrNextTrip(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                            child: Text('No se encontró el viaje con ID 1.'));
                      }
                      final trip = snapshot.data!;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          double maxHeight = 400;
                          double minHeight = 120;
                          double currentHeight =
                              constraints.maxHeight.clamp(minHeight, maxHeight);
                          double percentage = ((currentHeight - minHeight) /
                                  (maxHeight - minHeight))
                              .clamp(0.0, 1.0);
                          return FlexibleSpaceBar(
                            centerTitle: false,
                            titlePadding: EdgeInsets.only(
                                left: 16, bottom: percentage * 50),
                            title: Align(
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (trip.dateEnd != null &&
                                      trip.dateStart!.isAfter(DateTime.now()) &&
                                      trip.dateEnd!.isAfter(DateTime.now()))
                                    const Text(
                                      '¡Prepárate para tu próximo viaje!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    trip.title,
                                    style: const TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    trip.countries
                                        .map((country) => country.name)
                                        .join(', '),
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd-MM-yyyy')
                                            .format(trip.dateStart!),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (trip.dateEnd != null) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('dd-MM-yyyy')
                                              .format(trip.dateEnd!),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  child: Image.network(
                                    'https://wallpapercat.com/w/full/7/9/c/293012-3840x2160-desktop-4k-new-york-wallpaper.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                    ),
                                    color: Colors.black45,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ];
          },
          body: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  // Inyecta el overlap del SliverAppBar
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  // Encabezado "Tus Viajes"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tus Viajes',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 26,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Más reciente',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nuestro grid horizontal con indicador
                  SliverToBoxAdapter(
                    child: HorizontalGridWithIndicator(trips: trips),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
