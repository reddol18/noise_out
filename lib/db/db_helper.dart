import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LogItem {
  int id;
  int walks;
  int second;
  int hour;
  int minute;
  int year;
  int month;
  int day;
  double noise;
  bool use_average;
  String jibun;
  bool is_lowlevel;
  double lat;
  double lng;
  int duration;

  LogItem(
      {required this.id,
        required this.walks,
        required this.year,
        required this.month,
        required this.day,
        required this.hour,
        required this.minute,
        required this.second,
        required this.noise,
        required this.use_average,
        required this.jibun,
        required this.is_lowlevel,
        required this.lat,
        required this.lng,
        required this.duration
      });
}

class DbHelper {
  late Database db;

  Future openDb() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, 'noise_out_data.db');

    db = await openDatabase(
      path,
      version: 1,
      onConfigure: (Database db) => {},
      onCreate: _onCreate,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        print("Version Check ${oldVersion}, ${newVersion}");
        if (newVersion == 2) {
          /*await db.execute('''
            CREATE TABLE IF NOT EXISTS app_info (
              id INTEGER NOT NULL,
              title TEXT
            )
          ''');*/
        } else if (newVersion == 3) {
          /*List<Map> res = await db.rawQuery("PRAGMA table_info(last_log)", null);
          bool hasColumn = false;
          for(int i = 0 ; i < res.length; i++) {
            if (res[i]["name"] == "combo") {
              hasColumn = true;
            }
          }
          if (!hasColumn) {
            await db.execute('''
              ALTER TABLE last_log ADD combo INTEGER DEFAULT 0 NOT NULL
            ''');
            await db.execute('''
              ALTER TABLE daily_log ADD combo INTEGER DEFAULT 0 NOT NULL
            ''');
          }*/
        }
      },
    );
  }

  /**
      int id;
      int walks;
      int second;
      int hour;
      int minute;
      int year;
      int month;
      int day;
      double noise;
      bool use_average;
      String jibun;
      bool is_lowlevel;
      double lat;
      double lng;
   */
  // 데이터베이스 테이블을 생성한다.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS noise_log (
        id INTEGER PRIMARY KEY,
        walks INTEGER NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        day INTEGER NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        second INTEGER NOT NULL,
        noise FLOAT NOT NULL,
        use_average INTEGER NOT NULL,
        jibun STRING NOT NULL,
        is_lowlevel INTEGER NOT NULL,
        lat FLOAT NOT NULL,
        lng FLOAT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');
  }

  Future<LogItem?> getLogItem(int id) async {
    List<Map> logItems = await db.query("noise_log",
        columns: ["id", "walks",
          "year", "month", "day", "hour", "minute", "second",
          "noise", "use_average", "jibun", "is_lowlevel", "lat", "lng", "duration"],
        where: "id = ?",
        whereArgs: [id]);
    if (logItems.length > 0) {
      return LogItem(
        id: logItems.first["id"],
        walks: logItems.first["walks"],
        year: logItems.first["year"],
        month: logItems.first["month"],
        day: logItems.first["day"],
        hour: logItems.first["hour"],
        minute: logItems.first["minute"],
        second: logItems.first["second"],
        noise: logItems.first["noise"],
        use_average: logItems.first["use_average"] == 1 ? true : false,
        jibun: logItems.first["jibun"],
        is_lowlevel: logItems.first["is_lowlevel"] == 1 ? true : false,
        lat: logItems.first["lat"],
        lng: logItems.first["lng"],
        duration: logItems.first["duration"],
      );
    }
    return null;
  }

  Future<List<LogItem>> getLogItems() async {
    List<Map> result = await db.query("noise_log",
      columns: ["id", "walks",
        "year", "month", "day", "hour", "minute", "second",
        "noise", "use_average", "jibun", "is_lowlevel", "lat", "lng", "duration"],);
    List<LogItem> rets = <LogItem>[];
    result.forEach((item) {
      rets.add(LogItem(
        id: item["id"],
        walks: item["walks"],
        year: item["year"],
        month: item["month"],
        day: item["day"],
        hour: item["hour"],
        minute: item["minute"],
        second: item["second"],
        noise: item["noise"],
        use_average: item["use_average"] == 1 ? true : false,
        jibun: item["jibun"],
        is_lowlevel: item["is_lowlevel"] == 1 ? true : false,
        lat: item["lat"],
        lng: item["lng"],
        duration: item["duration"],
      ));
    });
    return rets;
  }

  // 새로운 데이터를 추가한다.
  Future add(LogItem item) async {
    item.id = await db.insert(
      'noise_log', // table name
      {
        'walks': item.walks,
        'year': item.year,
        'month': item.month,
        'day': item.day,
        'hour': item.hour,
        'minute': item.minute,
        'second': item.second,
        'noise': item.noise,
        'use_average': item.use_average ? 1: 0,
        'jibun': item.jibun,
        'is_lowlevel': item.is_lowlevel ? 1 : 0,
        'lat': item.lat,
        'lng': item.lng,
        'duration': item.duration,
      }, // new post row data
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return item;
  }

  // 변경된 데이터를 업데이트한다.
  /*
  Future update(item) async {
    await db.update(
      'daily_log', // table name
      {
        'walks': item.walks,
        'seconds': item.seconds,
        'year': item.year,
        'month': item.month,
        'day': item.day,
        'combo': item.combo,
      }, // new post row data
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return item;
  }*/

  // 데이터를 삭제한다.
  Future<int> remove(int id) async {
    await db.delete(
      'noise_log', // table name
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }

  Future close() async => db.close();
}
