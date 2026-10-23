import 'dart:convert';

import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/shared/services/api_service.dart';

class BatteriesAdapter implements BatteriesPort {
  BatteriesAdapter({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  static const _sseHeaders = {
    'Accept': 'text/event-stream',
    'Cache-Control': 'no-cache',
  };

  @override
  Future<List<BatteryReading>> readAllBatteries() async {
    final response = await _apiService.get('/batteries');

    if (response.statusCode != 200) {
      throw Exception('Error al obtener las baterías');
    }

    try {
      final data = json.decode(response.body);
      if (data is! List) {
        throw Exception('Error al obtener las baterías');
      }

      return data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Error al obtener las baterías');
        }
        return _batteryReadingFromJson(item);
      }).toList();
    } on FormatException {
      throw Exception('Error al obtener las baterías');
    }
  }

  @override
  Future<BatteryReading> readBattery(int batteryId) async {
    final response = await _apiService.get('/batteries/$batteryId');

    if (response.statusCode != 200) {
      throw Exception('Error al obtener la batería $batteryId');
    }

    try {
      final data = json.decode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception('Error al obtener la batería $batteryId');
      }

      return _batteryReadingFromJson(data);
    } on FormatException {
      throw Exception('Error al obtener la batería $batteryId');
    }
  }

  @override
  Stream<BatteryReading> streamAllBatteries() {
    return _streamReadings(
      '/batteries/stream',
      'Error al escuchar las baterías',
    );
  }

  @override
  Stream<BatteryReading> streamBattery(int batteryId) {
    return _streamReadings(
      '/batteries/$batteryId/stream',
      'Error al escuchar la batería $batteryId',
    );
  }

  Stream<BatteryReading> _streamReadings(
    String endpoint,
    String errorMessage,
  ) async* {
    final decoder = _SseDecoder();

    try {
      await for (final chunk
          in _apiService
              .getStream(endpoint, headers: _sseHeaders)
              .transform(utf8.decoder)) {
        for (final event in decoder.add(chunk)) {
          final data = _sseData(event);
          if (data == null || data.isEmpty) continue;

          final decoded = json.decode(data);
          if (decoded is! Map<String, dynamic>) {
            throw Exception(errorMessage);
          }
          yield _batteryReadingFromJson(decoded);
        }
      }
    } on ApiException {
      throw Exception(errorMessage);
    } on FormatException {
      throw Exception(errorMessage);
    }
  }
}

class _SseDecoder {
  String _buffer = '';

  List<String> add(String chunk) {
    _buffer = (_buffer + chunk).replaceAll('\r\n', '\n');
    final events = <String>[];

    while (true) {
      final separator = _buffer.indexOf('\n\n');
      if (separator == -1) break;
      events.add(_buffer.substring(0, separator));
      _buffer = _buffer.substring(separator + 2);
    }

    return events;
  }
}

String? _sseData(String event) {
  final dataLines = <String>[];

  for (final line in event.split('\n')) {
    if (!line.startsWith('data:')) continue;
    final value = line.substring(5);
    dataLines.add(value.startsWith(' ') ? value.substring(1) : value);
  }

  if (dataLines.isEmpty) return null;
  return dataLines.join('\n');
}

BatteryReading _batteryReadingFromJson(Map<String, dynamic> json) {
  return BatteryReading(
    deviceAddress: _asString(json['deviceAddress']),
    batteryId: _asInt(json['batteryId']),
    totalVoltage: _asDouble(json['totalVoltage']),
    current: _asDouble(json['current']),
    remainingCapacity: _asDouble(json['remainingCapacity']),
    nominalCapacity: _asDouble(json['nominalCapacity']),
    cycles: _asInt(json['cycles']),
    productionDate: _asString(json['productionDate']),
    balanceStatus: _asIntList(json['balanceStatus']),
    protectionStatus: _asInt(json['protectionStatus']),
    softwareVersion: _asInt(json['softwareVersion']),
    stateOfCharge: _asInt(json['stateOfCharge']),
    mosfetStatus: _asInt(json['mosfetStatus']),
    cellCount: _asInt(json['cellCount']),
    ntcCount: _asInt(json['ntcCount']),
    temperatures: _asDoubleList(json['temperatures']),
    cellVoltages: _asDoubleList(json['cellVoltages']),
    averageCellVoltage: _asDouble(json['averageCellVoltage']),
    minCellVoltage: _asDouble(json['minCellVoltage']),
    maxCellVoltage: _asDouble(json['maxCellVoltage']),
    voltageDifference: _asDouble(json['voltageDifference']),
    averageTemperature: _asDouble(json['averageTemperature']),
    isBalanced: _asBool(json['isBalanced']),
    isCharging: _asBool(json['isCharging']),
    isDischarging: _asBool(json['isDischarging']),
    timestamp: _asDateTime(json['timestamp']),
  );
}

String _asString(Object? value) {
  if (value is String) return value;
  throw const FormatException('Texto inválido');
}

int _asInt(Object? value) {
  if (value is num) return value.toInt();
  throw const FormatException('Valor numérico inválido');
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw const FormatException('Valor numérico inválido');
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  throw const FormatException('Valor booleano inválido');
}

DateTime _asDateTime(Object? value) {
  if (value is String) return DateTime.parse(value);
  throw const FormatException('Fecha inválida');
}

List<int> _asIntList(Object? value) {
  if (value is! List) throw const FormatException('Lista inválida');
  return value.map(_asInt).toList();
}

List<double> _asDoubleList(Object? value) {
  if (value is! List) throw const FormatException('Lista inválida');
  return value.map(_asDouble).toList();
}
