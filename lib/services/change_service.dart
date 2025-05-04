import 'package:easy_localization/easy_localization.dart';
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/database/dao/rate_dao.dart';
import 'package:travify/database/dao/transaction_dao.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/rate.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/screens/forms/form_change.dart';

class ChangeService {
  final rateDao = RateDao();
  final currencyDao = CurrencyDao();
  final transactioDao = TransactionDao();

  List<Map<String, dynamic>> historicalMap = [];
  Map<String, double> ratesMap = {};

  Future<List<Change>> getAllChanges() async {
    return await transactioDao.getAllChanges();
  }

  Future<void> getOfficialRatesAsMap() async {
    final List<Rate> rates = await rateDao.getRatesFromCurrency('EUR');
    final Map<String, double> fixedMap = {};

    for (final rate in rates) {
      fixedMap[rate.currencyTo.code] = rate.rate;
    }

    fixedMap['EUR'] = 1.0;
    ratesMap = fixedMap;
  }

  void changesToHistoricData(List<Change> changes) {
    historicalMap.clear();
    for (final change in changes) {
      historicalMap.add({
        "from": change.currencySpent.code,
        "amount_from": change.amount,
        "commission": change.commission,
        "to": change.currencyRecived.code,
        "amount_to": change.amountRecived
      });
    }
  }

  Map<String, double> calcularTasasEfectivasMedias(
      List<Map<String, dynamic>> historicData) {
    final Map<String, List<double>> acumulador = {};

    for (final row in historicData) {
      final String origen = row["from"];
      final String destino = row["to"];
      final double amtFrom = (row["amount_from"] as num).toDouble();
      final double commission = (row["commission"] as num).toDouble();
      final double amtTo = (row["amount_to"] as num).toDouble();

      final double montoNeto = amtFrom * (1 - commission);
      final double tasaEfectiva = amtTo / montoNeto;

      final String key = '$origen-$destino';
      acumulador.putIfAbsent(key, () => []);
      acumulador[key]!.add(tasaEfectiva);
    }

    final Map<String, double> tasasEfectivas = {};
    acumulador.forEach((key, listaTasas) {
      final double promedio =
          listaTasas.reduce((a, b) => a + b) / listaTasas.length;
      tasasEfectivas[key] = promedio;
    });

    return tasasEfectivas;
  }

  Map<String, double> calcularComisionMedia(
    List<Map<String, dynamic>> historicData, {
    double? userCommission,
    String? origenUsuario,
    String? destinoUsuario,
  }) {
    final Map<String, List<double>> acumulador = {};

    for (final row in historicData) {
      final String origen = row["from"];
      final String destino = row["to"];
      final double comision = (row["commission"] as num).toDouble();

      final String key = '$origen-$destino';
      acumulador.putIfAbsent(key, () => []);
      acumulador[key]!.add(comision);
    }

    // se agrega la comision del usuario
    if (userCommission != null &&
        origenUsuario != null &&
        destinoUsuario != null) {
      final String userKey = '$origenUsuario-$destinoUsuario';
      acumulador.putIfAbsent(userKey, () => []);
      acumulador[userKey]!.add(userCommission);
    }

    // promedios
    final Map<String, double> comisionesMedias = {};
    acumulador.forEach((key, listaComisiones) {
      final promedio =
          listaComisiones.reduce((a, b) => a + b) / listaComisiones.length;
      comisionesMedias[key] = promedio;
    });

    return comisionesMedias;
  }

  double? getRateFromEUR(Map<String, double> rates, String currencyCode) {
    return rates[currencyCode] ?? (currencyCode == 'EUR' ? 1.0 : null);
  }

  Map<String, Map<String, double>> construirGrafoPriorizandoReal(
    Map<String, double> tasasEfectivasMedias,
    Map<String, double> officialRatesFromEUR,
    Map<String, double> comisionesMedias, {
    double? userCommission,
    String? origenUsuario,
    String? destinoUsuario,
    double comisionDefecto = 0.02,
  }) {
    final monedas = Set<String>.from(officialRatesFromEUR.keys);
    monedas.add('EUR');

    final grafo = <String, Map<String, double>>{};

    for (final from in monedas) {
      for (final to in monedas) {
        if (from == to) continue;

        final key = '$from-$to';
        final invKey = '$to-$from';

        grafo.putIfAbsent(from, () => {});

        double comision = (from == origenUsuario &&
                to == destinoUsuario &&
                userCommission != null)
            ? userCommission
            : comisionesMedias[key] ??
                comisionesMedias[invKey] ??
                comisionDefecto;

        if (tasasEfectivasMedias.containsKey(key)) {
          final tasaReal = tasasEfectivasMedias[key]!;
          final netRate = tasaReal * (1 - comision);
          grafo[from]![to] = netRate;
          continue;
        }

        final fromRate = getRateFromEUR(officialRatesFromEUR, from);
        final toRate = getRateFromEUR(officialRatesFromEUR, to);

        if (fromRate != null && toRate != null) {
          final baseRate = toRate / fromRate;
          final netRate = baseRate * (1 - comision);
          grafo[from]![to] = netRate;
        }
      }
    }

    return grafo;
  }

