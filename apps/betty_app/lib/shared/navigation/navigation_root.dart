import 'package:betty_app/shared/navigation/bloc/navigation_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:betty_app/shared/widgets/background.dart';
import 'bloc/navigation_bloc.dart';
import 'bloc/navigation_state.dart';
import 'route_generator.dart';

class NavigationRoot extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const NavigationRoot({super.key, required this.child, required this.navigatorKey});

  @override
  State<NavigationRoot> createState() => _NavigationRootState();
}

class _NavigationRootState extends State<NavigationRoot> {
  late final NavigationBloc _navigationBloc;

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc();
  }

  @override
  void dispose() {
    _navigationBloc.close();
    super.dispose();
  }

  void _handleNavigation(BuildContext context, NavigationState state) {
    if (state.pendingRoute != null) {
      final route = state.pendingRoute!;
      final arguments = state.pendingArguments;

      _navigationBloc.add(const ClearPendingRoute());

      final pageWidget = RouteGenerator.getPageWidget(route);

      if (pageWidget != null) {
        widget.navigatorKey.currentState
            ?.push(
              MaterialPageRoute(
                builder: (_) => pageWidget,
                settings: RouteSettings(name: route, arguments: arguments),
              ),
            )
            .then((_) {
              _navigationBloc.add(const ShowAllWidgets());
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationBloc>.value(
      value: _navigationBloc,
      child: BlocListener<NavigationBloc, NavigationState>(
        listener: _handleNavigation,
        listenWhen: (previous, current) => current.pendingRoute != null,
        child: Stack(
          children: [
            const Positioned.fill(child: Background()),
            widget.child,
          ],
        ),
      ),
    );
  }
}
