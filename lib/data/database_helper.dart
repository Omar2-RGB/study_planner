import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
  }

  // ==========================================
  // عمليات CRUD الخاصة بـ المهام (Tasks)
  // ==========================================

  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'priority DESC, due_date ASC');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // عمليات CRUD الخاصة بـ الجداول (Schedules)
  // ==========================================

  Future<int> insertSchedule(Schedule schedule) async {
    final db = await instance.database;
    return await db.insert('schedules', schedule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Schedule>> getSchedules() async {
    final db = await instance.database;
    final result = await db.query('schedules', orderBy: 'day_of_week ASC, start_time ASC');
    return result.map((json) => Schedule.fromMap(json)).toList();
  }

  Future<List<Schedule>> getSchedulesByDay(int dayOfWeek) async {
    final db = await instance.database;
    final result = await db.query(
      'schedules',
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'start_time ASC',
    );
    return result.map((json) => Schedule.fromMap(json)).toList();
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await instance.database;
    return db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteTaskSchedule(int id) async {
    final db = await instance.database;
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // عمليات جلسات الدراسة (الإحصائيات)
  // ==========================================

  Future<int> insertStudySession(StudySession session) async {
    final db = await instance.database;
    return await db.insert('study_sessions', session.toMap());
  }

  Future<List<StudySession>> getStudySessions() async {
    final db = await instance.database;
    final result = await db.query('study_sessions');
    return result.map((json) => StudySession.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}