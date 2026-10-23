import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_bloc_helper.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_event.dart';
import 'package:betty_app/home/application/home_batteries_bloc/home_batteries_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBatteriesBloc extends Bloc<HomeBatteriesEvent, HomeBatteriesState> {
  final BatteriesPort _batteriesPort;

  HomeBatteriesBloc({required BatteriesPort batteriesPort})
    : _batteriesPort = batteriesPort,
      super(const HomeBatteriesState()) {
    on<LoadHomeBatteries>(_onLoadHomeBatteries);
  }

  Future<void> _onLoadHomeBatteries(LoadHomeBatteries event, Emitter<HomeBatteriesState> emit) async {
    final readings = await _batteriesPort.readAllBatteries();
    emit(
      HomeBatteriesState(
        chargePercent: combinedChargePercent(readings),
        isCharging: readings.any((reading) => reading.isCharging),
      ),
    );
  }
}
