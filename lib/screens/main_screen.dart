import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // حزمة الإعلانات
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
  
  // متغيرات الإعلان
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<Widget> _screens = [
    const TimerScreen(),
    const TasksScreen(),
    const ScheduleScreen(),
    const NotesScreen(),
    const StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  // دالة تهيئة وتحميل الإعلان
  void _initBannerAd() {
    _bannerAd = BannerAd(
      // معرّف الوحدة الإعلانية الخاص بك
      adUnitId: 'ca-app-pub-2095279697107993/4771751965',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // يمكنك طباعة الخطأ للتتبع إن أردت: print('Ad load failed: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // تنظيف الذاكرة عند إغلاق الشاشة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // عرض محتوى الشاشة المختارة
          Expanded(
            child: _screens[_currentIndex],
          ),
          
          // مكان إظهار الإعلان فوق شريط التنقل مباشرة إن تم تحميلة بنجاح
          if (_isAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              color: const Color(0xFF1E1E1E), // متناسق مع لون الثيم الداكن
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.indigoAccent.withOpacity(0.3),
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