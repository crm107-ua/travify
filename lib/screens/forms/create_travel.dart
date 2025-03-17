import 'package:flutter/material.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/database/dao/country_dao.dart';

class CreateTravelWizard extends StatefulWidget {
  const CreateTravelWizard({Key? key}) : super(key: key);

  @override
  _CreateTravelWizardState createState() => _CreateTravelWizardState();
}

class _CreateTravelWizardState extends State<CreateTravelWizard> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

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
  bool _limitIncrease = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    List<Country> countries = await CountryDao().getCountries();
    setState(() {
      _allCountries = countries;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _destinationController.dispose();
    _imageController.dispose();
    _maxLimitController.dispose();
    _desiredLimitController.dispose();
    _accumulatedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? (_dateStart ?? initialDate) : (_dateEnd ?? initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
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

  // Muestra un diálogo para seleccionar múltiples países
  void _showCountryMultiSelect() async {
    // Se utiliza una copia temporal para mantener la selección
    List<Country> tempSelected = List.from(_selectedCountries);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Seleccione países"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _allCountries.length,
                itemBuilder: (context, index) {
                  Country country = _allCountries[index];
                  return CheckboxListTile(
                    title: Text(country
                        .name), // se asume que Country tiene la propiedad name
                    value: tempSelected.any((c) => c.id == country.id),
                    onChanged: (bool? selected) {
                      if (selected == true) {
                        setStateDialog(() {
                          tempSelected.add(country);
                        });
                      } else {
                        setStateDialog(() {
                          tempSelected.removeWhere((c) => c.id == country.id);
                        });
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCountries = tempSelected;
                  });
                  Navigator.pop(context);
                },
                child: Text("Aceptar"),
              ),
            ],
          );
        });
      },
    );
  }

  void _onStepContinue() {
    // Total de pasos = 4 (0 a 3)
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Validación personalizada para las fechas:
      if (_dateStart == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Por favor, seleccione la fecha de inicio")),
        );
        return;
      }
      if (_dateEnd != null && _dateEnd!.isBefore(_dateStart!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "La fecha de fin no puede ser anterior a la fecha de inicio"),
          ),
        );
        return;
      }
      // Si las fechas son válidas, se procede a validar el resto del formulario
      if (_formKey.currentState!.validate()) {
        Budget budget = Budget(
          id: 0, // Id temporal, cámbialo según tu lógica
          maxLimit: double.tryParse(_maxLimitController.text) ?? 0.0,
          desiredLimit: double.tryParse(_desiredLimitController.text) ?? 0.0,
          accumulated: double.tryParse(_accumulatedController.text) ?? 0.0,
          limitIncrease: _limitIncrease,
        );

        Trip trip = Trip(
          id: 0, // Id temporal
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

        // Aquí podrías guardar el viaje en la base de datos o ejecutar otra acción
        print(trip.toString());
        Navigator.pop(context);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Viaje'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          steps: [
            // Paso 0: Información general
            Step(
              title: Text('Información'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese un título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                  TextFormField(
                    controller: _destinationController,
                    decoration: InputDecoration(labelText: 'Destino'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese un destino';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(
                        labelText: 'URL de la imagen (opcional)'),
                  ),
                ],
              ),
            ),
            // Paso 1: Selección de países
            Step(
              title: Text('Países'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(_selectedCountries.isEmpty
                        ? 'Seleccione países'
                        : 'Países: ${_selectedCountries.map((c) => c.name).join(', ')}'),
                    trailing: Icon(Icons.arrow_drop_down),
                    onTap: _showCountryMultiSelect,
                  ),
                ],
              ),
            ),
            // Paso 2: Fechas del viaje
            Step(
              title: Text('Fechas'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  ListTile(
                    title: Text(_dateStart == null
                        ? 'Seleccione fecha de inicio'
                        : 'Inicio: ${_dateStart!.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    title: Text(_dateEnd == null
                        ? 'Seleccione fecha de finalización'
                        : 'Fin: ${_dateEnd!.toLocal().toString().split(' ')[0]}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ],
              ),
            ),
            // Paso 3: Presupuesto
            Step(
              title: Text('Presupuesto'),
              isActive: _currentStep >= 3,
              state: _currentStep == 3 ? StepState.editing : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _maxLimitController,
                    decoration: InputDecoration(labelText: 'Límite Máximo'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el límite máximo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _desiredLimitController,
                    decoration: InputDecoration(labelText: 'Límite Deseado'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el límite deseado';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _accumulatedController,
                    decoration: InputDecoration(labelText: 'Acumulado'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  SwitchListTile(
                    title: Text('Permitir incremento de límite'),
                    value: _limitIncrease,
                    onChanged: (value) {
                      setState(() {
                        _limitIncrease = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
