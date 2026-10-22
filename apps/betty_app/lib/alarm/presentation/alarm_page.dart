import 'package:betty_app/alarm/domain/camera_type.dart';
import 'package:betty_app/alarm/presentation/camera/widgets/video_stream_widget.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_bloc.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage>
    with AutomaticKeepAliveClientMixin<AlarmPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocSelector<HomePageBloc, HomePageState, bool>(
      selector: (state) =>
          state.activePage ==
          HomeRoutesToIndexMapper.getIndexFromRoute(Routes.camera),
      builder: (context, isActive) => VideoStreamWidget(
        cameraType: CameraType.internal,
        isActive: isActive,
      ),
    );
  }
}
