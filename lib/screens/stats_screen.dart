import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/study_session_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int totalMinutes = 0;
  int todayMinutes = 0;
  bool isLoading = true;

  // تخزين بيانات آخر 7 أيام
  List<Map<String, dynamic>> weeklyData = [];
  int maxDailyMinutes = 1; // لمنع القسمة على صفر في الرسم البياني

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final sessions = await DatabaseHelper.instance.getStudySessions();
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    
    int tempTotal = 0;
    int tempToday = 0;
    Map<DateTime, int> dailyMinutesMap = {};

    for (var session in sessions) {
      tempTotal += session.durationMinutes;
      
      // توحيد التاريخ بدون الساعات والدقائق للمقارنة والتجميع
      DateTime sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      
      if (sessionDate == todayDate) {
        tempToday += session.durationMinutes;
      }

      // تجميع الدقائق لكل يوم
      dailyMinutesMap[sessionDate] = (dailyMinutesMap[sessionDate] ?? 0) + session.durationMinutes;
    }

    // تحضير بيانات الرسم البياني لآخر 7 أيام
    List<Map<String, dynamic>> tempWeeklyData = [];
    int tempMax = 0;

    for (int i = 6; i >= 0; i--) {
      DateTime d = todayDate.subtract(Duration(days: i));
      int mins = dailyMinutesMap[d] ?? 0;
      
      if (mins > tempMax) tempMax = mins;

      tempWeeklyData.add({
        'dayLabel': _getArabicDayShortName(d.weekday),
        'minutes': mins,
        'isToday': i == 0, // للتمييز بلون مختلف لليوم الحالي
      });
    }

    setState(() {
      totalMinutes = tempTotal;
      todayMinutes = tempToday;
      weeklyData = tempWeeklyData;
      maxDailyMinutes = tempMax > 0 ? tempMax : 1; // ضمان عدم وجود صفر
      isLoading = false;
    });
  }

  // دالة مساعدة للحصول على اسم اليوم مختصراً
  String _getArabicDayShortName(int weekday) {
    switch (weekday) {
      case 1: return 'إثن';
      case 2: return 'ثلا';
      case 3: return 'أرب';
      case 4: return 'خمي';
      case 5: return 'جمع';
      case 6: return 'سبت';
      case 7: return 'أحد';
      default: return '';
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes د';
    int h = minutes ~/ 60;
    int m = minutes % 60;
    return m == 0 ? '$h س' : '$h س و $m د';
  }

  Widget _buildStatCard(String title, int minutes, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(_formatTime(minutes), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // بناء الرسم البياني
  Widget _buildWeeklyChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نشاط آخر 7 أيام 📊', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((data) {
                int mins = data['minutes'];
                bool isToday = data['isToday'];
                // حساب نسبة ارتفاع العمود (بحد أقصى 150 بكسل)
                double barHeight = (mins / maxDailyMinutes) * 150.0;
                // إذا لم يكن هناك دقائق، نعطي العمود ارتفاعاً صغيراً جداً ليظهر الخط
                if (barHeight == 0) barHeight = 4.0;

                return Column(
                  children: [
                    // النص فوق العمود (عدد الدقائق)
                    Text(
                      mins > 0 ? mins.toString() : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    // العمود مع تأثير حركي (Animation)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      height: barHeight,
                      width: 25,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.orange : Colors.indigo.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // اسم اليوم تحت العمود
                    Text(
                      data['dayLabel'],
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? Colors.orange : Colors.grey.shade700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('إحصائيات الإنجاز 📈', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard('إنجاز اليوم', todayMinutes, Icons.local_fire_department, Colors.orange)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildStatCard('الوقت الكلي', totalMinutes, Icons.emoji_events, Colors.indigo)),
                  ],
                ),
                const SizedBox(height: 25),
                _buildWeeklyChart(), // استدعاء الرسم البياني هنا
                const SizedBox(height: 25),
                // رسالة تشجيعية
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.green, size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          todayMinutes > 0 
                            ? 'عمل رائع اليوم! استمر بهذا الحماس 🔥' 
                            : 'لم تبدأ بعد اليوم.. جهّز كوب القهوة وابدأ أول جلسة! ☕',
                          style: TextStyle(color: Colors.green.shade800, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
    );
  }
}