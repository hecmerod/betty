import 'package:betty_app/home/presentation/widgets/app_bar/app_bar.dart';
import 'package:betty_app/home/presentation/widgets/three_d_van_viewer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ThreeDVanViewer()),
        Positioned.fill(
          child: Scaffold(appBar: CustomAppBar(), backgroundColor: Colors.transparent, body: Placeholder()),
        ),
      ],
    );
  }
}
