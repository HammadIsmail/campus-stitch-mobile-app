import 'package:flutter/material.dart';
import '../../widgets/bottom_tab_bar.dart';
import 'bikes/bikes_screen.dart';
import 'market/market_screen.dart';
import 'profile/profile_screen.dart';
import 'roommates/roommates_screen.dart';
import 'services/services_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ServicesScreen(),
      const RoommatesScreen(),
      const BikesScreen(),
      const MarketScreen(),
      ProfileScreen(onSwitchTab: _onTabTapped),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomTabBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
      ),
    );
  }
}
