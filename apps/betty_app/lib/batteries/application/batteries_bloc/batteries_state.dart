import 'package:betty_app/batteries/domain/entities/battery_reading.dart';
import 'package:equatable/equatable.dart';

class BatteriesState extends Equatable {
  final List<BatteryReading> readings;
  final bool isLoading;
  final String? errorMessage;

  const BatteriesState({
    this.readings = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  BatteriesState copyWith({
    List<BatteryReading>? readings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BatteriesState(
      readings: readings ?? this.readings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [readings, isLoading, errorMessage];
}
