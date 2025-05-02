import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/screens/trip_screen.dart';
import 'package:travify/services/trip_service.dart';

class DataContent extends StatefulWidget {
  const DataContent({super.key});

  @override
  State<DataContent> createState() => _DataContentState();
}

class _DataContentState extends State<DataContent> {
  final TripService _tripService = TripService();
  List<Trip> _trips = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final trips = await _tripService.getAllTrips();
    setState(() => _trips = trips);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = _trips
        .where(
            (trip) => trip.title.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.only(top: 26),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Estadísticas",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar viaje...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredTrips.isEmpty
                ? const Center(
                    child: Text('No hay viajes',
                        style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailPage(trip: trip),
                            ),
                          );
                          // Recargar viajes al volver
                          setState(() {
                            _loadTrips();
                          });
                        },
                        child: _TripStatsCard(trip: trip),
                      );
                    }),
          )
        ],
      ),
    );
  }
}

class _TripStatsCard extends StatelessWidget {
  final Trip trip;
  const _TripStatsCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dailyData = _generateDailyData(trip);
    final expensesByCategory = _generateExpensesByCategory(trip);
    final currencyUsage = _generateCurrencyChangeStats(trip);

    final darkColors = [
      const Color(0xFF2C5282),
      const Color(0xFF553C9A),
      const Color(0xFF22543D),
      const Color(0xFF742A2A),
      const Color(0xFF1A202C),
      const Color(0xFF6B46C1),
      const Color(0xFF2A4365),
      const Color(0xFF276749),
      const Color(0xFF5F370E),
    ];

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${DateFormat('dd/MM/yyyy').format(trip.dateStart)}${trip.dateEnd != null ? ' - ' + DateFormat('dd/MM/yyyy').format(trip.dateEnd!) : ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('dd/MM'),
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(color: Colors.white70),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white70),
                majorGridLines: const MajorGridLines(width: 0.5),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(color: Colors.white),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                textStyle: const TextStyle(color: Colors.black),
              ),
              series: <CartesianSeries<_DailyStat, DateTime>>[
                ColumnSeries<_DailyStat, DateTime>(
                  dataSource: dailyData,
                  xValueMapper: (_DailyStat data, _) => data.date,
                  yValueMapper: (_DailyStat data, _) => data.incomes,
                  name: 'Ingresos',
                  color: const Color(0xFF4FD1C5),
                ),
                ColumnSeries<_DailyStat, DateTime>(
                  dataSource: dailyData,
                  xValueMapper: (_DailyStat data, _) => data.date,
                  yValueMapper: (_DailyStat data, _) => data.expenses,
                  name: 'Gastos',
                  color: const Color(0xFF805AD5),
                ),
                ColumnSeries<_DailyStat, DateTime>(
                  dataSource: dailyData,
                  xValueMapper: (_DailyStat data, _) => data.date,
                  yValueMapper: (_DailyStat data, _) => data.changes,
                  name: 'Cambios',
                  color: const Color(0xFF63B3ED),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SfCircularChart(
              title: ChartTitle(
                text: 'Gastos por Categoría',
                textStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: const TextStyle(color: Colors.white70),
              ),
              series: <CircularSeries<_CategoryExpense, String>>[
                PieSeries<_CategoryExpense, String>(
                  dataSource: expensesByCategory,
                  xValueMapper: (_CategoryExpense data, _) => data.category,
                  yValueMapper: (_CategoryExpense data, _) => data.amount,
                  dataLabelMapper: (_CategoryExpense data, _) =>
                      '${data.category}: ${data.amount.toStringAsFixed(2)}',
                  pointColorMapper: (_, index) =>
                      darkColors[index % darkColors.length],
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (currencyUsage.isNotEmpty)
              SfCircularChart(
                title: ChartTitle(
                  text: 'Divisas más utilizadas (cambios)',
                  textStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  textStyle: const TextStyle(color: Colors.white70),
                ),
                series: <CircularSeries<_CurrencyChange, String>>[
                  DoughnutSeries<_CurrencyChange, String>(
                    dataSource: currencyUsage,
                    xValueMapper: (_CurrencyChange data, _) => data.currency,
                    yValueMapper: (_CurrencyChange data, _) => data.amount,
                    dataLabelMapper: (_CurrencyChange data, _) =>
                        '${data.currency}: ${data.amount.toStringAsFixed(2)}',
                    pointColorMapper: (_, index) =>
                        darkColors[index % darkColors.length],
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<_DailyStat> _generateDailyData(Trip trip) {
    final Map<DateTime, _DailyStat> dailyStats = {};

    for (var transaction in trip.transactions) {
      final date = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      dailyStats.putIfAbsent(date, () => _DailyStat(date));

      switch (transaction.type) {
        case TransactionType.income:
          dailyStats[date]!.incomes += transaction.amount;
          break;
        case TransactionType.expense:
          dailyStats[date]!.expenses += transaction.amount;
          break;
        case TransactionType.change:
          dailyStats[date]!.changes += transaction.amount;
          break;
      }
    }

    return dailyStats.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_CategoryExpense> _generateExpensesByCategory(Trip trip) {
    final Map<String, double> categoryExpenses = {};

    for (var transaction
        in trip.transactions.where((t) => t.type == TransactionType.expense)) {
      final category = (transaction as Expense).category.name;
      categoryExpenses[category] =
          (categoryExpenses[category] ?? 0) + transaction.amount;
    }

    return categoryExpenses.entries
        .map((e) => _CategoryExpense(e.key, e.value))
        .toList();
  }

  List<_CurrencyChange> _generateCurrencyChangeStats(Trip trip) {
    final Map<String, double> currencyMap = {};

    for (var transaction
        in trip.transactions.where((t) => t.type == TransactionType.change)) {
      final currency = (transaction as Change).currencyRecived.name;
      currencyMap[currency] = (currencyMap[currency] ?? 0) + transaction.amount;
    }

    return currencyMap.entries
        .map((e) => _CurrencyChange(e.key, e.value))
        .toList();
  }
}

class _DailyStat {
  final DateTime date;
  double incomes = 0;
  double expenses = 0;
  double changes = 0;

  _DailyStat(this.date);
}

class _CategoryExpense {
  final String category;
  final double amount;

  _CategoryExpense(this.category, this.amount);
}

class _CurrencyChange {
  final String currency;
  final double amount;

  _CurrencyChange(this.currency, this.amount);
}
