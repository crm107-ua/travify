import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/services/trip_service.dart';

class HomeContent extends StatelessWidget {
  HomeContent({Key? key}) : super(key: key);

  final TripService _tripService = TripService();

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // 🔹 Sección superior que se contrae al hacer scroll
          SliverAppBar(
            expandedHeight: 400, // 🔹 Altura cuando está expandido
            collapsedHeight:
                120, // 🔹 Ajustamos la altura mínima cuando está colapsado
            pinned: true, // 🔹 Se mantiene visible al hacer scroll
            backgroundColor: Colors.black,
            flexibleSpace: FutureBuilder<Trip?>(
              future: _tripService.getTripById(1),
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
                    double maxHeight = 400; // expandedHeight de SliverAppBar
                    double minHeight = 120; // 🔹 Ajustamos la altura mínima
                    double currentHeight = constraints.maxHeight;

                    // Asegurar que currentHeight no sea menor que minHeight
                    currentHeight = currentHeight.clamp(minHeight, maxHeight);

                    // Calculamos el porcentaje de colapso, asegurando que siempre esté entre 0 y 1
                    double percentage =
                        ((currentHeight - minHeight) / (maxHeight - minHeight))
                            .clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      centerTitle:
                          false, // 🔹 Evita que el título se centre automáticamente
                      titlePadding: EdgeInsets.only(
                        left: 16,
                        bottom:
                            percentage * 50, // Ajuste dinámico de la posición
                      ),
                      title: Align(
                        alignment: Alignment
                            .bottomLeft, // 🔹 Asegura la alineación a la izquierda
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.title,
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white),
                            ),
                            const SizedBox(
                                height: 5), // Espaciado entre título y países

                            // 🔹 Países del viaje
                            Text(
                              trip.countries
                                  .map((country) => country.name)
                                  .join(', '),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                            const SizedBox(
                                height: 10), // Espaciado entre países y fechas

                            // 🔹 Fechas del viaje
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
                          // 🔹 Imagen de fondo con bordes redondeados en la parte inferior
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
                          // 🔹 Fondo oscuro para mejorar la legibilidad
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              color: Colors.black54, // Ajuste de opacidad
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ];
      },
      body: FutureBuilder<List<Trip>>(
        future: _tripService.getAllTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay viajes disponibles.'));
          }

          final trips = snapshot.data!;

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // 🔹 Alinea el título a la izquierda
            children: [
              // 🔹 Título "Tus Viajes"
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 25, bottom: 8),
                child: Text(
                  'Tus Viajes',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // 🔹 Lista de viajes
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
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
                          // 🔹 Sección 1: Destino y países
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
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  trip.countries
                                      .map((country) => country.name)
                                      .join(', '),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 🔹 Sección 2: Fechas
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (trip.dateStart != null)
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(trip.dateStart!),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  if (trip.dateStart != null &&
                                      trip.dateEnd != null) ...[
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
