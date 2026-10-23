import 'package:equatable/equatable.dart';

class HomeBatteriesState extends Equatable {
  final int? chargePercent;
  final bool isCharging;

  const HomeBatteriesState({this.chargePercent, this.isCharging = false});

  @override
  List<Object?> get props => [chargePercent, isCharging];
}
