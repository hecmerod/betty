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
    final generation = ++_watchGeneration;
    final previous = _subscription;
    _subscription = null;
    if (previous != null) unawaited(previous.cancel());
    if (emit.isDone || generation != _watchGeneration) return;

    emit(state.copyWith(isLoading: true));

    try {
      final readings = await _batteriesPort.readAllBatteries();
      if (emit.isDone || generation != _watchGeneration) return;
      emit(state.copyWith(readings: _sorted(readings), isLoading: false));
    } catch (_) {
      if (emit.isDone || generation != _watchGeneration) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error al cargar las baterías',
        ),
      );
    }

    if (emit.isDone || generation != _watchGeneration) return;
    try {
      _subscription = _batteriesPort.streamAllBatteries().listen(
        (reading) {
          if (!isClosed) add(BatteryReadingUpdated(reading));
        },
        onError: (Object _, StackTrace _) {
          if (!isClosed) add(const BatteriesStreamFailed());
        },
      );
    } catch (_) {
      if (emit.isDone || generation != _watchGeneration) return;
      if (state.errorMessage != null) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error al escuchar las baterías',
        ),
      );
    }
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
    _subscription?.cancel();
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
