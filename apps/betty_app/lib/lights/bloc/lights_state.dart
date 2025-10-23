import 'package:equatable/equatable.dart';

class LightsState extends Equatable {
  final int currentPage;
  final bool shouldAnimate;

  // Exterior lights
  final bool headlightsOn;
  final bool rearLightsOn;
  final bool emergencyLightsOn;
  final bool fogLightsOn;

  // Interior lights
  final bool ceilingLightsOn;
  final bool readingLightsOn;
  final bool ambientLightsOn;
  final bool workLightsOn;

  const LightsState({
    this.currentPage = 0,
    this.shouldAnimate = false,
    this.headlightsOn = false,
    this.rearLightsOn = false,
    this.emergencyLightsOn = false,
    this.fogLightsOn = false,
    this.ceilingLightsOn = false,
    this.readingLightsOn = false,
    this.ambientLightsOn = false,
    this.workLightsOn = false,
  });

  LightsState copyWith({
    int? currentPage,
    bool? shouldAnimate,
    bool? headlightsOn,
    bool? rearLightsOn,
    bool? emergencyLightsOn,
    bool? fogLightsOn,
    bool? ceilingLightsOn,
    bool? readingLightsOn,
    bool? ambientLightsOn,
    bool? workLightsOn,
  }) {
    return LightsState(
      currentPage: currentPage ?? this.currentPage,
      shouldAnimate: shouldAnimate ?? this.shouldAnimate,
      headlightsOn: headlightsOn ?? this.headlightsOn,
      rearLightsOn: rearLightsOn ?? this.rearLightsOn,
      emergencyLightsOn: emergencyLightsOn ?? this.emergencyLightsOn,
      fogLightsOn: fogLightsOn ?? this.fogLightsOn,
      ceilingLightsOn: ceilingLightsOn ?? this.ceilingLightsOn,
      readingLightsOn: readingLightsOn ?? this.readingLightsOn,
      ambientLightsOn: ambientLightsOn ?? this.ambientLightsOn,
      workLightsOn: workLightsOn ?? this.workLightsOn,
    );
  }

  @override
  List<Object?> get props => [
    currentPage,
    shouldAnimate,
    headlightsOn,
    rearLightsOn,
    emergencyLightsOn,
    fogLightsOn,
    ceilingLightsOn,
    readingLightsOn,
    ambientLightsOn,
    workLightsOn,
  ];
}
