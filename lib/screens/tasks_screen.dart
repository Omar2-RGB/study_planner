import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../data/database_helper.dart';
import '../models/task_model.dart';
import '../models/study_session_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  Map<int, int> taskDurations = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() => isLoading = true);
    
    final fetchedTasks = await DatabaseHelper.instance.getTasks();
    final sessions = await DatabaseHelper.instance.getStudySessions();
    
    Map<int, int> durations = {};
    for (var session in sessions) {
      if (session.taskId != 0) {
        durations[session.taskId] = (durations[session.taskId] ?? 0) + session.durationMinutes;
      }
    }

    setState(() {
      tasks = fetchedTasks;
      taskDurations = durations;
      isLoading = false;
    });
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: !task.isCompleted,
    );
    await DatabaseHelper.instance.updateTask(updatedTask);
    _refreshTasks();
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _refreshTasks();
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int selectedPriority = 2; 

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
                  const Text('مهمة جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'عنوان المهمة',
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
                  
                  ListTile(
                    title: const Text('تاريخ الإنجاز', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.calendar_today, color: Colors.indigoAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    tileColor: const Color(0xFF2A2A2A),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setModalState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 15),
                  
                  DropdownButtonFormField<int>(
                    value: selectedPriority,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'الأولوية',
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
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('🔥 عالية', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 2, child: Text('⚡ متوسطة', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 3, child: Text('🌱 منخفضة', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) {
                      if (value != null) setModalState(() => selectedPriority = value);
                    },
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
                        if (titleController.text.trim().isEmpty) return;
                        
                        final newTask = Task(
                          title: titleController.text.trim(),
                          dueDate: selectedDate,
                          priority: selectedPriority,
                        );
                        
                        await DatabaseHelper.instance.insertTask(newTask);
                        if (context.mounted) Navigator.pop(context);
                        _refreshTasks(); 
                      },
                      child: const Text('حفظ المهمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.redAccent;
      case 2: return Colors.orangeAccent;
      case 3: return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  String _formatSpentTime(int minutes) {
    if (minutes == 0) return 'لم تبدأ بعد';
    if (minutes < 60) return 'استغرقت: $minutes دقيقة';
    int h = minutes ~/ 60;
    int m = minutes % 60;
    return m == 0 ? 'استغرقت: $h ساعة' : 'استغرقت: $h س و $m د';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // خلفية داكنة فخمة
      appBar: AppBar(
        title: const Text('مهامي 📝', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
          : tasks.isEmpty
              ? const Center(child: Text('لا توجد مهام حالياً. أضف مهمة جديدة!', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final spentMinutes = taskDurations[task.id] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E), // كرت داكن فاخر
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getPriorityColor(task.priority).withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: _getPriorityColor(task.priority),
                          checkColor: Colors.black,
                          side: const BorderSide(color: Colors.white54),
                          onChanged: (value) => _toggleTaskStatus(task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.white,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(task.dueDate),
                                    style: TextStyle(color: task.isCompleted ? Colors.grey : Colors.white60),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.timer, size: 14, color: spentMinutes > 0 ? Colors.indigoAccent : Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatSpentTime(spentMinutes),
                                    style: TextStyle(
                                      color: spentMinutes > 0 ? Colors.indigoAccent : Colors.grey,
                                      fontWeight: spentMinutes > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteTask(task.id!),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}