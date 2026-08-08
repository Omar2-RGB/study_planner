class Schedule {
  final int? id;
  final String subjectName;
  final int dayOfWeek; 
  final String startTime; 
  final String endTime;

  Schedule({
    this.id,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_name': subjectName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      subjectName: map['subject_name'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'],
      endTime: map['end_time'],
    );
  }
}