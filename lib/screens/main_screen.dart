import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'tasks_screen.dart';
import 'schedule_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const TimerScreen(),
    const TasksScreen(),
    const ScheduleScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer_rounded), label: 'المؤقت'),
          NavigationDestination(icon: Icon(Icons.task_alt_rounded), label: 'المهام'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'الجدول'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'إحصائيات'),
        ],
      ),
    );
  }
}