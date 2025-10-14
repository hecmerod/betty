import 'package:flutter/material.dart';
import '../../domain/models/navigation_item.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../../../primary/presentation/pages/primary_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../camera/presentation/pages/camera_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<NavigationItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _navigationItems = [
      const NavigationItem(label: 'Principal', icon: Icons.home_outlined, activeIcon: Icons.home, page: PrimaryPage()),
      const NavigationItem(
        label: 'Mapa',
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on,
        page: MapPage(),
      ),
      const NavigationItem(
        label: 'Cámara',
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt,
        page: CameraPage(),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navigationItems[_currentIndex].page,
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        items: _navigationItems,
        onTap: _onItemTapped,
      ),
    );
  }
}
