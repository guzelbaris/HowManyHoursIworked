import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  static const String _workingTableName = "workinghours";
  static const String _workingIdName = "Id";
  static const String _workingYearColumnName = "Year";
  static const String _workingMonthColumnName = "Month";
  static const String _workingWeekColumnName = "Week";
  static const String _workingDayColumnName = "Day";
  static const String _workingMinutsColumnName = "Minutes";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "mast_db.db");
    print(databasePath);
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_workingTableName (
          $_workingIdName INTEGER PRIMARY KEY,
          $_workingYearColumnName TEXT NOT NULL,
          $_workingMonthColumnName TEXT NOT NULL,
          $_workingWeekColumnName TEXT NOT NULL,
          $_workingDayColumnName TEXT NOT NULL,
          $_workingMinutsColumnName INTEGER NOT NULL
        )
        ''');
      },
      readOnly: false,
    );
    return database;
  }

  Future<void> addEntry(String year, String month, String week, String day, int minutes) async {
    final db = await database;
    await db.insert(
      _workingTableName,
      {
        _workingYearColumnName: year,
        _workingMonthColumnName: month,
        _workingWeekColumnName: week,
        _workingDayColumnName: day,
        _workingMinutsColumnName: minutes,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await database;
    return db.query(_workingTableName);
  }

    Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete(
      _workingTableName,
      where: '$_workingIdName = ?',
      whereArgs: [id],
    );
  }

}
