import 'package:equatable/equatable.dart';

abstract class HomeBatteriesEvent extends Equatable {
  const HomeBatteriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeBatteries extends HomeBatteriesEvent {
  const LoadHomeBatteries();
}
