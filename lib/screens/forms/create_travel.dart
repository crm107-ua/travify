import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/services/country_service.dart';
import 'package:travify/services/trip_service.dart';

class CreateTravelWizard extends StatefulWidget {
  const CreateTravelWizard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateTravelWizardState createState() => _CreateTravelWizardState();
}

class _CreateTravelWizardState extends State<CreateTravelWizard> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final CountryService _countryService = CountryService();
  final TripService _tripService = TripService();

  // Paso 0: Información general
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // Paso 1: Selección de países
  List<Country> _allCountries = [];
  List<Country> _selectedCountries = [];

  // Paso 2: Fechas del viaje
  DateTime? _dateStart;
  DateTime? _dateEnd;

  // Paso 3: Presupuesto
  final TextEditingController _maxLimitController = TextEditingController();
  final TextEditingController _desiredLimitController = TextEditingController();
  final TextEditingController _accumulatedController = TextEditingController();
  bool _maxLimitTouched = false;
  bool _desiredLimitTouched = false;
  bool _accumulatedTouched = false;
  bool _limitIncrease = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    List<Country> countries = await _countryService.getAllCountries();
    setState(() {
      _allCountries = countries;
    });
  }

  Future<void> _saveTrip(Trip trip) async {
    if (trip.dateEnd == null) {
      final exists = await _tripService.checkTripExistWithDate(trip.dateStart);
      if (exists) {
        _showSnackBar(
            "No puedes crear un viaje sin fecha de fin para esa fecha, ya tienes viajes programados");
        return;
      }
    } else {
      final exists =
          await _tripService.checkTripExists(trip.dateStart, trip.dateEnd!);
      if (exists) {
        _showSnackBar("Ya existe un viaje en esas fechas");
        return;
      }
    }

    await _tripService.createTrip(trip);
    Navigator.pop(context, true);
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? (_dateStart ?? initialDate) : (_dateEnd ?? initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Hace que el calendario sea oscuro
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateStart = picked;
        } else {
          _dateEnd = picked;
        }
      });
    }
  }

  void _showCountryMultiSelect() async {
    List<Country> tempSelected = List.from(_selectedCountries);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Seleccione países",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allCountries.length,
                  itemBuilder: (context, index) {
                    Country country = _allCountries[index];
                    return CheckboxListTile(
                      title: Text(country.name,
                          style: TextStyle(color: Colors.white)),
                      value: tempSelected.any((c) => c.id == country.id),
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            tempSelected.add(country);
                          } else {
                            tempSelected.removeWhere((c) => c.id == country.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text("Cancelar", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCountries = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Aceptar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onStepContinue() {
    bool isValidForm = _formKey.currentState!.validate();
    bool hasStepError = false;
    switch (_currentStep) {
      case 0:
        if (_titleController.text.isEmpty ||
            _destinationController.text.isEmpty) {
          _showSnackBar(
              "Por favor, complete todos los campos obligatorios en Información");
          hasStepError = true;
        }
        break;

      case 1:
        if (_selectedCountries.isEmpty) {
          _showSnackBar("Por favor, seleccione al menos un país");
          hasStepError = true;
        }
        break;

      case 2:
        if (_dateStart == null) {
          _showSnackBar("Por favor, seleccione una fecha de inicio");
          hasStepError = true;
        } else if (_dateEnd != null && _dateEnd!.isBefore(_dateStart!)) {
          _showSnackBar("La fecha de fin no puede ser anterior a la de inicio");
          hasStepError = true;
        } else if (DateTime(
                _dateStart!.year, _dateStart!.month, _dateStart!.day)
            .isBefore(DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day))) {
          _showSnackBar("La fecha de inicio no puede ser anterior a hoy");
          hasStepError = true;
        }
        break;

      case 3:
        if (_maxLimitController.text.isEmpty ||
            _desiredLimitController.text.isEmpty) {
          _showSnackBar("Por favor, complete el presupuesto");
          hasStepError = true;
        } else if (!RegExp(r'^\d+(\.\d{1,2})?$')
            .hasMatch(_maxLimitController.text)) {
          _showSnackBar(
              "Ingrese un valor numérico válido con hasta 2 decimales");
          hasStepError = true;
        } else if (_maxLimitController.text.isNotEmpty &&
            double.parse(_maxLimitController.text) <
                double.parse(_desiredLimitController.text)) {
          _showSnackBar(
              "El límite máximo no puede ser menor al límite deseado");
          hasStepError = true;
        }
        break;
    }

    if (!isValidForm || hasStepError) {
      return; // No avanzamos si hay errores
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Crear y guardar viaje si todo está bien
      Budget budget = Budget(
        id: 0,
        maxLimit: double.tryParse(_maxLimitController.text) ?? 0.0,
        desiredLimit: double.tryParse(_desiredLimitController.text) ?? 0.0,
        accumulated: double.tryParse(_accumulatedController.text) ?? 0.0,
        limitIncrease: _limitIncrease,
      );

      Trip trip = Trip(
        id: 0,
        title: _titleController.text,
        description: _descriptionController.text,
        dateStart: _dateStart ?? DateTime.now(),
        dateEnd: _dateEnd,
        destination: _destinationController.text,
        image: _imageController.text,
        open: true,
        budget: budget,
        countries: _selectedCountries,
      );

      _saveTrip(trip);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Crea tu nuevo viaje',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          steps: [
            Step(
                title:
                    Text('Información', style: TextStyle(color: Colors.white)),
                isActive: _currentStep >= 0,
                content: _buildInfoStep()),
            Step(
                title: Text('Países', style: TextStyle(color: Colors.white)),
                isActive: _currentStep >= 1,
                content: _buildCountryStep()),
            Step(
                title: Text('Fechas', style: TextStyle(color: Colors.white)),
                isActive: _currentStep >= 2,
                content: _buildDateStep()),
            Step(
                title:
                    Text('Presupuesto', style: TextStyle(color: Colors.white)),
                isActive: _currentStep >= 3,
                content: _buildBudgetStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep() => Column(children: [
        _buildTextField(_titleController, 'Título', isRequired: true),
        _buildTextField(_descriptionController, 'Descripción',
            isRequired: true),
        _buildTextField(_destinationController, 'Destino', isRequired: true),
        _buildTextField(_imageController, 'URL de la imagen', isRequired: false)
      ]);

  Widget _buildCountryStep() => ListTile(
      title: Text(
          _selectedCountries.isEmpty
              ? 'Seleccione pais(es)'
              : 'Países: ${_selectedCountries.map((c) => c.name).join(', ')}',
          style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_drop_down, color: Colors.white),
      onTap: _showCountryMultiSelect);

  Widget _buildDateStep() => Column(
        children: [
          ListTile(
            title: Text(
              _dateStart == null
                  ? 'Seleccione fecha de inicio'
                  : 'Inicio: ${_dateStart!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.calendar_today, color: Colors.white),
            onTap: () => _selectDate(context, true),
          ),
          ListTile(
            title: Text(
              _dateEnd == null
                  ? 'Seleccione fecha de finalización'
                  : 'Fin: ${_dateEnd!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.calendar_today, color: Colors.white),
            onTap: () => _selectDate(context, false),
          )
        ],
      );

  Widget _buildBudgetStep() => Column(children: [
        _buildCurrencyTextField(
            _maxLimitController, 'Límite Máximo', _maxLimitTouched, () {
          setState(() {
            _maxLimitTouched = true;
          });
        }),
        _buildCurrencyTextField(
            _desiredLimitController, 'Límite Deseado', _desiredLimitTouched,
            () {
          setState(() {
            _desiredLimitTouched = true;
          });
        }),
        _buildCurrencyTextField(
            _accumulatedController, 'Acumulado', _accumulatedTouched, () {
          setState(() {
            _accumulatedTouched = true;
          });
        }),
        CheckboxListTile(
          title:
              Text('¿Aumentar límite?', style: TextStyle(color: Colors.white)),
          value: _limitIncrease,
          onChanged: (bool? value) {
            setState(() {
              _limitIncrease = value ?? false;
            });
          },
          activeColor: Colors.white,
          checkColor: Colors.black,
        )
      ]);

  Widget _buildCurrencyTextField(TextEditingController controller, String label,
      bool touchedFlag, Function() onTouched) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}$')), // Solo permite hasta 2 decimales
      ],
      onChanged: (value) {
        if (!touchedFlag) {
          onTouched(); // Marca el campo como interactuado
        }
      },
      validator: (value) {
        if (touchedFlag && (value == null || value.isEmpty)) {
          return 'Campo obligatorio';
        }
        if (touchedFlag && !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value!)) {
          return 'Ingrese un valor numérico válido con hasta 2 decimales';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Campo obligatorio';
        }
        return null;
      },
    );
  }
}