  List<(double, List<String>)> enumerarRutasCambio(
    Map<String, Map<String, double>> grafo,
    String monedaActual,
    String monedaDestino,
    double montoActual, {
    Set<String>? visitadas,
    int profundidadMax = 3,
    int profundidadActual = 0,
  }) {
    visitadas ??= <String>{};

    if (profundidadActual > profundidadMax) return [];

    if (monedaActual == monedaDestino) {
      return [
        (montoActual, [monedaDestino])
      ];
    }

    final resultados = <(double, List<String>)>[];
    final visitadasLocal = {...visitadas, monedaActual};

    final vecinos = grafo[monedaActual];
    if (vecinos == null) return resultados;

    for (final entry in vecinos.entries) {
      final nextMoneda = entry.key;
      final factor = entry.value;

      if (!visitadasLocal.contains(nextMoneda)) {
        final nuevoMonto = montoActual * factor;
        final subRutas = enumerarRutasCambio(
          grafo,
          nextMoneda,
          monedaDestino,
          nuevoMonto,
          visitadas: visitadasLocal,
          profundidadMax: profundidadMax,
          profundidadActual: profundidadActual + 1,
        );

        for (final subRuta in subRutas) {
          resultados.add((subRuta.$1, [monedaActual, ...subRuta.$2]));
        }
      }
    }

    return resultados;
  }

  Future<List<Change>> confirmChange(
      List<String>? optimalRoute,
      String? fromCode,
      String? toCode,
      double initialAmount,
      double commissionInput,
      List<Change> changes,
      RouteOption? selectedOption,
      Trip trip) async {
    List<Change> changesToSave = [];

    double currentAmount = initialAmount;

    if (optimalRoute != null) {
      if (selectedOption == RouteOption.direct) {
        final result = await initChange(
          changes,
          fromCode!,
          toCode!,
          commissionInput,
          currentAmount,
        );

        final montoInicial = result['montoInicial'];
        final origen = result['origen'];
        final destino = result['destino'];
        final montoDirecto = result['montoDirecto'];

        if (montoDirecto != null) {
          currentAmount = montoDirecto;
        }

        Currency? fromCurrency = await currencyDao.getCurrencyByCode(fromCode);
        Currency? toCurrency = await currencyDao.getCurrencyByCode(toCode);

        Change newChange = Change(
          id: 0,
          tripId: trip.id,
          date: DateTime.now(),
          description: 'Cambio de $origen a $destino',
          amount: double.parse(montoInicial.toStringAsFixed(2)),
          currencyRecived: toCurrency,
          currencySpent: fromCurrency,
          commission: double.parse(commissionInput.toStringAsFixed(2)),
          amountRecived: double.parse(montoDirecto.toStringAsFixed(2)),
        );

        changesToSave.add(newChange);
      } else {
        for (int i = 0; i < optimalRoute.length - 1; i++) {
          final result = await initChange(
            changes,
            optimalRoute[i],
            optimalRoute[i + 1],
            commissionInput,
            currentAmount,
          );

          final montoInicial = result['montoInicial'];
          final origen = result['origen'];
          final destino = result['destino'];
          final montoDirecto = result['montoDirecto'];

          if (montoDirecto != null) {
            currentAmount = montoDirecto;
          }

          Currency? fromCurrency =
              await currencyDao.getCurrencyByCode(optimalRoute[i]);
          Currency? toCurrency =
              await currencyDao.getCurrencyByCode(optimalRoute[i + 1]);

          Change newChange = Change(
            id: 0,
            tripId: trip.id,
            date: DateTime.now(),
            description: 'Cambio de $origen a $destino',
            amount: double.parse(montoInicial.toStringAsFixed(2)),
            currencyRecived: toCurrency,
            currencySpent: fromCurrency,
            commission: double.parse(commissionInput.toStringAsFixed(2)),
            amountRecived: double.parse(montoDirecto.toStringAsFixed(2)),
          );
          // invertir el orden de changesToSave
          changesToSave.add(newChange);
        }
      }
    }
    return changesToSave;
  }

  Future<Map<String, dynamic>> initChange(
    List<Change> changes,
    String origenUsuario,
    String destinoUsuario,
    double userCommission,
    double amount,
  ) async {
    await getOfficialRatesAsMap();
    changesToHistoricData(changes);

    final tasasEfectivasMedias = calcularTasasEfectivasMedias(historicalMap);
    final comisionesMedias = calcularComisionMedia(
      historicalMap,
      userCommission: userCommission,
      origenUsuario: origenUsuario,
      destinoUsuario: destinoUsuario,
    );

    final cominsionPromedia =
        comisionesMedias['$origenUsuario-$destinoUsuario'] ??
            comisionesMedias['$destinoUsuario-$origenUsuario'] ??
            0.02;

    final grafo = construirGrafoPriorizandoReal(
      tasasEfectivasMedias,
      ratesMap,
      comisionesMedias,
      userCommission: userCommission,
      origenUsuario: origenUsuario,
      destinoUsuario: destinoUsuario,
    );

    final rutas = enumerarRutasCambio(
      grafo,
      origenUsuario,
      destinoUsuario,
      amount,
    );

    if (rutas.isEmpty) {
      return {'error': 'not_valid_path'.tr()};
    }

    rutas.sort((a, b) => b.$1.compareTo(a.$1));
    final top3 = rutas.take(3).toList();

    double? montoDirecto;
    if (grafo[origenUsuario]?.containsKey(destinoUsuario) ?? false) {
      montoDirecto = amount * grafo[origenUsuario]![destinoUsuario]!;
    }

    final mejorRuta = rutas.first;

    return {
      'montoInicial': amount,
      'origen': origenUsuario,
      'destino': destinoUsuario,
      'montoDirecto': montoDirecto,
      'top3': top3,
      'mejorRuta': mejorRuta,
      'comisionPromedia': cominsionPromedia,
    };
  }
}
