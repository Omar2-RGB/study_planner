import 'dart:async';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/study_session_model.dart';
import '../models/task_model.dart'; // استدعاء نموذج المهام

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

  // -- متغيرات المهام --
  List<Task> pendingTasks = [];
  Task? selectedTask;

  @override
  void initState() {
    super.initState();
    _resetTimerData();
    _loadPendingTasks(); // تحميل المهام عند فتح الشاشة
  }

  // جلب المهام غير المكتملة لربطها بالمؤقت
  Future<void> _loadPendingTasks() async {
    final allTasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      pendingTasks = allTasks.where((task) => !task.isCompleted).toList();
      // اختيار أول مهمة تلقائياً إذا كان هناك مهام
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
          // إذا انتهى وقت التركيز، احفظ الجلسة واربطها بالمهمة المحددة
          if (isWorkTime) {
            final session = StudySession(
              taskId: selectedTask?.id ?? 0, // ربط الوقت بالـ id الخاص بالمهمة المحددة
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تخصيص الوقت ⏱️', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'وقت التركيز (بالدقائق)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: breakCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'وقت الاستراحة (بالدقائق)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
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
    Color activeColor = isWorkTime ? Colors.indigoAccent : Colors.teal;
    Color bgColor = isWorkTime ? Colors.indigo.shade50 : Colors.teal.shade50;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('مؤقت الإنجاز', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'تعديل الوقت',
            onPressed: _showEditTimeDialog,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // -- قائمة اختيار المهمة للعمل عليها --
            if (isWorkTime) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo.shade100, width: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Task>(
                    isExpanded: true,
                    hint: const Text('اختر مهمة للعمل عليها...'),
                    value: selectedTask,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.indigo),
                    items: pendingTasks.map((Task task) {
                      return DropdownMenuItem<Task>(
                        value: task,
                        child: Text('🎯 ${task.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: isRunning ? null : (Task? newValue) { 
                      // لا يمكن تغيير المهمة أثناء عمل المؤقت
                      setState(() {
                        selectedTask = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // ------------------------------------

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
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
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  timerText,
                  style: TextStyle(
                    fontSize: 60, 
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
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
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.pause),
                    label: const Text('إيقاف', style: TextStyle(fontSize: 18)),
                  ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: stopTimer,
                  backgroundColor: Colors.red.shade400,
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