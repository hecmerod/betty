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
    if (_hasBatteriesBloc(context)) return const _ExistingBatteriesPage();

    return BlocProvider(
      create: (context) =>
          BatteriesBloc(batteriesPort: context.read<BatteriesPort>())
            ..add(const WatchBatteries()),
      child: const BatteriesPageView(),
    );
  }
}

bool _hasBatteriesBloc(BuildContext context) {
  try {
    context.read<BatteriesBloc>();
    return true;
  } on ProviderNotFoundException {
    return false;
  }
}

class _ExistingBatteriesPage extends StatefulWidget {
  const _ExistingBatteriesPage();

  @override
  State<_ExistingBatteriesPage> createState() => _ExistingBatteriesPageState();
}

class _ExistingBatteriesPageState extends State<_ExistingBatteriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<BatteriesBloc>().add(const WatchBatteries());
  }

  @override
  Widget build(BuildContext context) => const BatteriesPageView();
}

class BatteriesPageView extends StatelessWidget {
  const BatteriesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteriesBloc, BatteriesState>(
      buildWhen: (previous, current) =>
          previous.readings.isEmpty != current.readings.isEmpty ||
          previous.isLoading != current.isLoading ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.readings.isEmpty) return const BatteriesPlaceholder();

        final double gap = MediaQuery.sizeOf(context).height / 120;

        return Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(minHeight: 2),

            if (state.errorMessage != null) const BatteriesErrorBanner(),
            const BatteryReadingCard(index: 0),
            SizedBox(height: gap),
            const BatteryReadingCard(index: 1),
          ],
        );
      },
    );
  }
}
