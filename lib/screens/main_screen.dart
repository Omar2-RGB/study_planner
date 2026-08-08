import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'tasks_screen.dart';
import 'schedule_screen.dart';
import 'stats_screen.dart';
import 'notes_screen.dart';

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
    const NotesScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        // خلفية داكنة فاخرة تتناسب مع الطابع الليلي الجديد
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.indigoAccent.withOpacity(0.3), // لون التحديد النشط
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_rounded, color: Colors.white60),
            selectedIcon: Icon(Icons.timer_rounded, color: Colors.indigoAccent),
            label: 'المؤقت',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_rounded, color: Colors.white60),
            selectedIcon: Icon(Icons.task_alt_rounded, color: Colors.indigoAccent),
            label: 'المهام',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded, color: Colors.white60),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.indigoAccent),
            label: 'الجدول',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_rounded, color: Colors.white60),
            selectedIcon: Icon(Icons.note_alt_rounded, color: Colors.indigoAccent),
            label: 'ملاحظات',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded, color: Colors.white60),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.indigoAccent),
            label: 'إحصائيات',
          ),
        ],
      ),
    );
  }
}