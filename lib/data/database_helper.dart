import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // معرفة المنصة kIsWeb
import 'package:shared_preferences/shared_preferences.dart'; // تخزين الويب البديل

import '../models/task_model.dart';
import '../models/schedule_model.dart';
import '../models/study_session_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('study_planner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE tasks (
      id $idType,
      title $textType,
      is_completed $boolType,
      due_date $textType,
      priority $intType
    )
    ''');

    await db.execute('''
    CREATE TABLE schedules (
      id $idType,
      subject_name $textType,
      day_of_week $intType,
      start_time $textType,
      end_time $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE study_sessions (
      id $idType,
      task_id $intType,
      duration_minutes $intType,
      date $textType
    )
    ''');
    
    await db.execute('''
    CREATE TABLE notes (
      id $idType,
      title $textType,
      content $textType,
      date $textType
    )
    ''');
  }

  // ==========================================
  // عمليات CRUD الخاصة بـ المهام (Tasks)
  // ==========================================

  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Task> tasks = await getTasks();
      // توليد ID تلقائي في الويب
      int newId = tasks.isEmpty ? 1 : ((tasks.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1);
      Task newTask = Task(
        id: newId,
        title: task.title,
        isCompleted: task.isCompleted,
        dueDate: task.dueDate,
        priority: task.priority,
      );
      tasks.add(newTask);
      await prefs.setString('web_tasks', jsonEncode(tasks.map((e) => e.toMap()).toList()));
      return newId;
    }
    
    final db = await instance.database;
    return await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('web_tasks');
      if (data == null) return [];
      List<dynamic> decoded = jsonDecode(data);
      List<Task> tasks = decoded.map((e) => Task.fromMap(e)).toList();
      tasks.sort((a, b) {
        int pCompare = b.priority.compareTo(a.priority);
        if (pCompare != 0) return pCompare;
        return a.dueDate.compareTo(b.dueDate);
      });
      return tasks;
    }

    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'priority DESC, due_date ASC');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Task> tasks = await getTasks();
      int index = tasks.indexWhere((element) => element.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        await prefs.setString('web_tasks', jsonEncode(tasks.map((e) => e.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await instance.database;
    return db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Task> tasks = await getTasks();
      tasks.removeWhere((element) => element.id == id);
      await prefs.setString('web_tasks', jsonEncode(tasks.map((e) => e.toMap()).toList()));
      return 1;
    }

    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // عمليات الملاحظات السريعة (Notes)
  // ==========================================

  Future<int> insertNote(Map<String, dynamic> note) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> notes = await getNotes();
      int newId = notes.isEmpty ? 1 : ((notes.map((e) => (e['id'] as int?) ?? 0).reduce((a, b) => a > b ? a : b)) + 1);
      Map<String, dynamic> newNote = Map.from(note);
      newNote['id'] = newId;
      notes.insert(0, newNote);
      await prefs.setString('web_notes', jsonEncode(notes));
      return newId;
    }

    final db = await instance.database;
    return await db.insert('notes', note, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('web_notes');
      if (data == null) return [];
      List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    final db = await instance.database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  Future<int> deleteNote(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> notes = await getNotes();
      notes.removeWhere((element) => element['id'] == id);
      await prefs.setString('web_notes', jsonEncode(notes));
      return 1;
    }

    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // عمليات الجداول (Schedules)
  // ==========================================

  Future<int> insertSchedule(Schedule schedule) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Schedule> schedules = await getSchedules();
      int newId = schedules.isEmpty ? 1 : ((schedules.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1);
      Schedule newSchedule = Schedule(
        id: newId,
        subjectName: schedule.subjectName,
        dayOfWeek: schedule.dayOfWeek,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
      );
      schedules.add(newSchedule);
      await prefs.setString('web_schedules', jsonEncode(schedules.map((e) => e.toMap()).toList()));
      return newId;
    }

    final db = await instance.database;
    return await db.insert('schedules', schedule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Schedule>> getSchedules() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('web_schedules');
      if (data == null) return [];
      List<dynamic> decoded = jsonDecode(data);
      List<Schedule> schedules = decoded.map((e) => Schedule.fromMap(e)).toList();
      schedules.sort((a, b) {
        int dCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dCompare != 0) return dCompare;
        return a.startTime.compareTo(b.startTime);
      });
      return schedules;
    }

    final db = await instance.database;
    final result = await db.query('schedules', orderBy: 'day_of_week ASC, start_time ASC');
    return result.map((json) => Schedule.fromMap(json)).toList();
  }

  Future<List<Schedule>> getSchedulesByDay(int dayOfWeek) async {
    List<Schedule> all = await getSchedules();
    return all.where((element) => element.dayOfWeek == dayOfWeek).toList();
  }

  Future<int> updateSchedule(Schedule schedule) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Schedule> schedules = await getSchedules();
      int index = schedules.indexWhere((element) => element.id == schedule.id);
      if (index != -1) {
        schedules[index] = schedule;
        await prefs.setString('web_schedules', jsonEncode(schedules.map((e) => e.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await instance.database;
    return db.update('schedules', schedule.toMap(), where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<int> deleteTaskSchedule(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<Schedule> schedules = await getSchedules();
      schedules.removeWhere((element) => element.id == id);
      await prefs.setString('web_schedules', jsonEncode(schedules.map((e) => e.toMap()).toList()));
      return 1;
    }

    final db = await instance.database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // عمليات جلسات الدراسة (Study Sessions)
  // ==========================================

  Future<int> insertStudySession(StudySession session) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<StudySession> sessions = await getStudySessions();
      int newId = sessions.isEmpty ? 1 : ((sessions.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1);
      StudySession newSession = StudySession(
        id: newId,
        taskId: session.taskId,
        durationMinutes: session.durationMinutes,
        date: session.date,
      );
      sessions.add(newSession);
      await prefs.setString('web_sessions', jsonEncode(sessions.map((e) => e.toMap()).toList()));
      return newId;
    }

    final db = await instance.database;
    return await db.insert('study_sessions', session.toMap());
  }

  Future<List<StudySession>> getStudySessions() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString('web_sessions');
      if (data == null) return [];
      List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => StudySession.fromMap(e)).toList();
    }

    final db = await instance.database;
    final result = await db.query('study_sessions');
    return result.map((json) => StudySession.fromMap(json)).toList();
  }

  Future<void> close() async {
    if (!kIsWeb) {
      final db = await instance.database;
      db.close();
    }
  }
}