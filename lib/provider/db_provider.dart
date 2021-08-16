import 'dart:io';
import 'package:flutterweather/models/WeatherData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the Employee table
  initDB() async {
    final path = join(await getDatabasesPath(), 'weatherDatabase.db');
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE weather('
              'id INTEGER PRIMARY KEY autoincrement,'
              'date INTEGER,'
              'name TEXT,'
              'temp DOUBLE,'
              'main TEXT,'
              'icon TEXT'
              ')');
        });
  }

  // Insert employee on database
  createWeather(WeatherData weatherData) async {
    await deleteAllWeather();
    final db = await database;
    final res = await db!.insert('weather', weatherData.toJson());

    return res;
  }

  // Delete all employees
  Future<int> deleteAllWeather() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM weather');

    return res;
  }

  Future<List<WeatherData>> getAllWeather() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM weather");

    return List.generate(res.length, (i) {
      return WeatherData(
        name:res[i]['name'].toString(),
        icon:res[i]['icon'].toString(),
        main:res[i]['main'].toString(),
        temp: double.parse(res[i]['temp'].toString()),
        date: int.parse(res[i]['date'].toString()),
      );
    });
  }
}