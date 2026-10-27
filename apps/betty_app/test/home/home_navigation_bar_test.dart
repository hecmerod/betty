import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_navigation_bloc/home_navigation_bloc.dart';
import 'package:betty_app/home/presentation/widgets/navigation_bar/home_navigation_bar.dart';
import 'package:betty_app/home/presentation/widgets/navigation_bar/home_navigation_bar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a nav button accepts taps anywhere in its segment', (tester) async {
    final bloc = HomeNavigationBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: Scaffold(body: HomeNavigationBar())),
      ),
    );

    expect(bloc.state.route, Routes.home);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);

    final Rect mapButton = tester.getRect(find.byKey(HomeNavigationBarIcon.keys[Routes.map]!));
    await tester.tapAt(mapButton.topCenter + const Offset(0, 6));
    await tester.pump();

    expect(bloc.state.route, Routes.map);
    expect(find.byIcon(Icons.map), findsOneWidget);

    final Rect cameraButton = tester.getRect(find.byKey(HomeNavigationBarIcon.keys[Routes.alarm]!));
    await tester.tapAt(cameraButton.centerLeft + const Offset(8, 0));
    await tester.pump();

    expect(bloc.state.route, Routes.alarm);
    expect(find.text('Cámara'), findsOneWidget);
  });
}
