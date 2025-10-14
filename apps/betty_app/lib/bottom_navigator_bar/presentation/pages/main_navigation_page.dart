import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/navigation_item.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../../../primary/presentation/pages/primary_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../camera/presentation/pages/camera_page.dart';
import '../../../trips/presentation/pages/trips_page.dart';
import '../../../trips/presentation/providers/trip_provider.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const PrimaryPage(), const MapPage(), const CameraPage(), const TripsPage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Selector<TripProvider, bool>(
        selector: (context, provider) => provider.hasTripInProgress,
        builder: (context, hasTripInProgress, child) {
          return BottomNavigationBarWidget(
            currentIndex: _currentIndex,
            items: [
              const NavigationItem(label: 'Principal', icon: Icons.home_outlined, activeIcon: Icons.home),
              const NavigationItem(label: 'Mapa', icon: Icons.location_on_outlined, activeIcon: Icons.location_on),
              const NavigationItem(label: 'Cámara', icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt),
              NavigationItem(
                label: 'Viajes',
                icon: hasTripInProgress ? Icons.play_circle_outlined : Icons.list_outlined,
                activeIcon: hasTripInProgress ? Icons.play_circle : Icons.list,
              ),
            ],
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }
}
