import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:travify/constants/images.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/notifiers/trip_notifier.dart';
import 'package:travify/services/country_service.dart';
import 'package:travify/services/currency_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CreateOrEditTravelWizard extends StatefulWidget {
  final Trip? trip;

  const CreateOrEditTravelWizard({super.key, this.trip});

  @override
  // ignore: library_private_types_in_public_api
  _CreateOrEditTravelWizardState createState() =>
      _CreateOrEditTravelWizardState();
}

class _CreateOrEditTravelWizardState extends State<CreateOrEditTravelWizard> {
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  final CountryService _countryService = CountryService();
  final CurrencyService _currencyService = CurrencyService();
  late TripNotifier _tripNotifier;

  // Paso 0: Información general
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImageFile;

  // Paso 1: Selección de países
  List<Country> _allCountries = [];
  List<Country> _selectedCountries = [];
  List<Currency> _allCurrencies = [];
  Currency? _selectedCurrency;

  // Paso 2: Fechas del viaje
  DateTime? _dateStart;
  DateTime? _dateEnd;

  // Paso 3: Presupuesto
  final TextEditingController _maxLimitController = TextEditingController();
  final TextEditingController _desiredLimitController = TextEditingController();
  bool _maxLimitTouched = false;
  bool _desiredLimitTouched = false;
  bool _limitIncrease = false;

