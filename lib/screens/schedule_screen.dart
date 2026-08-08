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

  List<Schedule> _getSchedulesForDay(int dayIndex) {
    int dbDayOfWeek = dayIndex + 1;
    return allSchedules.where((s) => s.dayOfWeek == dbDayOfWeek).toList();
  }

  void _showAddScheduleSheet() {
    final subjectController = TextEditingController();
    int selectedDay = 1;
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E), // خلفية داكنة للنافذة
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  const Text('إضافة حصة / فترة مذاكرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'المادة أو الموضوع',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.indigoAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    value: selectedDay,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'اليوم',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.indigoAccent),
                      ),
                    ),
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(weekDays[index], style: const TextStyle(color: Colors.white)),
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
                          title: const Text('من الساعة', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          subtitle: Text(selectedStartTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          tileColor: const Color(0xFF2A2A2A),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: selectedStartTime);
                            if (time != null) setModalState(() => selectedStartTime = time);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ListTile(
                          title: const Text('إلى الساعة', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          subtitle: Text(selectedEndTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          tileColor: const Color(0xFF2A2A2A),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (subjectController.text.trim().isEmpty) return;
                        
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
                      child: const Text('حفظ في الجدول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    return DefaultTabController(
      length: 7, 
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // خلفية داكنة فخمة
        appBar: AppBar(
          title: const Text('الجدول الأسبوعي 📅', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.indigoAccent,
            labelColor: Colors.indigoAccent,
            unselectedLabelColor: Colors.white60,
            tabs: weekDays.map((day) => Tab(text: day)).toList(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
            : TabBarView(
                children: List.generate(7, (dayIndex) {
                  final daySchedules = _getSchedulesForDay(dayIndex);
                  
                  if (daySchedules.isEmpty) {
                    return const Center(child: Text('لا توجد حصص في هذا اليوم. ☕', style: TextStyle(fontSize: 16, color: Colors.grey)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = daySchedules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), // كرت داكن فاخر
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.book, color: Colors.indigoAccent),
                          ),
                          title: Text(schedule.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('من ${schedule.startTime} إلى ${schedule.endTime}', style: const TextStyle(color: Colors.white70)),
                          ),
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
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          tooltip: 'إضافة حصة',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}