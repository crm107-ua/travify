import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search_choices/search_choices.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/services/change_service.dart';
import 'package:travify/services/currency_service.dart';

enum RouteOption { direct, best }

class ChangeForm extends StatefulWidget {
  final Currency? initialFromCurrency;
  final Currency? initialToCurrency;
  final void Function(Income) onSave;
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

    // Cargar cambios históricos del viaje
    changes = widget.trip.transactions.whereType<Change>().toList();
  }

  void _onFormChanged() {
    // Esta función se llamará cada vez que un campo cambie de valor
    setState(() {});
  }

  void _loadCurrencies() async {
    final loaded = await CurrencyService().getAllCurrencies();
    setState(() {
      _currencies = loaded;
      _isLoading = false;

      // Si no se han pasado divisas iniciales, tomamos por defecto
      _fromCurrency ??= _currencies.firstWhere(
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Cambio de divisas',
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
                label: 'Cantidad origen',
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
              // Vista previa dinámica
              _buildDynamicPreview(),

              const SizedBox(height: 20),
            ],
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
                return 'Ingrese una cantidad';
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
            hint: 'Selecciona una divisa',
            searchHint: 'Buscar divisa...',
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
            decoration: const InputDecoration(
              labelText: 'Comisión',
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
            hint: 'Selecciona una divisa',
            searchHint: 'Buscar divisa...',
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

  Widget _buildDynamicPreview() {
    final fromValue = _fromAmountController.text.trim();
    final fromCode = _fromCurrency?.code ?? '';
    final toCode = _toCurrency?.code ?? '';
    final commissionValue = _commissionController.text.trim();

    // Se convierte la comisión (de porcentaje a decimal)
    double commission = double.tryParse(commissionValue) ?? 0.0;
    commission /= 100;

    final bool allFieldsFilled = fromValue.isNotEmpty &&
        fromCode.isNotEmpty &&
        toCode.isNotEmpty &&
        commissionValue.isNotEmpty;

    if (!allFieldsFilled) {
      return const Text(
        'Por favor, completa todos los campos para ver la vista previa del cambio.',
        style: TextStyle(color: Colors.white),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _changeService.ejemploDeUso(
        changes,
        fromCode,
        toCode,
        commission,
        double.tryParse(fromValue) ?? 0.0,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 100),
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Optimizando cambio de divisa...',
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

        final top3Chips = top3.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final (monto, ruta) = entry.value;
          return Chip(
            label: Text(
              '#$i: ${ruta.join(' → ')} => ${monto.toStringAsFixed(2)} $destino',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.grey[700],
          );
        }).toList();

        // Texto sobre la ruta óptima
        final mejorText =
            'Ruta óptima (#1): ${mejorRuta.join(' → ')} => ${mejorMonto.toStringAsFixed(2)} $destino';

        // Para la comparación
        String comparacion = 'No se puede comparar con ruta directa.';
        if (montoDirecto != null) {
          final diff = mejorMonto - montoDirecto;
          if (diff > 0) {
            comparacion =
                'La ruta #1 supera a la directa en ${diff.toStringAsFixed(2)} $destino.';
          } else if (diff < 0) {
            comparacion =
                'La ruta directa supera a la #1 en ${(-diff).toStringAsFixed(2)} $destino.';
          } else {
            comparacion = 'La ruta directa y la óptima dan el mismo resultado.';
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
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _changeService
                                      .confirmChange(
                                          mejorRuta,
                                          double.tryParse(fromValue) ?? 0.0,
                                          double.tryParse(commissionValue)! /
                                              100,
                                          changes)
                                      .then((changesToSave) {
                                    if (changesToSave.isNotEmpty) {
                                      print(changesToSave);
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // Fondo blanco
                                  foregroundColor:
                                      Colors.black, // Texto/Icono en negro
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.currency_exchange),
                                label: const Text('Confirmar cambio'),
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
                                    } else {
                                      _selectedOption = RouteOption.best;
                                    }
                                  });
                                },
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'Directa',
                                      style: TextStyle(
                                        // Podemos ajustar el tamaño del texto aquí si queremos
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'Óptima',
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
                    children: const [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Información de cambio:',
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
                          _selectedOption == RouteOption.direct
                              ? 'Has elegido la ruta directa: '
                                  '${montoDirecto?.toStringAsFixed(2)} $destino.'
                              : 'Has elegido la ruta óptima: '
                                  '${mejorMonto.toStringAsFixed(2)} $destino.',
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
                          'Ruta directa $origen → $destino: '
                          '${montoDirecto!.toStringAsFixed(2)} $destino',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        )
                      : const Text(
                          'No hay ruta directa disponible.',
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
                              children: top3Chips,
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
                          mejorText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
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
                              ? 'Comisión promedio de $origen → $destino: '
                                  '${comisionPromedia.toStringAsFixed(2)}%'
                              : 'No se encontró comisión promedio',
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
