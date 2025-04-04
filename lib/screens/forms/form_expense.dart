import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/models/expense.dart';
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

  final TripService _tripService = TripService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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

  void _calculateDailyAmortization() {
    if (_startDateAmortization != null && _endDateAmortization != null) {
      final days =
          _endDateAmortization!.difference(_startDateAmortization!).inDays + 1;
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (days > 0) {
        setState(() => _dailyAmortization = amount / days);
      }
    } else {
      _startDateAmortization = widget.trip.dateStart;
      _endDateAmortization = widget.trip.dateEnd;
      final days =
          _endDateAmortization!.difference(_startDateAmortization!).inDays + 1;
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (days > 0) {
        setState(() => _dailyAmortization = amount / days);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? widget.trip.dateStart : widget.trip.dateEnd,
      firstDate: widget.trip.dateStart,
      lastDate: widget.trip.dateEnd ?? DateTime.now(),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.expense != null ? 'Editar gasto' : 'Nuevo gasto',
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
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Cantidad (${widget.trip.currency.symbol})',
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => _calculateDailyAmortization(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ExpenseCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (cat) => setState(() => _category = cat),
                validator: (value) =>
                    value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 15),
              SwitchListTile(
                title: const Text('¿Amortizable?',
                    style: TextStyle(color: Colors.white)),
                value: _isAmortization,
                onChanged: (val) => setState(() => _isAmortization = val),
                activeColor: Colors.white,
              ),
              if (_isAmortization) ...[
                ListTile(
                  title: Text(
                      _startDateAmortization != null
                          ? 'Inicio: ${DateFormat('dd/MM/yyyy').format(_startDateAmortization!)}'
                          : 'Fecha de inicio',
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
                          ? 'Fin: ${DateFormat('dd/MM/yyyy').format(_endDateAmortization!)}'
                          : 'Fecha de fin',
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
                        'Amortización diaria: ${_dailyAmortization!.toStringAsFixed(2)} ${widget.trip.currency.symbol}',
                        style: const TextStyle(color: Colors.white70)),
                  ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  final expense = Expense(
                    id: widget.expense?.id ?? 0,
                    date: _selectedDate,
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    category: _category!,
                    isAmortization: _isAmortization,
                    amortization: _dailyAmortization,
                    startDateAmortization: _startDateAmortization,
                    endDateAmortization: _endDateAmortization,
                  );

                  widget.onSave(expense);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black),
                child: Text(
                    widget.expense != null ? 'Guardar cambios' : 'Crear gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
