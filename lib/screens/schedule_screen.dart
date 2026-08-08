import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/schedule_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Schedule> allSchedules = [];
  bool isLoading = false;

  // أسماء الأيام (حسب ترتيب Dart حيث 1 = الإثنين، 7 = الأحد)
  final List<String> weekDays = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];

  @override
  void initState() {
    super.initState();
    _refreshSchedules();
  }

  Future<void> _refreshSchedules() async {
    setState(() => isLoading = true);
    allSchedules = await DatabaseHelper.instance.getSchedules();
    setState(() => isLoading = false);
  }

  Future<void> _deleteSchedule(int id) async {
    await DatabaseHelper.instance.deleteTaskSchedule(id);
    _refreshSchedules();
  }

  // تصفية الحصص حسب اليوم
  List<Schedule> _getSchedulesForDay(int dayIndex) {
    // dayIndex يبدأ من 0 (للإثنين) إلى 6 (للأحد)
    // لكننا خزنّاها في الداتا بيز من 1 إلى 7
    int dbDayOfWeek = dayIndex + 1;
    return allSchedules.where((s) => s.dayOfWeek == dbDayOfWeek).toList();
  }

  void _showAddScheduleSheet() {
    final subjectController = TextEditingController();
    int selectedDay = 1; // الافتراضي: الإثنين
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('إضافة حصة / فترة مذاكرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'المادة أو الموضوع',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'اليوم',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index + 1, // القيم من 1 إلى 7
                        child: Text(weekDays[index]),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) setModalState(() => selectedDay = value);
                    },
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('من الساعة'),
                          subtitle: Text(selectedStartTime.format(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: selectedStartTime);
                            if (time != null) setModalState(() => selectedStartTime = time);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ListTile(
                          title: const Text('إلى الساعة'),
                          subtitle: Text(selectedEndTime.format(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: selectedEndTime);
                            if (time != null) setModalState(() => selectedEndTime = time);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        if (subjectController.text.trim().isEmpty) return;
                        
                        // تحويل الوقت إلى نص لتخزينه في SQLite (مثال: "14:30")
                        String startText = '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}';
                        String endText = '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}';

                        final newSchedule = Schedule(
                          subjectName: subjectController.text.trim(),
                          dayOfWeek: selectedDay,
                          startTime: startText,
                          endTime: endText,
                        );
                        
                        await DatabaseHelper.instance.insertSchedule(newSchedule);
                        if (context.mounted) Navigator.pop(context);
                        _refreshSchedules();
                      },
                      child: const Text('حفظ في الجدول', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم DefaultTabController لإنشاء شريط تبويبات للأيام
    return DefaultTabController(
      length: 7, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الجدول الأسبوعي 📅', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: weekDays.map((day) => Tab(text: day)).toList(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: List.generate(7, (dayIndex) {
                  final daySchedules = _getSchedulesForDay(dayIndex);
                  
                  if (daySchedules.isEmpty) {
                    return const Center(child: Text('لا توجد حصص في هذا اليوم. ☕', style: TextStyle(fontSize: 18, color: Colors.grey)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = daySchedules[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: const Icon(Icons.book, color: Colors.indigo),
                          ),
                          title: Text(schedule.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text('من ${schedule.startTime} إلى ${schedule.endTime}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteSchedule(schedule.id!),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddScheduleSheet,
          tooltip: 'إضافة حصة',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}