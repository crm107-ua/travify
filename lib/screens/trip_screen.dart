import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/trip.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 pestañas
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildAppBarFlexibleContent() {
    final trip = widget.trip;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          style: const TextStyle(fontSize: 20, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 5),
        Text(
          '${trip.destination} • ${trip.countries.map((c) => c.name).join(', ')}',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
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
        ElevatedButton.icon(
          onPressed: () => _showBudgetDialog(context, trip),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(5, 26),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.account_balance_wallet, size: 14),
          label: const Text(
            "Ver presupuesto",
            style: TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 340,
              collapsedHeight: 190,
              pinned: true,
              backgroundColor: Colors.black,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add, color: Colors.white, size: 30),
                  color: Colors.grey[900],
                  onSelected: (value) {
                    switch (value) {
                      case 'expense':
                        print("Nuevo gasto");
                        break;
                      case 'income':
                        print("Nuevo ingreso");
                        break;
                      case 'change':
                        print("Nuevo cambio");
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'expense',
                      child: Row(
                        children: const [
                          Icon(Icons.money_off, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text('Nuevo gasto',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'income',
                      child: Row(
                        children: const [
                          Icon(Icons.attach_money,
                              color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text('Nuevo ingreso',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'change',
                      child: Row(
                        children: const [
                          Icon(Icons.swap_horiz, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text('Nuevo cambio',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: ClipRRect(
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
                      title: _buildAppBarFlexibleContent(),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                child:
                                    trip.image != null && trip.image!.isNotEmpty
                                        ? Image.network(trip.image!,
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            'https://images.pexels.com/photos/1519088/pexels-photo-1519088.jpeg',
                                            fit: BoxFit.cover,
                                          ),
                              ),
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
                            ],
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 18),
                tabs: const [
                  Tab(text: "Gastos"),
                  Tab(text: "Ingresos"),
                  Tab(text: "Cambios"),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExpenseList(), // ← nueva función que vas a crear
              _buildPlaceholder("Incomes del viaje"),
              _buildPlaceholder("Cambios de divisa"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

void _showBudgetDialog(BuildContext context, Trip trip) {
  final budget = trip.budget;

  if (budget == null) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Presupuesto', style: TextStyle(color: Colors.white)),
        content: const Text('No hay presupuesto asignado.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.black,
      title: const Text('Presupuesto', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Límite Máximo: ${budget.maxLimit} €',
              style: const TextStyle(color: Colors.white)),
          Text('Límite Deseado: ${budget.desiredLimit} €',
              style: const TextStyle(color: Colors.white)),
          Text('Acumulado: ${budget.accumulated} €',
              style: const TextStyle(color: Colors.white)),
          Text('¿Aumentar límite?: ${budget.limitIncrease ? "Sí" : "No"}',
              style: const TextStyle(color: Colors.white)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
        )
      ],
    ),
  );
}

Widget _buildExpenseList() {
  // Aquí deberías usar widget.trip.expenses si lo tienes
  final expenses = [
    {'desc': 'Hotel', 'amount': 120.0, 'date': DateTime.now()},
    {'desc': 'Comida', 'amount': 45.0, 'date': DateTime.now()},
    {'desc': 'Transporte', 'amount': 30.0, 'date': DateTime.now()},
  ];

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: expenses.length,
    itemBuilder: (context, index) {
      final expense = expenses[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "titulo",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${expense['amount']} €',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "descripcion",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
