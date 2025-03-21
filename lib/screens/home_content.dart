import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/utils/horizontal_grid.dart';
import 'package:travify/services/trip_service.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  final TripService _tripService = TripService();
  late Future<List<dynamic>> _combinedFuture;
  late AnimationController _blinkingController;
  bool _sortByRecent = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();

    _blinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.2,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _loadTrips();
      setState(() {});
    }
  }

  void _loadTrips() {
    _combinedFuture = Future.wait([
      _tripService.getUpcomingTrips(),
      _tripService.getCurrentTripOrNextTrip(),
    ]).then((results) {
      final List<Trip> trips = results[0] as List<Trip>;
      final Trip? currentTrip = results[1] as Trip?;

      trips.sort((a, b) => _sortByRecent
          ? a.dateStart.compareTo(b.dateStart)
          : b.dateStart.compareTo(a.dateStart));

      return [trips, currentTrip];
    });
  }

  @override
  void dispose() {
    _blinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _combinedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No se pudieron cargar los datos'));
        }

        final List<Trip> trips = snapshot.data![0];
        final Trip? currentOrNextTrip = snapshot.data![1];

        final List<Trip> filteredTrips = currentOrNextTrip == null
            ? trips
            : trips.where((trip) => trip.id != currentOrNextTrip.id).toList();

        if (filteredTrips.isEmpty && currentOrNextTrip == null) {
          return _buildEmptyTripsUI();
        }

        return _buildTripsUI(filteredTrips, currentOrNextTrip);
      },
    );
  }

  Widget _buildEmptyTripsUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://wallpapercat.com/w/full/7/9/c/293012-3840x2160-desktop-4k-new-york-wallpaper.jpg'),
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
                offset: const Offset(0, -100),
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

  Widget _buildTripsUI(List<Trip> trips, Trip? currentTrip) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: 340,
              collapsedHeight: currentTrip?.dateStart != null &&
                      currentTrip!.dateStart.isAfter(DateTime.now())
                  ? 150
                  : 120,
              pinned: true,
              backgroundColor: Colors.black,
              flexibleSpace: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double maxHeight = 400;
                    double minHeight = 120;
                    double currentHeight =
                        constraints.maxHeight.clamp(minHeight, maxHeight);
                    double percentage =
                        ((currentHeight - minHeight) / (maxHeight - minHeight))
                            .clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding:
                          EdgeInsets.only(left: 16, bottom: percentage * 50),
                      title: currentTrip == null
                          ? const Text("Sin viaje actual",
                              style: TextStyle(color: Colors.white))
                          : _buildAppBarContent(currentTrip),
                      background: _buildAppBarBackground(),
                    );
                  },
                ),
              ),
            ),
          ),
        ];
      },
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              trips.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                          height: 400,
                          alignment: Alignment.center,
                          child: const Text('Crea más viajes para verlos aquí',
                              style: TextStyle(fontSize: 20))),
                    )
                  : SliverToBoxAdapter(
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
                                const SizedBox(width: 9),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _sortByRecent =
                                          !_sortByRecent; // Cambia el orden
                                      _loadTrips(); // Recarga
                                    });
                                  },
                                  child: Row(
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
                                        _sortByRecent
                                            ? 'Más reciente'
                                            : 'Más lejano',
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              SliverToBoxAdapter(
                child: HorizontalGridWithIndicator(trips: trips),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBarContent(Trip trip) {
    final bool isUpcoming = trip.dateEnd != null &&
        trip.dateStart!.isAfter(DateTime.now()) &&
        trip.dateEnd!.isAfter(DateTime.now());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isUpcoming
            ? const Text(
                '¡Prepárate para tu próximo viaje!',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )
            : Row(
                children: [
                  const Text(
                    'Ahora mismo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Punto rojo parpadeante
                  AnimatedBuilder(
                    animation: _blinkingController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _blinkingController.value,
                        child: const Icon(Icons.circle,
                            size: 10, color: Colors.redAccent),
                      );
                    },
                  ),
                ],
              ),
        const SizedBox(height: 10),
        Text(
          trip.title,
          style: const TextStyle(fontSize: 25, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 5),
        Text(
          trip.countries.map((c) => c.name).join(', '),
          style: const TextStyle(fontSize: 16, color: Colors.white70),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              DateFormat('dd-MM-yyyy').format(trip.dateStart!),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trip.dateEnd != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd-MM-yyyy').format(trip.dateEnd!),
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
    );
  }

  Widget _buildAppBarBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://wallpapers.com/images/hd/4k-new-york-city-night-79y2vrc0ks0ucwh5.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.black45,
          ),
        )
      ],
    );
  }
}
