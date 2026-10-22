import 'package:betty_app/alarm/application/alarm_bloc/alarm_bloc.dart';
import 'package:betty_app/alarm/application/alarm_bloc/alarm_event.dart';
import 'package:betty_app/alarm/domain/camera_type.dart';
import 'package:betty_app/alarm/domain/ports/alarm_port.dart';
import 'package:betty_app/alarm/domain/ports/sensor_port.dart';
import 'package:betty_app/alarm/presentation/camera/widgets/video_stream_widget.dart';
import 'package:betty_app/alarm/presentation/widgets/alarm_main_button.dart';
import 'package:betty_app/alarm/presentation/widgets/sensor_list.dart';
import 'package:betty_app/alarm/presentation/widgets/sensor_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlarmBloc(alarmPort: context.read<AlarmPort>(), sensorPort: context.read<SensorPort>())
        ..add(const LoadAlarmStatus())
        ..add(const LoadAlarmPassword())
        ..add(const LoadSensors()),
      child: const AlarmPageView(),
    );
  }
}

class AlarmPageView extends StatefulWidget {
  const AlarmPageView({super.key});

  @override
  State<AlarmPageView> createState() => _AlarmPageViewState();
}

class _AlarmPageViewState extends State<AlarmPageView> with AutomaticKeepAliveClientMixin<AlarmPageView> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoStreamWidget(cameraType: CameraType.internal, enableFullscreen: true),
            ),
            const SizedBox(height: 24),
            const AlarmMainButton(),
            const SizedBox(height: 24),
            const SensorHeading(),
            const SizedBox(height: 16),
            const SensorList(),
          ],
        ),
      ),
    );
  }
}
