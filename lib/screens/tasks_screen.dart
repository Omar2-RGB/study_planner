import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../data/database_helper.dart';
import '../models/task_model.dart';
import '../models/study_session_model.dart'; // استدعاء نموذج الجلسات

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  Map<int, int> taskDurations = {}; // قاموس لتخزين (رقم المهمة -> إجمالي الدقائق)
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  // تحديث قائمة المهام وجلب أوقات العمل عليها
  Future<void> _refreshTasks() async {
    setState(() => isLoading = true);
    
    // جلب المهام
    final fetchedTasks = await DatabaseHelper.instance.getTasks();
    
    // جلب الجلسات لحساب الوقت
    final sessions = await DatabaseHelper.instance.getStudySessions();
    
    // حساب مجموع الدقائق لكل مهمة
    Map<int, int> durations = {};
    for (var session in sessions) {
      if (session.taskId != 0) { // نتجاهل المهام العامة (id = 0)
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
                  const Text('مهمة جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان المهمة',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  ListTile(
                    title: const Text('تاريخ الإنجاز'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
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
                    initialValue: selectedPriority, // تم استخدام initialValue هنا
                    decoration: InputDecoration(
                      labelText: 'الأولوية',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('🔥 عالية')),
                      DropdownMenuItem(value: 2, child: Text('⚡ متوسطة')),
                      DropdownMenuItem(value: 3, child: Text('🌱 منخفضة')),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      child: const Text('حفظ المهمة', style: TextStyle(fontSize: 18)),
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
      case 1: return Colors.red.shade400;
      case 2: return Colors.orange.shade400;
      case 3: return Colors.green.shade400;
      default: return Colors.grey;
    }
  }

  // تحويل الدقائق إلى صيغة مقروءة بشكل جميل
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
      appBar: AppBar(
        title: const Text('مهامي 📝', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text('لا توجد مهام حالياً. أضف مهمة جديدة!', style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    
                    // جلب الوقت المستغرق لهذه المهمة (أو 0 إذا لم نعمل عليها بعد)
                    final spentMinutes = taskDurations[task.id] ?? 0;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: _getPriorityColor(task.priority), width: 1.5),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: _getPriorityColor(task.priority),
                          onChanged: (value) => _toggleTaskStatus(task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                        // تعديل هنا: دمج التاريخ مع الوقت المستغرق
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
                                    style: TextStyle(color: task.isCompleted ? Colors.grey : Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.timer, size: 14, color: spentMinutes > 0 ? Colors.indigo : Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatSpentTime(spentMinutes),
                                    style: TextStyle(
                                      color: spentMinutes > 0 ? Colors.indigo : Colors.grey,
                                      fontWeight: spentMinutes > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteTask(task.id!),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}