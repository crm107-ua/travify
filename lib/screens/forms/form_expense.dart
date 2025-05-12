import 'package:another_flushbar/flushbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/services/trip_service.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? expense;
  final void Function(Expense) onSave;
  final Trip trip;

  const ExpenseForm({
    super.key,
    this.expense,
    required this.onSave,
    required this.trip,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TripService _tripService = TripService();

  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _category;
  bool _isAmortization = false;
  DateTime? _startDateAmortization;
  DateTime? _endDateAmortization;
  double? _dailyAmortization;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description ?? '';
      _amountController.text = expense.amount.toString();
      _selectedDate = expense.date;
      _category = expense.category;
      _isAmortization = expense.isAmortization;
      _startDateAmortization = expense.startDateAmortization;
      _endDateAmortization = expense.endDateAmortization;
      _calculateDailyAmortization();
    }
  }

  bool isFutureDate(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final inputDate = DateTime(date.year, date.month, date.day);
    return inputDate.isAfter(todayDate);
  }

  void _showSnackBar(String message) {
    Flushbar(
      duration: Duration(seconds: 2),
      borderRadius: BorderRadius.circular(8),
      margin: EdgeInsets.all(16),
      flushbarPosition: FlushbarPosition.BOTTOM,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]!
          : Colors.grey[200]!,
      messageText: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    ).show(context);
  }

  DateTime? calcularNextAmortizationDate({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (startDate == null || endDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final start = DateTime(startDate.year, startDate.month, startDate.day)
        .add(const Duration(days: 1));
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (today.isBefore(start)) {
      return start;
    } else if (today.isAfter(end)) {
      return null;
    } else {
      return today;
    }
  }

  void _calculateDailyAmortization() {
    if (_startDateAmortization != null && _endDateAmortization != null) {
      final startDate = DateTime(
        _startDateAmortization!.year,
        _startDateAmortization!.month,
        _startDateAmortization!.day,
      );

      final endDate = DateTime(
        _endDateAmortization!.year,
        _endDateAmortization!.month,
        _endDateAmortization!.day,
      );

      final days = endDate.difference(startDate).inDays + 1;
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (days > 0) {
        setState(() => _dailyAmortization = amount / days);
      }
    } else {
      if (widget.trip.dateEnd == null) return;

      final startDate = DateTime(
        widget.trip.dateStart.year,
        widget.trip.dateStart.month,
        widget.trip.dateStart.day,
      );

      final endDate = DateTime(
        widget.trip.dateEnd!.year,
        widget.trip.dateEnd!.month,
        widget.trip.dateEnd!.day,
      );

      final days = endDate.difference(startDate).inDays + 1;
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (days > 0) {
        setState(() => _dailyAmortization = amount / days);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime today = DateTime.now();
    final DateTime initial = isStartDate
        ? (_startDateAmortization ?? today)
        : (_endDateAmortization ?? today);

    final DateTime firstDate = DateTime(today.year, today.month, today.day);
    final DateTime lastDate = DateTime(2100, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDateAmortization = picked;
        } else {
          _endDateAmortization = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            widget.expense != null ? 'edit_expense'.tr() : 'new_expense'.tr(),
            style: const TextStyle(fontSize: 19),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'description'.tr(),
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _amountController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText:
                        '${'quantity'.tr()} (${widget.trip.currency.symbol})',
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged: (_) => _calculateDailyAmortization(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'required_field'.tr();
                    }
                    if (double.tryParse(value) == null) {
                      return 'invalid_number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'category'.tr(),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  items: ExpenseCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.key.tr(context: context)),
                    );
                  }).toList(),
                  onChanged: (cat) => setState(() => _category = cat),
                  validator: (value) =>
                      value == null ? 'category_select'.tr() : null,
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: Text('amortizatoion_iq'.tr(),
                      style: TextStyle(color: Colors.white)),
                  value: _isAmortization,
                  onChanged: (val) => setState(() => _isAmortization = val),
                  activeColor: Colors.white,
                ),
                if (_isAmortization) ...[
                  ListTile(
                    title: Text(
                        _startDateAmortization != null
                            ? '${'init'.tr()}: ${DateFormat('dd/MM/yyyy').format(_startDateAmortization!)}'
                            : 'date_init'.tr(),
                        style: const TextStyle(color: Colors.white)),
                    trailing:
                        const Icon(Icons.calendar_today, color: Colors.white),
                    onTap: () async {
                      _selectDate(context, true);
                      _calculateDailyAmortization();
                    },
                  ),
                  ListTile(
                    title: Text(
                        _endDateAmortization != null
                            ? '${'end'.tr()}: ${DateFormat('dd/MM/yyyy').format(_endDateAmortization!)}'
                            : 'date_end'.tr(),
                        style: const TextStyle(color: Colors.white)),
                    trailing:
                        const Icon(Icons.calendar_today, color: Colors.white),
                    onTap: () async {
                      await _selectDate(context, false);
                      _calculateDailyAmortization();
                    },
                  ),
                  if (_dailyAmortization != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                          '${'daily_amortization'.tr()}: ${_dailyAmortization!.toStringAsFixed(2)} ${widget.trip.currency.symbol}',
                          style: const TextStyle(color: Colors.white70)),
                    ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final expense = Expense(
                      id: widget.expense?.id ?? 0,
                      tripId: widget.trip.id,
                      date: _selectedDate,
                      description: _descriptionController.text,
                      amount: double.parse(_amountController.text),
                      category: _category!,
                      isAmortization: _isAmortization,
                      amortization: _dailyAmortization,
                      startDateAmortization: _startDateAmortization,
                      endDateAmortization: _endDateAmortization,
                      nextAmortizationDate: _isAmortization
                          ? calcularNextAmortizationDate(
                              startDate: _startDateAmortization,
                              endDate: _endDateAmortization,
                            )
                          : null,
                    );

                    Trip trip =
                        await _tripService.getTripById(widget.trip.id) as Trip;

                    final totalExpenses = trip.transactions
                        .where((transaction) =>
                            transaction.type == TransactionType.expense)
                        .whereType<Expense>()
                        .fold(0.0, (sum, expense) {
                      if (expense.isAmortization == true) {
                        return sum + expense.amortization!;
                      } else {
                        return sum + expense.amount;
                      }
                    });

                    final totalIncomes = trip.transactions
                        .where((transaction) =>
                            transaction.type == TransactionType.income)
                        .whereType<Income>()
                        .fold(0.0, (sum, income) => sum + income.amount);

                    final maxAvailableToSpend =
                        totalIncomes < trip.budget.maxLimit
                            ? trip.budget.maxLimit
                            : totalIncomes;

                    final totalExpensesWithNew = totalExpenses + expense.amount;

                    if (!trip.budget.limitIncrease) {
                      if (totalExpensesWithNew > maxAvailableToSpend) {
                        _showSnackBar(
                            '${'expense_limit_not_ok'.tr()}: ${trip.budget.maxLimit} ${trip.currency.symbol}');
                        return;
                      }
                    }

                    if (_startDateAmortization != null &&
                        _endDateAmortization == null) {
                      _showSnackBar('select_end_date'.tr());
                      return;
                    }

                    if (_startDateAmortization == null &&
                        _endDateAmortization != null) {
                      _showSnackBar('select_start_date'.tr());
                      return;
                    }

                    if (_isAmortization && _endDateAmortization != null) {
                      if (_endDateAmortization!
                          .isBefore(_startDateAmortization!)) {
                        _showSnackBar('date_before_not_ok'.tr());
                        return;
                      }
                      if (_endDateAmortization!
                          .isAtSameMomentAs(_startDateAmortization!)) {
                        _showSnackBar('date_equal_not_ok'.tr());
                        return;
                      }
                    }

                    widget.onSave(expense);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  child: Text(widget.expense != null
                      ? 'save_changes'.tr()
                      : 'create_expense'.tr()),
                ),
                if (_isAmortization &&
                    _startDateAmortization != null &&
                    isFutureDate(_startDateAmortization!))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '⚠️ ${'early_amortization'.tr()}',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
