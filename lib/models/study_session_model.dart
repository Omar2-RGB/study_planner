class StudySession {
  final int? id;
  final int taskId;
  final int durationMinutes;
  final DateTime date;

  StudySession({
    this.id,
    required this.taskId,
    required this.durationMinutes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'duration_minutes': durationMinutes,
      'date': date.toIso8601String(),
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      taskId: map['task_id'],
      durationMinutes: map['duration_minutes'],
      date: DateTime.parse(map['date']),
    );
  }
}