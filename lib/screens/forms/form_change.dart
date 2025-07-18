import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search_choices/search_choices.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/services/change_service.dart';
import 'package:travify/services/currency_service.dart';
import 'package:travify/services/settings_service.dart';

enum RouteOption { direct, best }

class ChangeForm extends StatefulWidget {
  final Currency? initialFromCurrency;
  final Currency? initialToCurrency;
  final void Function(List<Change>) onSave;
  final Trip trip;

  const ChangeForm({
    super.key,
    this.initialFromCurrency,
    this.initialToCurrency,
    required this.trip,
    required this.onSave,
  });

  @override
  State<ChangeForm> createState() => _ChangeFormState();
}

class _ChangeFormState extends State<ChangeForm> {
  final _formKey = GlobalKey<FormState>();
  final ChangeService _changeService = ChangeService();
  late List<Change> changes;

  // Controladores de texto
  final TextEditingController _fromAmountController = TextEditingController();
  final TextEditingController _toAmountController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();

  Currency? _fromCurrency;
  Currency? _toCurrency;
  List<Currency> _currencies = [];
  bool _isLoading = true;
  RouteOption? _selectedOption;
  int _selectedChipIndex = 0;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();

    // Asignar monedas iniciales
    _fromCurrency = widget.initialFromCurrency;
    _toCurrency = widget.initialToCurrency;

    // Cargar monedas disponibles
    _loadCurrencies();

    // Listeners para refrescar la UI tan pronto cambien los campos:
    _fromAmountController.addListener(_onFormChanged);
    _toAmountController.addListener(_onFormChanged);
    _commissionController.addListener(_onFormChanged);