  @override
  void initState() {
    super.initState();
    _loadCountries().then((_) {
      if (widget.trip != null) {
        _loadTripData(widget.trip!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tripNotifier = Provider.of<TripNotifier>(context, listen: false);
  }

  void _loadTripData(Trip trip) async {
    setState(() {
      _titleController.text = trip.title;
      _descriptionController.text = trip.description ?? '';
      _destinationController.text = trip.destination;
      _dateStart = trip.dateStart;
      _dateEnd = trip.dateEnd;
      _selectedCountries = trip.countries;
      _maxLimitController.text = trip.budget.maxLimit.toString();
      _desiredLimitController.text = trip.budget.desiredLimit.toString();
      _limitIncrease = trip.budget.limitIncrease;
    });

    if (trip.image != null &&
        trip.image!.isNotEmpty &&
        !trip.image!.startsWith('http')) {
      File localFile = File(trip.image!);
      if (await localFile.exists()) {
        setState(() {
          _pickedImageFile = localFile;
        });
      }
    }

    await _loadCurrencies(trip.countries.map((c) => c.id).toList());
    if (_allCurrencies.isNotEmpty) {
      setState(() {
        _selectedCurrency =
            _allCurrencies.firstWhere((c) => c.id == trip.currency.id);
      });
    }
  }

  Future<void> _loadCountries() async {
    List<Country> countries = await _countryService.getAllCountries();
    setState(() {
      _allCountries = countries;
    });
  }

  Future<void> _loadCurrencies(List<int> ids) async {
    List<Currency> currencies =
        (await _currencyService.getAllCurrencies()).reversed.toList();
    setState(() {
      _allCurrencies = currencies;
      _selectedCurrency = currencies.isNotEmpty ? currencies.first : null;
    });
  }

  Future<void> _saveTrip(Trip trip) async {
    if (trip.dateEnd != null) {
      bool tripExistsWithDate = await _tripNotifier.tripExistsWithDateNotNull(
        trip.dateStart,
        excludeTripId: trip.id != 0 ? trip.id : null,
      );

      if (tripExistsWithDate) {
        _showSnackBar("travel_exists_to_this_init_date".tr());
        return;
      }

      bool conflict = await _tripNotifier.tripExists(
        trip.dateStart,
        trip.dateEnd!,
        excludeTripId: trip.id != 0 ? trip.id : null,
      );
      if (conflict) {
        _showSnackBar("travel_exixts_with_dates".tr());
        return;
      }
    } else {
      bool tripExistsWithDate = await _tripNotifier.tripExistsWithDate(
        trip.dateStart,
        excludeTripId: trip.id != 0 ? trip.id : null,
      );

      if (tripExistsWithDate) {
        _showSnackBar("travel_exists_to_this_init_date".tr());
        return;
      }
    }

    if (trip.id == 0) {
      await _tripNotifier.addTrip(trip);
    } else {
      await _tripNotifier.updateTrip(trip);
    }

    if (mounted) Navigator.pop(context, trip);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedImage != null) {
      final savedImage = await _saveImageLocally(File(pickedImage.path));
      setState(() {
        _pickedImageFile = savedImage;
      });
    }
  }

  Future<File> _saveImageLocally(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        'trip_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final savedImage = await image.copy('${appDir.path}/$fileName');
    return savedImage;
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
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            List<Country> filteredCountries = _allCountries
                .where((country) => country.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: Text(
                "select_countries".tr(),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "countries".tr(),
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          Country country = filteredCountries[index];
                          return CheckboxListTile(
                            title: Text(
                              country.name,
                              style: TextStyle(color: Colors.white),
                            ),
                            value: tempSelected.any((c) => c.id == country.id),
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                            onChanged: (bool? selected) {
                              setStateDialog(() {
                                if (selected == true) {
                                  tempSelected.add(country);
                                } else {
                                  tempSelected
                                      .removeWhere((c) => c.id == country.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("cancel".tr(),
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCountries = tempSelected;
                      _loadCurrencies(tempSelected.map((c) => c.id).toList());
                    });
                    Navigator.pop(context);
                  },
                  child: Text("accept".tr(),
                      style: TextStyle(color: Colors.white)),
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
          _showSnackBar("complete_info_fields".tr());
          hasStepError = true;
        }
        break;

      case 1:
        if (_selectedCountries.isEmpty) {
          _showSnackBar("select_a_country_at_least".tr());
          hasStepError = true;
        }
        break;

      case 2:
        if (_dateStart == null) {
          _showSnackBar("select_init_date".tr());
          hasStepError = true;
        } else if (_dateEnd != null && _dateEnd!.isBefore(_dateStart!)) {
          _showSnackBar("date_before_not_ok".tr());
          hasStepError = true;
        } else if (DateTime(
                    _dateStart!.year, _dateStart!.month, _dateStart!.day)
                .isBefore(DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)) &&
            widget.trip == null) {
          _showSnackBar("date_before_today".tr());
          hasStepError = true;
        }
        break;

      case 3:
        if (_maxLimitController.text.isEmpty ||
            _desiredLimitController.text.isEmpty) {
          _showSnackBar("budget_complete".tr());
          hasStepError = true;
        } else if (!RegExp(r'^\d+(\.\d{1,2})?$')
            .hasMatch(_maxLimitController.text)) {
          _showSnackBar("valid_number_two_decimal".tr());
          hasStepError = true;
        } else if (_maxLimitController.text.isNotEmpty &&
            double.parse(_maxLimitController.text) <
                double.parse(_desiredLimitController.text)) {
          _showSnackBar("error_limits".tr());
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
        id: widget.trip?.budget.id ?? 0,
        maxLimit: double.tryParse(_maxLimitController.text) ?? 0.0,
        desiredLimit: double.tryParse(_desiredLimitController.text) ?? 0.0,
        accumulated: 0.0,
        limitIncrease: _limitIncrease,
      );

      Trip trip = Trip(
        id: widget.trip?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        dateStart: _dateStart ?? DateTime.now(),
        dateEnd: _dateEnd,
        destination: _destinationController.text,
        image: _pickedImageFile?.path,
        open: true,
        budget: budget,
        currency: _selectedCurrency!,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            widget.trip != null ? 'edit_travel'.tr() : 'create_new_travel'.tr(),
            style: TextStyle(fontSize: 19),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Colors.white,
                    secondary: Colors.white,
                  ),
            ),
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: [
                Step(
                    title: Text('information'.tr(),
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 0,
                    content: _buildInfoStep()),
                Step(
                    title: Text('countries'.tr(),
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 1,
                    content: _buildCountryStep()),
                Step(
                    title: Text('dates'.tr(),
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 2,
                    content: _buildDateStep()),
                Step(
                    title: Text('budget'.tr(),
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 3,
                    content: _buildBudgetStep()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_titleController, 'title'.tr(), isRequired: true),
          _buildTextField(_descriptionController, 'description'.tr(),
              isRequired: true),
          _buildTextField(_destinationController, 'destiny'.tr(),
              isRequired: true),
          const SizedBox(height: 20),
          Text('trip_photo'.tr(), style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[800],
                ),
                child: _pickedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_pickedImageFile!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.add_photo_alternate,
                        color: Colors.white70, size: 50),
              ),
            ),
          ),
        ],
      );

  Widget _buildCountryStep() => ListTile(
      title: Text(
          _selectedCountries.isEmpty
              ? 'select_countries'.tr()
              : '${'countries'.tr()}: ${_selectedCountries.map((c) => c.name).join(', ')}',
          style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_drop_down, color: Colors.white),
      onTap: _showCountryMultiSelect);

  Widget _buildDateStep() => Column(
        children: [
          ListTile(
            title: Text(
              _dateStart == null
                  ? 'select_start_date'.tr()
                  : '${'init'.tr()}: ${_dateStart!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.calendar_today, color: Colors.white),
            onTap: () => _selectDate(context, true),
          ),
          Row(
            children: [
              if (_dateEnd != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _dateEnd = null;
                    });
                  },
                  icon: Icon(Icons.clear, color: Colors.white),
                  tooltip: 'clear'.tr(),
                ),
              Expanded(
                child: ListTile(
                  title: Text(
                    _dateEnd == null
                        ? 'select_end_date'.tr()
                        : '${'end'.tr()}: ${_dateEnd!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white),
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildBudgetStep() => Column(children: [
        DropdownSearch<Currency>(
          popupProps: PopupProps.dialog(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'search_currency'.tr(),
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            dialogProps: DialogProps(
              backgroundColor: Colors.grey[850],
            ),
            itemBuilder: (context, currency, isSelected) => ListTile(
              title: Text('${currency.symbol} - ${currency.name}',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: "default_currency".tr(),
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          selectedItem: _selectedCurrency,
          items: _allCurrencies,
          itemAsString: (Currency c) => '${c.symbol} - ${c.name}',
          onChanged: (Currency? currency) {
            setState(() {
              _selectedCurrency = currency;
            });
          },
          validator: (Currency? value) {
            if (_allCurrencies.isNotEmpty && value == null) {
              return 'select_currency'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 5),
        _buildCurrencyTextField(
          _maxLimitController,
          'max_limit'.tr(),
          _maxLimitTouched,
          () => setState(() => _maxLimitTouched = true),
        ),
        _buildCurrencyTextField(
          _desiredLimitController,
          'desired_limit'.tr(),
          _desiredLimitTouched,
          () => setState(() => _desiredLimitTouched = true),
        ),
        CheckboxListTile(
          title: Text('lock_limit'.tr(), style: TextStyle(color: Colors.white)),
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
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
      ],
      onChanged: (value) {
        if (!touchedFlag) {
          onTouched(); // Marca el campo como interactuado
        }
      },
      validator: (value) {
        if (touchedFlag && (value == null || value.isEmpty)) {
          return 'required_field'.tr();
        }
        if (touchedFlag && !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value!)) {
          return 'valid_number_two_decimal'.tr();
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
      inputFormatters: [
        LengthLimitingTextInputFormatter(40),
      ],
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'required_field'.tr();
        }
        return null;
      },
    );
  }
}
