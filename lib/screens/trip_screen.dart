import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/services/transaction_service.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/forms/form_expense.dart';
import 'package:travify/screens/forms/form_income.dart';
import 'package:travify/screens/forms/form_travel.dart';
import 'package:travify/services/trip_service.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Trip _trip;
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trip = widget.trip;
  }

  Future<void> _reloadTrip() async {
    final updated = await TripService().getTripById(_trip.id);
    if (updated != null) {
      setState(() {
        _trip = updated;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildAppBarFlexibleContent() {
    final trip = _trip;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          style: const TextStyle(fontSize: 20, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 5),
        Text(
          '${trip.destination} • ${trip.countries.map((c) => c.name).join(', ')}',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
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
          onPressed: () => _showTripSummaryDialog(context, trip),
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
            "Más información",
            style: TextStyle(fontSize: 10),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;

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
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 23),
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.black87,
                        title: const Text('Eliminar viaje',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                            '¿Estás seguro de que deseas eliminar este viaje?',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar',
                                style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (result == true) {
                      await TripService().deleteTrip(trip.id);
                      Navigator.pop(context, true);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 23),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateOrEditTravelWizard(trip: _trip),
                      ),
                    );

                    if (updated == true) {
                      await _reloadTrip();
                    }
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add, color: Colors.white, size: 30),
                  color: Colors.grey[900],
                  onSelected: (value) async {
                    switch (value) {
                      case 'expense':
                        final newExpense = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseForm(
                              trip: _trip,
                              onSave: (expense) {
                                Navigator.pop(context, expense);
                              },
                            ),
                          ),
                        );

                        if (newExpense != null && newExpense is Expense) {
                          await _transactionService
                              .createTransaction(newExpense);
                          setState(() {
                            _trip.transactions.add(newExpense);
                            _tabController.animateTo(0);
                          });
                        }
                        break;

                      case 'income':
                        final newIncome = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IncomeForm(
                              trip: _trip,
                              onSave: (income) {
                                Navigator.pop(context, income);
                              },
                            ),
                          ),
                        );

                        if (newIncome != null && newIncome is Income) {
                          await _transactionService
                              .createTransaction(newIncome);
                          setState(() {
                            _trip.transactions.add(newIncome);
                            _tabController.animateTo(1);
                          });
                        }
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
              _buildExpenseList(trip),
              _buildIncomeList(trip),
              _buildChangeList(trip),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTripSummaryDialog(BuildContext context, Trip trip) {
  final budget = trip.budget;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resumen del Viaje',
                  style: TextStyle(color: Colors.white, fontSize: 22)),
              const SizedBox(height: 10),
              Text(trip.title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              _buildSectionTitle('Destino'),
              _buildInfoText(trip.destination),
              const SizedBox(height: 16),
              _buildSectionTitle('Países'),
              _buildInfoText(trip.countries.map((c) => c.name).join(', ')),
              const SizedBox(height: 16),
              _buildSectionTitle('Fechas'),
              _buildInfoText(_formatTripDates(trip)),
              const SizedBox(height: 16),
              _buildSectionTitle('Divisa'),
              _buildInfoText('${trip.currency.symbol} - ${trip.currency.name}'),
              const SizedBox(height: 16),
              _buildSectionTitle('Presupuesto'),
              if (budget != null) ...[
                _buildInfoText('Límite Máximo: ${budget.maxLimit} €'),
                _buildInfoText('Límite Deseado: ${budget.desiredLimit} €'),
                _buildInfoText('Acumulado: ${budget.accumulated} €'),
                _buildInfoText(
                    '¿Aumentar límite?: ${budget.limitIncrease ? "Sí" : "No"}'),
              ] else
                _buildInfoText('No hay presupuesto asignado.'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar', style: TextStyle(color: Colors.white70)),
        ),
      ],
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _buildInfoText(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 14),
    ),
  );
}

String _formatTripDates(Trip trip) {
  final start = DateFormat('dd-MM-yyyy').format(trip.dateStart!);
  if (trip.dateEnd != null) {
    final end = DateFormat('dd-MM-yyyy').format(trip.dateEnd!);
    return '$start → $end';
  }
  return start;
}

Widget _buildExpenseList(Trip trip) {
  final expenses = trip.transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .whereType<Expense>()
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  if (expenses.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: Text(
          'Crea tu primer gasto ✨',
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
      ),
    );
  }

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.description ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(expense.date),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                expense.isAmortization == true
                    ? Text(
                        '-${expense.amortization?.toStringAsFixed(2)}${trip.currency.symbol}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        '-${expense.amount.toStringAsFixed(2)}${trip.currency.symbol}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (expense.isAmortization == true)
                      Text(
                        'Total: (${expense.amount.toStringAsFixed(2)}${trip.currency.symbol}) - ',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    Text(
                      "${expense.category.label}"
                      "${expense.isAmortization == false ? ' - Gasto único' : ''}",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (expense.isAmortization == true &&
                    expense.startDateAmortization != null &&
                    expense.endDateAmortization != null)
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(expense.startDateAmortization!)} - ${DateFormat('dd/MM/yyyy').format(expense.endDateAmortization!)}',
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

Widget _buildIncomeList(Trip trip) {
  final incomes = trip.transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .whereType<Income>()
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date)); // más reciente primero

  if (incomes.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: Text(
          'Crea tu primer ingreso ✨',
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: incomes.length,
    itemBuilder: (context, index) {
      final income = incomes[index];
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    income.description ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(income.date),
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${income.amount}${trip.currency.symbol}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  income.isRecurrent == true
                      ? income.nextRecurrentDate != null
                          ? 'Próximo ingreso: ${DateFormat('dd/MM/yyyy').format(income.nextRecurrentDate!)}'
                          : 'Recurrente'
                      : 'Ingreso único',
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

Widget _buildChangeList(Trip trip) {
  final changes = trip.transactions
      .where((transaction) => transaction.type == TransactionType.change)
      .whereType<Change>()
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  if (changes.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: Text(
          'Crea tu primer cambio ✨',
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: changes.length,
    itemBuilder: (context, index) {
      final change = changes[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // <-- Añadir aquí Expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    change.description ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(change.date),
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // altura mínima posible
              children: [
                Text(
                  '${change.amount}${change.currencySpent.symbol}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                const SizedBox(height: 3),
                const Icon(Icons.arrow_downward, color: Colors.white, size: 18),
                const SizedBox(height: 3),
                Text(
                  '${change.amountRecived}${change.currencyRecived.symbol}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
