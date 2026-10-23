import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:equatable/equatable.dart';

abstract class BatteriesEvent extends Equatable {
  const BatteriesEvent();

  @override
  List<Object?> get props => [];
}

class WatchBatteries extends BatteriesEvent {
  const WatchBatteries();
}

class BatteryReadingUpdated extends BatteriesEvent {
  final BatteryReading reading;

  const BatteryReadingUpdated(this.reading);

  @override
  List<Object?> get props => [reading];
}

class BatteriesStreamFailed extends BatteriesEvent {
  const BatteriesStreamFailed();
}
