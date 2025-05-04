import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/notifiers/trip_notifier.dart';
import 'package:travify/screens/trip_screen.dart';

class DataContent extends StatefulWidget {
  const DataContent({super.key});

  @override
  State<DataContent> createState() => _DataContentState();
}

class _DataContentState extends State<DataContent> {
  String _search = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tripNotifier = Provider.of<TripNotifier>(context);
    final filteredTrips = tripNotifier.allTrips.where((trip) {
      final hasData = trip.transactions.any((t) =>
          t.type == TransactionType.income ||
          t.type == TransactionType.expense ||
          t.type == TransactionType.change);
      return hasData &&
          trip.title.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "stats".tr(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'search_trip'.tr(),
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredTrips.isEmpty
                  ? Center(
                      child: Text('not_trips_with_data'.tr(),
                          style: TextStyle(color: Colors.white70)),
                    )
                  : PageView.builder(
                      itemCount: filteredTrips.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        final trip = filteredTrips[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: _TripStatsCard(trip: trip),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStatsCard extends StatefulWidget {
  final Trip trip;
  const _TripStatsCard({required this.trip});

  @override
  State<_TripStatsCard> createState() => _TripStatsCardState();
}

class _TripStatsCardState extends State<_TripStatsCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final expensesByCategory = _generateExpensesByCategory(trip);
    final changesByCurrency = _generateDailyDataGroupedByCurrency(trip);
    final totalAmount = expensesByCategory.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final legendStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
    );

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: trip.image?.startsWith('http') == true
                  ? Image.network(trip.image ?? '', fit: BoxFit.cover)
                  : Image.file(File(trip.image ?? ''), fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(trip.dateStart)}${trip.dateEnd != null ? ' - ${DateFormat('dd/MM/yyyy').format(trip.dateEnd!)}' : ''}',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new,
                            color: Colors.white70),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TripDetailPage(trip: trip)),
                          );
                          final tripNotifier =
                              Provider.of<TripNotifier>(context, listen: false);
                          await tripNotifier.loadCurrentTripAndUpcoming();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.amber,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(text: 'diary'.tr()),
                      Tab(text: 'categories'.tr()),
                      Tab(text: 'currencies'.tr()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat('dd/MM'),
                            labelStyle: const TextStyle(color: Colors.white70),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: const TextStyle(color: Colors.white70),
                            majorGridLines: const MajorGridLines(width: 0.3),
                          ),
                          legend:
                              Legend(isVisible: true, textStyle: legendStyle),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: _generateIncomeExpenseSeriesByCurrency(trip),
                        ),
                        SfCircularChart(
                          title: ChartTitle(
                              text: 'expenses_by_category'.tr(),
                              textStyle: legendStyle),
                          legend: Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                            position: LegendPosition.bottom,
                            textStyle: legendStyle,
                          ),
                          series: [
                            PieSeries<_CategoryExpense, String>(
                              dataSource: expensesByCategory,
                              xValueMapper: (data, _) => data.category,
                              yValueMapper: (data, _) => data.amount,
                              dataLabelMapper: (data, _) {
                                final percentage =
                                    (data.amount / totalAmount * 100)
                                        .toStringAsFixed(0);
                                return '${data.category}: $percentage%';
                              },
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat('dd/MM'),
                            labelStyle: const TextStyle(color: Colors.white70),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: const TextStyle(color: Colors.white70),
                            majorGridLines: const MajorGridLines(width: 0.3),
                          ),
                          legend: Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                            position: LegendPosition.bottom,
                            textStyle: legendStyle,
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: changesByCurrency.entries.map((entry) {
                            return ColumnSeries<_CurrencyDailyStat, DateTime>(
                              name: entry.key,
                              dataSource: entry.value,
                              xValueMapper: (data, _) => data.date,
                              yValueMapper: (data, _) => data.amount,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<CartesianSeries<_DailyStat, DateTime>>
      _generateIncomeExpenseSeriesByCurrency(Trip trip) {
    final Map<String, Map<DateTime, _DailyStat>> byCurrency = {};

    for (var t in trip.transactions) {
      if (t.type == TransactionType.income ||
          t.type == TransactionType.expense) {
        final currency = trip.currency.symbol;
        final date = DateTime(t.date.year, t.date.month, t.date.day);

        byCurrency.putIfAbsent(currency, () => {});
        byCurrency[currency]!.putIfAbsent(date, () => _DailyStat(date));

        if (t.type == TransactionType.income) {
          byCurrency[currency]![date]!.incomes += t.amount;
        } else {
          byCurrency[currency]![date]!.expenses += t.amount;
        }
      }
    }

    return byCurrency.entries.expand((entry) {
      final currency = entry.key;
      final stats = entry.value.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return [
        ColumnSeries<_DailyStat, DateTime>(
          name: '${'incomes'.tr()} ($currency)',
          dataSource: stats,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.incomes,
          color: Colors.greenAccent,
        ),
        ColumnSeries<_DailyStat, DateTime>(
          name: '${'expenses'.tr()} ($currency)',
          dataSource: stats,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.expenses,
          color: Colors.redAccent,
        )
      ];
    }).toList();
  }

  List<_CategoryExpense> _generateExpensesByCategory(Trip trip) {
    final Map<String, double> map = {};

    for (var t
        in trip.transactions.where((t) => t.type == TransactionType.expense)) {
      final cat = (t as Expense).category.key.tr(context: context);
      map[cat] = (map[cat] ?? 0) + t.amount;
    }

    return map.entries.map((e) => _CategoryExpense(e.key, e.value)).toList();
  }

  Map<String, List<_CurrencyDailyStat>> _generateDailyDataGroupedByCurrency(
      Trip trip) {
    final Map<String, Map<DateTime, double>> grouped = {};

    for (var t in trip.transactions) {
      if (t.type == TransactionType.change) {
        final change = t as Change;
        final currency = change.currencyRecived.name;
        final date = DateTime(t.date.year, t.date.month, t.date.day);

        grouped.putIfAbsent(currency, () => {});
        grouped[currency]![date] = (grouped[currency]![date] ?? 0) + t.amount;
      }
    }

    final result = <String, List<_CurrencyDailyStat>>{};
    for (final currency in grouped.keys) {
      final data = grouped[currency]!
          .entries
          .map((e) => _CurrencyDailyStat(e.key, e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      result[currency] = data;
    }

    return result;
  }
}

class _DailyStat {
  final DateTime date;
  double incomes = 0;
  double expenses = 0;

  _DailyStat(this.date);
}

class _CategoryExpense {
  final String category;
  final double amount;

  _CategoryExpense(this.category, this.amount);
}

class _CurrencyDailyStat {
  final DateTime date;
  final double amount;

  _CurrencyDailyStat(this.date, this.amount);
}
