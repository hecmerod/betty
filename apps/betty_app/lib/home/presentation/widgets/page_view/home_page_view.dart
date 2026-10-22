import 'package:betty_app/alarm/presentation/alarm_page.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_state.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_bloc.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_event.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:betty_app/home/presentation/home_page.dart';
import 'package:betty_app/home/presentation/widgets/navigation_bar/home_navigation_bar.dart';
import 'package:betty_app/map/presentation/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeNavigationBloc()),
        BlocProvider(create: (context) => HomePageBloc()),
      ],
      child: const _HomePageViewBody(),
    );
  }
}

class _HomePageViewBody extends StatefulWidget {
  const _HomePageViewBody();

  @override
  State<_HomePageViewBody> createState() => _HomePageViewBodyState();
}

class _HomePageViewBodyState extends State<_HomePageViewBody> {
  final PageController _controller = PageController(initialPage: HomePageState.initialPage);
  int _page = HomePageState.initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int destination) async {
    if (destination == _page) return;

    final bloc = context.read<HomePageBloc>();
    bloc.add(PageTransitionStarted(destination));

    final int pageDistance = (_page - destination).abs();
    _page = destination;

    pageDistance > 1
        ? _controller.jumpToPage(destination)
        : await _controller.animateToPage(destination, duration: const Duration(milliseconds: 300), curve: Curves.ease);

    if (!mounted || bloc.isClosed || _page != destination) return;
    bloc.add(PageTransitionFinished(destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<HomeNavigationBloc, HomeNavigationState>(
        listenWhen: (previous, current) => previous.route != current.route,
        listener: (context, state) => _goToPage(HomeRoutesToIndexMapper.getIndexFromRoute(state.route)),
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              children: const [AlarmPage(), HomePage(), MapPage()],
            ),
            const Positioned(left: 0, right: 0, bottom: 0, child: HomeNavigationBar()),
          ],
        ),
      ),
    );
  }
}
