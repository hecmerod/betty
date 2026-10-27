import 'dart:async';

import 'package:betty_app/batteries/application/batteries_bloc/batteries_event.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_state.dart';
import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteriesBloc extends Bloc<BatteriesEvent, BatteriesState> {
  final BatteriesPort _batteriesPort;
  StreamSubscription<BatteryReading>? _subscription;
  int _watchGeneration = 0;
  bool _streamOpen = false;
  bool _watchInFlight = false;

  BatteriesBloc({required BatteriesPort batteriesPort})
    : _batteriesPort = batteriesPort,
      super(const BatteriesState()) {
    on<WatchBatteries>(_onWatchBatteries);
    on<BatteryReadingUpdated>(_onBatteryReadingUpdated);
    on<BatteriesStreamFailed>(_onBatteriesStreamFailed);
  }

  Future<void> _onWatchBatteries(
    WatchBatteries event,
    Emitter<BatteriesState> emit,
  ) async {
    // Reopening the page must not drop a stream that is already open.
    if (!event.force && (_streamOpen || _watchInFlight)) return;

    final generation = ++_watchGeneration;
    _watchInFlight = true;
    _streamOpen = false;
    final previous = _subscription;
    _subscription = null;
    if (previous != null) unawaited(previous.cancel());
    if (!_isCurrent(emit, generation)) return;

    emit(state.copyWith(isLoading: true));

    try {
      final readings = await _batteriesPort.readAllBatteries();
      if (!_isCurrent(emit, generation)) return;
      emit(state.copyWith(readings: _sorted(readings), isLoading: false));
    } catch (_) {
      if (!_isCurrent(emit, generation)) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error al cargar las baterías',
        ),
      );
    }

    if (!_isCurrent(emit, generation)) return;
    try {
      _subscription = _batteriesPort.streamAllBatteries().listen(
        (reading) {
          if (!isClosed && generation == _watchGeneration) {
            add(BatteryReadingUpdated(reading));
          }
        },
        onError: (Object _, StackTrace _) {
          _onStreamClosed(generation);
          if (!isClosed && generation == _watchGeneration) {
            add(const BatteriesStreamFailed());
          }
        },
        onDone: () => _onStreamClosed(generation),
      );
    } catch (_) {
      if (!_isCurrent(emit, generation)) return;
      _watchInFlight = false;
      _streamOpen = false;
      if (state.errorMessage != null) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error al escuchar las baterías',
        ),
      );
      return;
    }

    if (!_isCurrent(emit, generation) || _subscription == null) return;
    _streamOpen = true;
    _watchInFlight = false;
  }

  bool _isCurrent(Emitter<BatteriesState> emit, int generation) {
    return !emit.isDone && generation == _watchGeneration;
  }

  void _onStreamClosed(int generation) {
    if (generation != _watchGeneration) return;
    _streamOpen = false;
    _watchInFlight = false;
    _subscription = null;
  }

  void _onBatteryReadingUpdated(
    BatteryReadingUpdated event,
    Emitter<BatteriesState> emit,
  ) {
    emit(
      state.copyWith(
        readings: _upsert(state.readings, event.reading),
        isLoading: false,
      ),
    );
  }

  void _onBatteriesStreamFailed(
    BatteriesStreamFailed event,
    Emitter<BatteriesState> emit,
  ) {
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: 'Error al escuchar las baterías',
      ),
    );
  }

  @override
  Future<void> close() {
    _watchGeneration++;
    _streamOpen = false;
    _watchInFlight = false;
    final subscription = _subscription;
    _subscription = null;
    subscription?.cancel();
    return super.close();
  }
}

List<BatteryReading> _sorted(List<BatteryReading> readings) {
  final next = [...readings]
    ..sort((a, b) => a.batteryId.compareTo(b.batteryId));
  return next;
}

List<BatteryReading> _upsert(
  List<BatteryReading> readings,
  BatteryReading reading,
) {
  final next = [...readings];
  final index = next.indexWhere((item) => item.batteryId == reading.batteryId);
  if (index == -1) {
    next.add(reading);
  } else {
    next[index] = reading;
  }
  next.sort((a, b) => a.batteryId.compareTo(b.batteryId));
  return next;
}
