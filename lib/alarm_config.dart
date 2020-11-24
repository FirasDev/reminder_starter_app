import 'package:reminder_Starter_App/models/alarm_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:async';

final String tableAlarm = 'alarm';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnOccurence = "occurence";
final String columnDateTime = 'alarmDateTime';
final String columnEnabled = 'isEnabled';
final String columnColorIndex = 'gradientColorIndex';

class AlarmConfig {
  static Database _database;
  static AlarmConfig _alarmConfig;

  AlarmConfig._createInstance();
  factory AlarmConfig() {
    if (_alarmConfig == null) {
      _alarmConfig = AlarmConfig._createInstance();
    }
    return _alarmConfig;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnOccurence text,
          $columnDateTime text not null,
          $columnEnabled integer,
          $columnColorIndex integer)
        ''');
      },
    );
    return database;
  }

  void insertAlarm(AlarmInfo alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toMap());
    print('result : $result');
  }

  void updateAlarm(AlarmInfo alarmInfo) async {
    var db = await this.database;
    var result = await db.update(tableAlarm, alarmInfo.toMap(),
        where: '$columnId = ?', whereArgs: [alarmInfo.id]);
    print('result : $result');
  }

  Future<List<AlarmInfo>> getAlarms() async {
    List<AlarmInfo> _alarms = [];

    var db = await this.database;
    var result = await db.query(tableAlarm);
    result.forEach((element) {
      var alarmInfo = AlarmInfo.fromMap(element);
      _alarms.add(alarmInfo);
    });
    return _alarms;
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }
}