    // Cargar cambios de todos los viajes
    _loadAllChanges();
  }

  void _onFormChanged() {
    setState(() {});
  }

  void _loadAllChanges() async {
    final allChanges = await _changeService.getAllChanges();
    setState(() {
      changes = allChanges;
    });
  }

  void _loadCurrencies() async {
    final loaded = await CurrencyService().getAllCurrencies();
    final savedCode = await SettingsService.getDefaultCurrency();

    setState(() {
      _currencies = loaded;
      _isLoading = false;

      _fromCurrency ??= savedCode != null
          ? _currencies.firstWhere(
              (c) => c.code == savedCode,
              orElse: () => _currencies.first,
            )
          : _currencies.firstWhere(
              (c) => c.id == widget.trip.currency.id,
              orElse: () => _currencies.first,
            );

      _toCurrency ??= _currencies.firstWhere(
        (c) => c.id == widget.trip.countries.first.currencies.first.id,
        orElse: () => _currencies.first,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'currency_change'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 19),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Campo: Cantidad Origen
                _buildCurrencyRow(
                  controller: _fromAmountController,
                  currency: _fromCurrency,
                  onCurrencyChanged: (val) => setState(() {
                    _fromCurrency = val;
                  }),
                  label: 'origin_quantity'.tr(),
                ),
                const SizedBox(height: 20),
                // Campo: Cantidad Destino
                _buildCurrencyEndRow(
                  currency: _toCurrency,
                  onCurrencyChanged: (val) => setState(() {
                    _toCurrency = val;
                  }),
                ),
                const SizedBox(height: 30),
                _buildDynamicPreview(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyRow({
    required TextEditingController controller,
    required Currency? currency,
    required void Function(Currency?) onCurrencyChanged,
    required String label,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              LengthLimitingTextInputFormatter(5),
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
            ),
            onChanged: (value) {
              // Se llama cada vez que cambia el texto
              setState(() {});
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'input_quantity'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: SearchChoices.single(
            items: _currencies.map((c) {
              return DropdownMenuItem<Currency>(
                value: c,
                child: Text('${c.code} (${c.symbol})'),
              );
            }).toList(),
            value: currency,
            hint: 'currency_select'.tr(),
            searchHint: 'search_currency'.tr(),
            onChanged: (val) {
              onCurrencyChanged(val);
              // Esto también refresca la vista previa si cambias la divisa
              setState(() {});
            },
            isExpanded: true,
            style: const TextStyle(color: Colors.white),
            menuBackgroundColor: Colors.grey[900],
            displayClearIcon: false,
            iconEnabledColor: Colors.white,
            iconDisabledColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyEndRow({
    required Currency? currency,
    required void Function(Currency?) onCurrencyChanged,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _commissionController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,2}(\.\d{0,2})?$')),
            ],
            decoration: InputDecoration(
              labelText: 'comission'.tr(),
              suffixText: '%',
            ),
            // Aquí usas onChanged
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: SearchChoices.single(
            items: _currencies.map((c) {
              return DropdownMenuItem<Currency>(
                value: c,
                child: Text('${c.code} (${c.symbol})'),
              );
            }).toList(),
            value: currency,
            hint: 'currency_select'.tr(),
            searchHint: 'search_currency'.tr(),
            onChanged: (val) {
              onCurrencyChanged(val);
              setState(() {});
            },
            isExpanded: true,
            style: const TextStyle(color: Colors.white),
            menuBackgroundColor: Colors.grey[900],
            displayClearIcon: false,
            iconEnabledColor: Colors.white,
            iconDisabledColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicPreview() {
    final fromValue = _fromAmountController.text.trim();
    final fromCode = _fromCurrency?.code ?? '';
    final toCode = _toCurrency?.code ?? '';
    final commissionValue = _commissionController.text.trim();

    double commission = double.tryParse(commissionValue) ?? 0.0;
    if (commission >= 1.0) {
      commission /= 100;
    }

    final bool allFieldsFilled = fromValue.isNotEmpty &&
        fromCode.isNotEmpty &&
        toCode.isNotEmpty &&
        commissionValue.isNotEmpty &&
        fromValue != '0' &&
        fromValue != '1';

    if (!allFieldsFilled) {
      return Text(
        'change_complete_inputs'.tr(),
        style: TextStyle(color: Colors.white),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _changeService.initChange(
        changes,
        fromCode,
        toCode,
        commission,
        double.tryParse(fromValue) ?? 0.0,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 100),
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'change_optimization'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        if (data.containsKey('error')) {
          return Text(
            data['error'],
            style: const TextStyle(color: Colors.red),
          );
        }

        final String origen = data['origen'];
        final String destino = data['destino'];
        final double? montoDirecto = data['montoDirecto'];
        final double comisionPromedia =
            (data['comisionPromedia'] ?? 0.02) * 100;
        final List<(double, List<String>)> top3 =
            List<(double, List<String>)>.from(data['top3']);
        final (double mejorMonto, List<String> mejorRuta) =
            data['mejorRuta'] as (double, List<String>);

        final List<Widget> top3ChoiceChips = top3.asMap().entries.map((entry) {
          final i = entry.key;
          final (monto, ruta) = entry.value;

          return ChoiceChip(
            label: Text(
              '#${i + 1}: ${ruta.join(' → ')} => ${monto.toStringAsFixed(2)} $destino',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            selectedColor: Colors.blueGrey,
            disabledColor: Colors.grey[700],
            backgroundColor: Colors.grey[700],
            selected: _selectedChipIndex == i,
            onSelected: (bool selected) {
              _selectedOption = RouteOption.best;
              setState(() {
                if (selected) {
                  _selectedChipIndex = i;
                }
              });
            },
          );
        }).toList();

        final double chosenMonto = _selectedOption == RouteOption.direct
            ? (montoDirecto ?? mejorMonto)
            : top3[_selectedChipIndex].$1;

        final double displayMonto = _selectedOption == RouteOption.direct
            ? (montoDirecto ?? mejorMonto)
            : top3[_selectedChipIndex].$1;

        final String rutaTexto = _selectedOption == RouteOption.direct
            ? 'direct_path'.tr()
            : '${'path'.tr()} ${_selectedChipIndex + 1}';

        String comparacion = 'not_compare_direct_path'.tr();
        if (montoDirecto != null) {
          final diff =
              double.parse((chosenMonto - montoDirecto).toStringAsFixed(2));
          if (diff > 0) {
            comparacion =
                '${'the_path'.tr()} #${_selectedOption == RouteOption.direct ? 1 : _selectedChipIndex + 1} ${'in_best_direct_path'.tr()} ${diff.toStringAsFixed(2)} $destino.';
          } else if (diff < 0) {
            comparacion =
                '${'in_best_direct_path_to'.tr()} #${_selectedOption == RouteOption.direct ? 1 : _selectedChipIndex + 1} en ${(-diff).toStringAsFixed(2)} $destino.';
          } else {
            if (_selectedChipIndex == 0) {
              comparacion = 'same_result_path_selected'.tr();
            } else {
              comparacion = 'same_result_path'.tr();
            }
          }
        }

        // Determina si hay ruta directa disponible
        final bool hasDirectRoute = (montoDirecto != null);

        // Si _selectedOption no se ha definido, la inicializamos
        _selectedOption ??=
            hasDirectRoute ? RouteOption.best : RouteOption.best;

        // Construimos la UI
        return Container(
          padding: const EdgeInsets.all(2),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hasDirectRoute
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_isConfirming) return;

                                  setState(() {
                                    _isConfirming = true;
                                  });

                                  final List<String> chosenRoute =
                                      _selectedOption == RouteOption.direct
                                          ? mejorRuta
                                          : top3[_selectedChipIndex].$2;

                                  _changeService
                                      .confirmChange(
                                    chosenRoute,
                                    fromCode,
                                    toCode,
                                    double.tryParse(fromValue) ?? 0.0,
                                    double.tryParse(commissionValue)! / 100,
                                    changes,
                                    _selectedOption,
                                    widget.trip,
                                  )
                                      .then((changesToSave) {
                                    if (changesToSave.isNotEmpty) {
                                      widget.onSave(changesToSave);
                                    }
                                  }).whenComplete(() {
                                    setState(() {
                                      _isConfirming = false;
                                    });
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isConfirming
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.black),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'confirming'.tr(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.currency_exchange,
                                              color: Colors.black),
                                          SizedBox(width: 12),
                                          Text(
                                            'confirm_change'.tr(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ToggleButtons(
                                borderRadius: BorderRadius.circular(12),
                                borderColor: Colors.white,
                                selectedBorderColor: Colors.white,
                                borderWidth: 2,
                                fillColor: Colors.white,
                                color: Colors.white,
                                selectedColor: Colors.black,
                                isSelected: [
                                  _selectedOption == RouteOption.direct,
                                  _selectedOption == RouteOption.best,
                                ],
                                onPressed: (index) {
                                  setState(() {
                                    if (index == 0) {
                                      _selectedOption = RouteOption.direct;
                                      _selectedChipIndex = -1;
                                    } else {
                                      _selectedOption = RouteOption.best;
                                      _selectedChipIndex = 0;
                                    }
                                  });
                                },
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'direct'.tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 15.5),
                                    child: Text(
                                      'optim'.tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '${'change_info'.tr()}:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                hasDirectRoute
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${'you_have_chosen'.tr()} $rutaTexto: ${displayMonto.toStringAsFixed(2)} $destino.',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: hasDirectRoute
                      ? Text(
                          '${'direct_path'.tr()} $origen → $destino: '
                          '${montoDirecto!.toStringAsFixed(2)} $destino',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        )
                      : Text(
                          'not_direct_path_available'.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                ),
                hasDirectRoute
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: top3ChoiceChips,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                hasDirectRoute
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          comparacion,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : const SizedBox.shrink(),
                hasDirectRoute
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          comisionPromedia > 0
                              ? '${'average_commission'.tr()} $origen → $destino: '
                                  '${comisionPromedia.toStringAsFixed(2)}%'
                              : 'not_average_commission_find'.tr(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
