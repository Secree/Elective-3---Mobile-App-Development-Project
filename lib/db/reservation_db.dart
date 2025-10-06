import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Reservation {
  final int? id;
  final String from;
  final String to;
  final DateTime createdAt;

  Reservation({this.id, required this.from, required this.to, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'origin': from,
    'destination': to,
    'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() => 'Reservation{id: $id, from: $from, to: $to, at: $createdAt}';

  static Reservation fromMap(Map<String, dynamic> m) => Reservation(
        id: m['id'] as int?,
        from: m['origin'] as String,
        to: m['destination'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}

class ReservationDatabase {
  static final ReservationDatabase instance = ReservationDatabase._init();
  static Database? _database;
  ReservationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reservations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB, onOpen: (db) async {
      await _migrateIfNeeded(db);
    });
  }

  Future<void> _migrateIfNeeded(Database db) async {
    try {
      final info = await db.rawQuery("PRAGMA table_info('reservations')");
      final cols = info.map((e) => (e['name'] as String).toLowerCase()).toList();
      if (cols.contains('from') || cols.contains('to')) {
        // Perform migration: create new table, copy data mapping from->origin, to->destination
        await db.transaction((txn) async {
          await txn.execute('''
            CREATE TABLE IF NOT EXISTS reservations_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              origin TEXT NOT NULL,
              destination TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');

          // Use double quotes to reference possibly reserved column names
          await txn.execute('''
            INSERT INTO reservations_new (origin, destination, createdAt)
            SELECT "from", "to", createdAt FROM reservations;
          ''');

          await txn.execute('DROP TABLE reservations');
          await txn.execute('ALTER TABLE reservations_new RENAME TO reservations');
        });
      }
    } catch (e) {
      // If anything fails, ignore migration and allow normal behavior; errors will be visible in logs.
      // Don't rethrow to avoid crashing the app during open.
      // ignore: avoid_print
      print('Reservation DB migration error: $e');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE reservations (
      id $idType,
      origin $textType,
      destination $textType,
      createdAt $textType
    )
    ''');
  }

  Future<Reservation> create(Reservation r) async {
    final db = await instance.database;
    final id = await db.insert('reservations', r.toMap());
    return Reservation(id: id, from: r.from, to: r.to, createdAt: r.createdAt);
  }

  Future<List<Reservation>> all() async {
    final db = await instance.database;
    final maps = await db.query('reservations', orderBy: 'createdAt DESC');
    return maps.map((m) => Reservation.fromMap(m)).toList();
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
