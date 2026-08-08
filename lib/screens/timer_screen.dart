import 'dart:async';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/study_session_model.dart';
import '../models/task_model.dart';
import 'about_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int workMinutes = 25;
  int breakMinutes = 5;
  
  late int secondsRemaining;
  late int totalSeconds;
  Timer? timer;
  bool isRunning = false;
  bool isWorkTime = true;

  List<Task> pendingTasks = [];
  Task? selectedTask;

  @override
  void initState() {
    super.initState();
    _resetTimerData();
    _loadPendingTasks();
  }

  Future<void> _loadPendingTasks() async {
    final allTasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      pendingTasks = allTasks.where((task) => !task.isCompleted).toList();
      if (pendingTasks.isNotEmpty && selectedTask == null) {
        selectedTask = pendingTasks.first;
      }
    });
  }

  void _resetTimerData() {
    totalSeconds = (isWorkTime ? workMinutes : breakMinutes) * 60;
    secondsRemaining = totalSeconds;
  }

  void startTimer() {
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          if (isWorkTime) {
            final session = StudySession(
              taskId: selectedTask?.id ?? 0,
              durationMinutes: workMinutes,
              date: DateTime.now(),
            );
            DatabaseHelper.instance.insertStudySession(session);
          }
          
          stopTimer();
          isWorkTime = !isWorkTime;
          _resetTimerData();
        }
      });
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      _resetTimerData();
    });
  }

  void _showEditTimeDialog() {
    TextEditingController workCtrl = TextEditingController(text: workMinutes.toString());
    TextEditingController breakCtrl = TextEditingController(text: breakMinutes.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تخصيص الوقت ⏱️', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'وقت التركيز (بالدقائق)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigoAccent),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: breakCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'وقت الاستراحة (بالدقائق)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.indigoAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  workMinutes = int.tryParse(workCtrl.text) ?? 25;
                  breakMinutes = int.tryParse(breakCtrl.text) ?? 5;
                  isWorkTime = true;
                  stopTimer();
                });
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  String get timerText {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalSeconds == 0 ? 0 : secondsRemaining / totalSeconds;
    Color activeColor = isWorkTime ? Colors.indigoAccent : Colors.tealAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // خلفية داكنة فخمة
      appBar: AppBar(
        title: const Text('مؤقت الإنجاز', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            tooltip: 'عن التطبيق والمبرمج',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: 'تعديل الوقت',
            onPressed: _showEditTimeDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWorkTime) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigoAccent.withOpacity(0.4), width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Task>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E1E),
                    hint: const Text('اختر مهمة للعمل عليها...', style: TextStyle(color: Colors.grey)),
                    value: selectedTask,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.indigoAccent),
                    items: pendingTasks.map((Task task) {
                      return DropdownMenuItem<Task>(
                        value: task,
                        child: Text('🎯 ${task.title}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: isRunning ? null : (Task? newValue) { 
                      setState(() {
                        selectedTask = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: activeColor.withOpacity(0.3)),
              ),
              child: Text(
                isWorkTime ? 'وقت التركيز 🧠' : 'وقت الاستراحة ☕',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: activeColor),
              ),
            ),
            const SizedBox(height: 40),
            
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  timerText,
                  style: const TextStyle(
                    fontSize: 60, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isRunning)
                  FloatingActionButton.extended(
                    onPressed: startTimer,
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('ابدأ التنفيذ', style: TextStyle(fontSize: 18)),
                  )
                else
                  FloatingActionButton.extended(
                    onPressed: pauseTimer,
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.pause),
                    label: const Text('إيقاف', style: TextStyle(fontSize: 18)),
                  ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: stopTimer,
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  tooltip: 'إعادة ضبط',
                  child: const Icon(Icons.refresh),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}