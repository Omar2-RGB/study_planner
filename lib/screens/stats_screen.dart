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

  List<Map<String, dynamic>> weeklyData = [];
  int maxDailyMinutes = 1;

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
      
      DateTime sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      
      if (sessionDate == todayDate) {
        tempToday += session.durationMinutes;
      }

      dailyMinutesMap[sessionDate] = (dailyMinutesMap[sessionDate] ?? 0) + session.durationMinutes;
    }

    List<Map<String, dynamic>> tempWeeklyData = [];
    int tempMax = 0;

    for (int i = 6; i >= 0; i--) {
      DateTime d = todayDate.subtract(Duration(days: i));
      int mins = dailyMinutesMap[d] ?? 0;
      
      if (mins > tempMax) tempMax = mins;

      tempWeeklyData.add({
        'dayLabel': _getArabicDayShortName(d.weekday),
        'minutes': mins,
        'isToday': i == 0,
      });
    }

    setState(() {
      totalMinutes = tempTotal;
      todayMinutes = tempToday;
      weeklyData = tempWeeklyData;
      maxDailyMinutes = tempMax > 0 ? tempMax : 1;
      isLoading = false;
    });
  }

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // كرت داكن فاخر
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(_formatTime(minutes), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // كرت داكن فاخر
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نشاط آخر 7 أيام 📊', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyData.map((data) {
              int mins = data['minutes'];
              bool isToday = data['isToday'];
              double barHeight = (mins / maxDailyMinutes) * 150.0;
              if (barHeight == 0) barHeight = 4.0;

              return Column(
                children: [
                  Text(
                    mins > 0 ? mins.toString() : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    height: barHeight,
                    width: 25,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.orangeAccent : Colors.indigoAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['dayLabel'],
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.orangeAccent : Colors.grey.shade400,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // خلفية داكنة فخمة للمدينة
      appBar: AppBar(
        title: const Text('إحصائيات الإنجاز 📈', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard('إنجاز اليوم', todayMinutes, Icons.local_fire_department, Colors.orangeAccent)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildStatCard('الوقت الكلي', totalMinutes, Icons.emoji_events, Colors.indigoAccent)),
                  ],
                ),
                const SizedBox(height: 25),
                _buildWeeklyChart(),
                const SizedBox(height: 25),
                
                // رسالة تشجيعية متوافقة مع الوضع الليلي
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2E22), // أخضر داكن مريح للعين
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.greenAccent, size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          todayMinutes > 0 
                            ? 'عمل رائع اليوم! استمر بهذا الحماس 🔥' 
                            : 'لم تبدأ بعد اليوم.. جهّز كوب القهوة وابدأ أول جلسة! ☕',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
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