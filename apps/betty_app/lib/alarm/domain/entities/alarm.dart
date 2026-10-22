import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final bool isActive;
  final String password;

  const Alarm({this.isActive = false, this.password = ''});

  Alarm copyWith({bool? isActive, String? password}) {
    return Alarm(
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [isActive, password];
}
