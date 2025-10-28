import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/widgets/secondary_page_app_bar.dart';
import 'bloc/camera_bloc.dart';
import 'bloc/camera_state.dart';
import 'widgets/internal_camera_page.dart';
import 'widgets/external_camera_page.dart';
import 'widgets/camera_tab_selector.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => CameraBloc(), child: const _CameraPageContent());
  }
}

class _CameraPageContent extends StatefulWidget {
  const _CameraPageContent();

  @override
  State<_CameraPageContent> createState() => _CameraPageContentState();
}

class _CameraPageContentState extends State<_CameraPageContent> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: SecondaryPageAppBar(
            title: 'Cámaras',
            backgroundOpacity: 0.0,
            customTitle: CameraTabSelector(currentPage: state.currentPage),
          ),
          body: BlocListener<CameraBloc, CameraState>(
            listenWhen: (previous, current) => previous.currentPage != current.currentPage,
            listener: (context, state) async {
              await _fadeController.reverse();
              _fadeController.forward();
            },
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: state.currentPage == 0 ? const InternalCameraPage() : const ExternalCameraPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
