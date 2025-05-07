import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travify/constants/images.dart';
import 'package:travify/constants/videos.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/notifiers/trip_notifier.dart';
import 'package:travify/screens/trip_screen.dart';
import 'package:travify/screens/utils/horizontal_grid.dart';
import 'package:travify/screens/utils/single_trip_view.dart';
import 'package:video_player/video_player.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkingController;
  VideoPlayerController? _videoController;
  bool _sortByRecent = true;

  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripNotifier>(context, listen: false)
          .loadCurrentTripAndUpcoming();
    });

    _blinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.2,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  Future<void> _initializeVideo() async {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return;
    }

    final controller = VideoPlayerController.asset(
      AppVideos.homeVideo,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(0);
    await controller.setPlaybackSpeed(0.3);
    controller.play();

    setState(() {
      _videoController = controller;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _blinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripNotifier>(
      builder: (context, notifier, _) {
        final currentTrip = notifier.currentTrip;
        final trips = notifier.upcomingTrips;

        if (currentTrip == null && trips.isEmpty) {
          return _buildEmptyTripsUI();
        }

        final filteredTrips = trips
            .where((t) => t.id != currentTrip?.id)
            .where((t) => t.open)
            .toList();

        // Si solo hay un viaje
        if (filteredTrips.isEmpty && currentTrip != null) {
          return _buildSingleTripFullScreen(context, currentTrip);
        }

        // Varios viajes
        return _buildTripsUI(filteredTrips, currentTrip);
      },
    );
  }

  Widget _buildSingleTripFullScreen(BuildContext context, Trip trip) {
    return SingleTripFullScreen(
      trip: trip,
      buildAppBarBackground: _buildAppBarBackground,
    );
  }

  Widget _buildEmptyTripsUI() {
    return FutureBuilder(
      future: _initializeVideo(),
      builder: (context, snapshot) {
        final bool ready = snapshot.connectionState == ConnectionState.done &&
            _videoController != null &&
            _videoController!.value.isInitialized;

        return Stack(
          children: [
            // Fondo de video
            ready
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                : Container(color: Colors.black),
            Container(color: Colors.black.withOpacity(0.4)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
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
                        child: Text(
                          'new_travel'.tr(),
                          style: const TextStyle(
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildTripsUI(List<Trip> trips, Trip? currentTrip) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: 310,
              collapsedHeight: 160,
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
                          ? Text('no_actual_travel'.tr(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20))
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TripDetailPage(trip: currentTrip),
                                  ),
                                );
                              },
                              child: _buildAppBarContent(currentTrip),
                            ),
                      background: _buildAppBarBackground(currentTrip?.image),
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
                          child: Text('create_more_travel'.tr(),
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
                              'your_travels'.tr(),
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
                                            ? 'more_recent'.tr()
                                            : 'less_recent'.tr(),
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
            ? Text(
                'get_ready'.tr(),
                style: TextStyle(fontSize: 16, color: Colors.white),
              )
            : Row(
                children: [
                  Text(
                    'now'.tr(),
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
          maxLines: 2,
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
                fontSize: 12,
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
                  fontSize: 12,
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

  Widget _buildAppBarBackground(String? imagePathOrUrl) {
    Widget imageWidget;

    if (imagePathOrUrl != null && imagePathOrUrl.isNotEmpty) {
      if (imagePathOrUrl.startsWith('http')) {
        imageWidget = Image.network(imagePathOrUrl, fit: BoxFit.cover);
      } else {
        imageWidget = Image.file(File(imagePathOrUrl), fit: BoxFit.cover);
      }
    } else {
      imageWidget = Image.asset(AppImages.defaultImage, fit: BoxFit.cover);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black12,
                Colors.black87,
              ],
            ),
          ),
        ),
        Container(decoration: const BoxDecoration(color: Colors.black45)),
      ],
    );
  }
}
