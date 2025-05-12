import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travify/constants/images.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/notifiers/trip_notifier.dart';
import 'package:travify/screens/forms/form_change.dart';
import 'package:travify/services/transaction_service.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/forms/form_expense.dart';
import 'package:travify/screens/forms/form_income.dart';
import 'package:travify/screens/forms/form_travel.dart';

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
  late TripNotifier _tripNotifier;
  final TransactionService _transactionService = TransactionService();
  double _realBalance = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trip = widget.trip;
    _tripNotifier = Provider.of<TripNotifier>(context, listen: false);
    _initTripData();
  }

  Future<void> _initTripData() async {
    await _transactionService.generateAmortizations(_trip);
    await _transactionService.generateRecurrentIncomes(_trip);
    await _tripNotifier.loadCurrentTripAndUpcoming();
    final updated = _tripNotifier.getRefreshedTrip(_trip);
    setState(() {
      _trip = updated;
      _calcRealBalance();
      _loading = false;
    });
  }

  void _calcRealBalance() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalExpenses = _trip.transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .whereType<Expense>()
        .fold(0.0, (sum, expense) {
      if (expense.isAmortization == true) {
        final start = expense.startDateAmortization ?? _trip.dateStart;
        final startDate = DateTime(start.year, start.month, start.day);

        if (startDate.isAfter(today)) {
          return sum;
        }
        return sum + expense.amortization!;
      } else {
        return sum + expense.amount;
      }
    });

    final totalIncomes = _trip.transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .whereType<Income>()
        .fold(0.0, (sum, income) => sum + income.amount);

    _realBalance = totalIncomes - totalExpenses;
  }

  Color _getBalanceColor() {
    final positiveRealBalance = _realBalance.abs();
    if (_realBalance < 0 && positiveRealBalance > _trip.budget.desiredLimit) {
      return Colors.redAccent;
    } else if (_realBalance > 0) {
      return Colors.greenAccent;
    } else {
      return Colors.amberAccent;
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
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${'desired_expense'.tr()}: ${trip.budget.desiredLimit.toStringAsFixed(2)} ${trip.currency.symbol}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trip.transactions.isNotEmpty
                ? Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          _realBalance > 0
                              ? Icons.arrow_upward
                              : _realBalance < 0
                                  ? Icons.arrow_downward
                                  : Icons.equalizer,
                          color: _getBalanceColor(),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _realBalance > 0
                                  ? '+${_realBalance.toStringAsFixed(2)} ${trip.currency.symbol}'
                                  : '${_realBalance.toStringAsFixed(2)} ${trip.currency.symbol}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _getBalanceColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 30),
      ],
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

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      trip.open ? 'open'.tr() : 'closed'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                Switch(
                  value: trip.open,
                  activeColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.redAccent,
                  onChanged: (bool mode) async {
                    setState(() {
                      trip.open = mode;
                    });
                    await _tripNotifier.updateTrip(trip);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 23),
                  onPressed: () => _showTripSummaryDialog(context, trip),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white, size: 23),
                  color: Colors.grey[900],
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateOrEditTravelWizard(trip: _trip),
                          ),
                        );

                        if (updated is Trip) {
                          await _tripNotifier.updateTrip(updated);
                          final refreshed =
                              _tripNotifier.getRefreshedTrip(updated);
                          setState(() {
                            _trip = refreshed;
                            _calcRealBalance();
                          });
                        }

                        break;

                      case 'delete':
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.black87,
                            title: Text('delete_travel'.tr(),
                                style: TextStyle(color: Colors.white)),
                            content: Text('sure_delete_travel'.tr(),
                                style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('cancel'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('delete'.tr(),
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (result == true) {
                          await _tripNotifier.deleteTrip(_trip.id);
                          if (context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70, size: 18),
                          SizedBox(width: 10),
                          Text('edit_travel'.tr(),
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 10),
                          Text('delete_travel'.tr(),
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                trip.open
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 30),
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
                                  _trip.transactions.insert(0, newExpense);
                                  _trip.transactions
                                      .sort((a, b) => b.date.compareTo(a.date));
                                  _tabController.animateTo(0);
                                  _calcRealBalance();
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
                                  _trip.transactions
                                      .sort((a, b) => b.date.compareTo(a.date));
                                  _tabController.animateTo(1);
                                  _calcRealBalance();
                                });
                              }

                              break;
                            case 'change':
                              final newChanges = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeForm(
                                    trip: _trip,
                                    onSave: (List<Change> changes) {
                                      Navigator.pop(context, changes);
                                    },
                                  ),
                                ),
                              );
                              if (newChanges != null &&
                                  newChanges is List<Change>) {
                                for (final change in newChanges) {
                                  await _transactionService
                                      .createTransaction(change);
                                  setState(() {
                                    _trip.transactions.add(change);
                                    _trip.transactions.sort(
                                        (a, b) => b.date.compareTo(a.date));
                                    _tabController.animateTo(2);
                                    _calcRealBalance();
                                  });
                                }
                              }
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'expense',
                            child: Row(
                              children: [
                                Icon(Icons.money_off,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('new_expense'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'income',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('new_income'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'change',
                            child: Row(
                              children: [
                                Icon(Icons.swap_horiz,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('new_change'.tr(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
                                        ? (trip.image!.startsWith('http')
                                            ? Image.network(
                                                trip.image!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(trip.image!),
                                                fit: BoxFit.cover,
                                              ))
                                        : Image.asset(
                                            AppImages.defaultImage,
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
                tabs: [
                  Tab(text: 'expenses'.tr()),
                  Tab(text: 'incomes'.tr()),
                  Tab(text: 'changes'.tr())
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
        .toList();

    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Text(
            'create_your_first_expense'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 19),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 17, left: 9, right: 9),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return GestureDetector(
          onTap: () =>
              showTransactionDetailDialog(trip, context, expense, () async {
            _transactionService.deleteTransaction(expense).then((_) {
              setState(() {
                _trip.transactions.remove(expense);
                _calcRealBalance();
              });
            });
          }, (active) async {
            {}
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
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
                        expense.description ?? 'no_description'.tr(),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(expense.date),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
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
                            '${'total'.tr()}: (${expense.amount.toStringAsFixed(2)}${trip.currency.symbol}) - ',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        Text(
                          "${expense.category.key.tr()}${expense.isAmortization == false ? ' - ${'unique_expense'.tr()}' : ''}",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (expense.isAmortization == true &&
                        expense.startDateAmortization != null &&
                        expense.endDateAmortization != null)
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(expense.startDateAmortization!)} - ${DateFormat('dd/MM/yyyy').format(expense.endDateAmortization!)}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    if (expense.isAmortization == true &&
                        expense.startDateAmortization == null &&
                        expense.endDateAmortization == null)
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(trip.dateStart)}'
                        ' - ${DateFormat('dd/MM/yyyy').format(trip.dateEnd ?? trip.dateStart)}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeList(Trip trip) {
    final incomes = trip.transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .whereType<Income>()
        .toList();

    if (incomes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Text(
            'create_your_first_income'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 19),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 17, left: 9, right: 9),
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return GestureDetector(
          onTap: () =>
              showTransactionDetailDialog(trip, context, income, () async {
            _transactionService.deleteTransaction(income).then((_) {
              setState(() {
                _trip.transactions.remove(income);
                _calcRealBalance();
              });
            });
          }, (active) async {
            income.active = active;
            _transactionService.updateIncomeActive(income);
            final index =
                _trip.transactions.indexWhere((t) => t.id == income.id);
            if (index != -1) {
              setState(() {
                _trip.transactions[index] = income;
                _calcRealBalance();
              });
            }
          }), // income o change según el caso
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
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
                        income.description ?? 'no_description'.tr(),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(income.date),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
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
                      income.isRecurrent == true && income.active == true
                          ? income.nextRecurrentDate != null
                              ? '${'next_income'.tr()}: ${DateFormat('dd/MM/yyyy').format(income.nextRecurrentDate!)}'
                              : 'recurrent'.tr()
                          : 'unique_income'.tr(),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangeList(Trip trip) {
    final changes = trip.transactions
        .where((transaction) => transaction.type == TransactionType.change)
        .whereType<Change>()
        .toList();

    if (changes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Text(
            'create_your_first_change'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 19),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 17, left: 9, right: 9),
      itemCount: changes.length,
      itemBuilder: (context, index) {
        final change = changes[index];
        return GestureDetector(
          onTap: () =>
              showTransactionDetailDialog(trip, context, change, () async {
            _transactionService.deleteTransaction(change).then((_) {
              setState(() {
                _trip.transactions.remove(change);
              });
            });
          }, (active) async {
            {}
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                        change.description ?? 'no_description'.tr(),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(change.date),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${'comision_abreviated'.tr()}: ${(change.commission * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${change.amount}${change.currencySpent.symbol}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(Icons.arrow_downward,
                        color: Colors.white, size: 18),
                    const SizedBox(height: 3),
                    Text(
                      '${change.amountRecived}${change.currencyRecived.symbol}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showTransactionDetailDialog(
    Trip trip,
    BuildContext context,
    Transaction transaction,
    void Function()? onDelete,
    void Function(bool active)? onToggleActive,
  ) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(transaction.date);

    showDialog(
      context: context,
      builder: (context) {
        bool isActive = transaction is Income && (transaction.active ?? false);

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.black,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 16.0, top: 8),
                              child: Text(
                                transaction.description ??
                                    'no_description'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.black,
                                  title: Text('delete_trasaction'.tr(),
                                      style: TextStyle(color: Colors.white)),
                                  content: Text('sure_delete_trasaction'.tr(),
                                      style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('cancel'.tr(),
                                          style:
                                              TextStyle(color: Colors.white70)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('delete'.tr(),
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                onDelete?.call();
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Fecha
                      Text(
                        '📅 ${'date'.tr()}: $dateFormatted',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text('🧾 ${'type'.tr()}: ${transaction.type.label.tr()}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18)),

                      if (transaction is Expense) ...[
                        const SizedBox(height: 8),
                        Text(
                            '${'category'.tr()}: ${transaction.category.key.tr()}',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        if (transaction.isAmortization) ...[
                          Text(
                              '${'daily_amortization'.tr()}: ${transaction.amortization?.toStringAsFixed(2)}${trip.currency.symbol}',
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          if (transaction.startDateAmortization != null &&
                              transaction.endDateAmortization != null)
                            Text(
                                '${'range'.tr()}: ${DateFormat('dd/MM/yyyy').format(transaction.startDateAmortization!)} - ${DateFormat('dd/MM/yyyy').format(transaction.endDateAmortization!)}',
                                style: const TextStyle(color: Colors.white70)),
                        ] else ...[
                          Text(
                              '${'quantity'.tr()}: ${transaction.amount.toStringAsFixed(2)}${trip.currency.symbol}',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ] else if (transaction is Income) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${'quantity'.tr()}: +${transaction.amount.toStringAsFixed(2)}${trip.currency.symbol}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 5),
                        if (transaction.isRecurrent == true) ...[
                          Text(
                            '${'recurrency_type'.tr()}: ${transaction.recurrentIncomeType?.key.tr()}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 5),
                          if (transaction.nextRecurrentDate != null) ...[
                            if (transaction.active == false) ...[
                              Text(
                                'inactive_recurrent_income'.tr(),
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text('${'active'.tr()}:',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                const SizedBox(width: 12),
                                Switch(
                                  value: isActive,
                                  activeColor: Colors.greenAccent,
                                  onChanged: (value) {
                                    setState(() => isActive = value);
                                    onToggleActive?.call(value);
                                  },
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              'passed_recurrent_income'.tr(),
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ],
                      ] else if (transaction is Change) ...[
                        const SizedBox(height: 8),
                        Text(
                            '${'expended'.tr()}: ${transaction.amount.toStringAsFixed(2)} ${transaction.currencySpent.symbol}',
                            style: const TextStyle(color: Colors.white70)),
                        Text(
                            '${'reciebed'.tr()}: ${transaction.amountRecived.toStringAsFixed(2)} ${transaction.currencyRecived.symbol}',
                            style: const TextStyle(color: Colors.white70)),
                        Text(
                            '${'comission'.tr()}: ${(transaction.commission * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: Text('to_close'.tr(),
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTripSummaryDialog(BuildContext context, Trip trip) {
    final budget = trip.budget;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('trip_resume'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 22)),
                const SizedBox(height: 10),
                Text(trip.title,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                _buildSectionTitle('destiny'.tr()),
                _buildInfoText(trip.destination),
                const SizedBox(height: 16),
                _buildSectionTitle('countries'.tr()),
                _buildInfoText(trip.countries.map((c) => c.name).join(', ')),
                const SizedBox(height: 16),
                _buildSectionTitle('dates'.tr()),
                _buildInfoText(_formatTripDates(trip)),
                const SizedBox(height: 16),
                _buildSectionTitle('currency'.tr()),
                _buildInfoText(
                    '${trip.currency.symbol} - ${trip.currency.name}'),
                const SizedBox(height: 16),
                _buildSectionTitle('budget'.tr()),
                _buildInfoText(
                    '${'max_limit'.tr()}: ${budget.maxLimit}${trip.currency.symbol}'),
                _buildInfoText(
                    '${'desired_limit'.tr()}: ${budget.desiredLimit}${trip.currency.symbol}'),
                _buildInfoText(
                    '${'lock_limit'.tr()}: ${budget.limitIncrease ? "Sí" : "No"}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('to_close'.tr(), style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
