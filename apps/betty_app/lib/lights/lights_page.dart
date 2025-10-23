import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/widgets/secondary_page_app_bar.dart';
import 'bloc/lights_bloc.dart';
import 'bloc/lights_state.dart';
import 'widgets/exterior_lights_page.dart';
import 'widgets/interior_lights_page.dart';
import 'widgets/lights_tab_selector.dart';

class LightsPage extends StatelessWidget {
  const LightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LightsBloc(), child: const _LightsPageContent());
  }
}

class _LightsPageContent extends StatefulWidget {
  const _LightsPageContent();

  @override
  State<_LightsPageContent> createState() => _LightsPageContentState();
}

class _LightsPageContentState extends State<_LightsPageContent> with SingleTickerProviderStateMixin {
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
    return BlocBuilder<LightsBloc, LightsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: SecondaryPageAppBar(
            title: 'Control de Luces',
            backgroundOpacity: 0.0,
            customTitle: LightsTabSelector(currentPage: state.currentPage),
          ),
          body: BlocListener<LightsBloc, LightsState>(
            listenWhen: (previous, current) => previous.currentPage != current.currentPage,
            listener: (context, state) async {
              await _fadeController.reverse();
              _fadeController.forward();
            },
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: state.currentPage == 0 ? const ExteriorLightsPage() : const InteriorLightsPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
