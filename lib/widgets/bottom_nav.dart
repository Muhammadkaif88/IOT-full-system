import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/rooms_screen.dart';
import '../screens/scenes_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/settings_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  void _go(BuildContext context, int i) {
    if (i == currentIndex) return;
    Widget page;
    switch (i) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const RoomsScreen();
        break;
      case 2:
        page = const ScenesScreen();
        break;
      case 3:
        page = const ScheduleScreen();
        break;
      default:
        page = const SettingsScreen();
    }
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _go(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Rooms'),
        BottomNavigationBarItem(icon: Icon(Icons.bolt_outlined), label: 'Scenes'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}
