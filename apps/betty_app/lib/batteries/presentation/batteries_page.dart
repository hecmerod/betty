import 'package:betty_app/batteries/application/batteries_bloc/batteries_bloc.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_event.dart';
import 'package:betty_app/batteries/application/batteries_bloc/batteries_state.dart';
import 'package:betty_app/batteries/domain/ports/batteries_port.dart';
import 'package:betty_app/batteries/presentation/widgets/batteries_error_banner.dart';
import 'package:betty_app/batteries/presentation/widgets/batteries_placeholder.dart';
import 'package:betty_app/batteries/presentation/widgets/battery_reading_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteriesPage extends StatelessWidget {
  const BatteriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BatteriesBloc(batteriesPort: context.read<BatteriesPort>())..add(const WatchBatteries()),
      child: const BatteriesPageView(),
    );
  }
}

class BatteriesPageView extends StatelessWidget {
  const BatteriesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocBuilder<BatteriesBloc, BatteriesState>(
        buildWhen: (previous, current) =>
            previous.readings.isEmpty != current.readings.isEmpty || previous.isLoading != current.isLoading,
        builder: (context, state) {
          if (state.readings.isEmpty) return const BatteriesPlaceholder();

          final double height = MediaQuery.sizeOf(context).height;
          final EdgeInsets cardInsets = EdgeInsets.symmetric(horizontal: height / 40);

          return Column(
            children: [
              SizedBox(height: height / 10),
              if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
              if (state.errorMessage != null) const BatteriesErrorBanner(),
              Padding(padding: cardInsets, child: const BatteryReadingCard(index: 0)),
              SizedBox(height: height / 20),
              Padding(padding: cardInsets, child: const BatteryReadingCard(index: 1)),
            ],
          );
        },
      ),
    );
  }
}
