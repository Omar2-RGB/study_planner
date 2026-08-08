class Task {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime dueDate;
  final int priority;

  Task({
    this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    required this.priority,
  });

  // تحويل الكائن إلى Map لإدخاله في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted ? 1 : 0, // SQLite لا يدعم البوليان
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
    };
  }

  // استخراج الكائن من Map قادم من قاعدة البيانات
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['is_completed'] == 1,
      dueDate: DateTime.parse(map['due_date']),
      priority: map['priority'],
    );
  }
}