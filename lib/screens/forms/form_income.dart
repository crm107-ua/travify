import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/trip.dart';

class IncomeForm extends StatefulWidget {
  final Income? income;
  final void Function(Income) onSave;
  final Trip trip;

  const IncomeForm({
    super.key,
    this.income,
    required this.onSave,
    required this.trip,
  });

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isRecurrent = false;
  RecurrentIncomeType? _recurrentType;
  DateTime? _nextDate;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      final income = widget.income!;
      _descriptionController.text = income.description ?? '';
      _amountController.text = income.amount.toString();
      _selectedDate = income.date;
      _isRecurrent = income.isRecurrent ?? false;
      _recurrentType = income.recurrentIncomeType;
      _nextDate = income.nextRecurrentDate;
      _active = income.active ?? true;
    }
  }

  void _calculateNextDate() {
    if (_recurrentType == null) {
      _nextDate = null;
      return;
    }

    switch (_recurrentType!) {
      case RecurrentIncomeType.daily:
        _nextDate = _selectedDate.add(const Duration(days: 1));
        break;
      case RecurrentIncomeType.weekly:
        _nextDate = _selectedDate.add(const Duration(days: 7));
        break;
      case RecurrentIncomeType.monthly:
        _nextDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
        break;
      case RecurrentIncomeType.yearly:
        _nextDate = DateTime(
          _selectedDate.year + 1,
          _selectedDate.month,
          _selectedDate.day,
        );
        break;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final income = Income(
      id: widget.income?.id ?? 0,
      tripId: widget.trip.id,
      date: _selectedDate,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      isRecurrent: _isRecurrent,
      recurrentIncomeType: _isRecurrent ? _recurrentType : null,
      nextRecurrentDate: _isRecurrent ? _nextDate : null,
      active: _active,
    );

    widget.onSave(income);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Oculta el teclado al tocar fuera
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            widget.income != null ? 'edit_income'.tr() : 'new_income'.tr(),
            style: TextStyle(fontSize: 19),
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
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
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
                    LengthLimitingTextInputFormatter(20),
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('recurrent_iq'.tr(),
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Switch(
                      value: _isRecurrent,
                      onChanged: (val) {
                        setState(() {
                          _isRecurrent = val;
                          if (val) _calculateNextDate();
                        });
                      },
                      activeColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                if (_isRecurrent) ...[
                  DropdownButtonFormField<RecurrentIncomeType>(
                    value: _recurrentType,
                    decoration: InputDecoration(
                      labelText: 'recurrency_type'.tr(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    items: RecurrentIncomeType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.key.tr()),
                      );
                    }).toList(),
                    onChanged: (type) => setState(() {
                      _recurrentType = type;
                      _calculateNextDate();
                    }),
                    validator: (value) {
                      if (_isRecurrent && value == null) {
                        return 'select_type'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_nextDate != null)
                    Text(
                      '${'next_date'.tr()}: ${DateFormat('dd/MM/yyyy').format(_nextDate!)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('active_iq'.tr(),
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Switch(
                        value: _active,
                        onChanged: (val) => setState(() => _active = val),
                        activeColor: Colors.white,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  child: Text(widget.income != null
                      ? 'save_changes'.tr()
                      : 'create_income'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
