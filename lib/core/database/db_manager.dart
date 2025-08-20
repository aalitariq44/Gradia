import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DbManager {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize FFI for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gradia_school_management.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL DEFAULT 'admin',
        password_hash TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create schools table
    await db.execute('''
      CREATE TABLE schools (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_ar TEXT NOT NULL,
        name_en TEXT,
        logo_path TEXT,
        address TEXT,
        phone TEXT,
        principal_name TEXT,
        school_types TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        national_id_number TEXT,
        school_id INTEGER NOT NULL,
        grade TEXT NOT NULL,
        section TEXT NOT NULL,
        academic_year TEXT,
        gender TEXT NOT NULL,
        phone TEXT,
        guardian_name TEXT,
        guardian_phone TEXT,
        total_fee REAL NOT NULL,
        start_date TEXT NOT NULL,
        status TEXT DEFAULT 'نشط',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES schools (id)
      )
    ''');

    // Create installments table
    await db.execute('''
      CREATE TABLE installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        payment_time TEXT NOT NULL,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    // Create additional_fees table
    await db.execute('''
      CREATE TABLE additional_fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        fee_type TEXT NOT NULL,
        amount REAL NOT NULL,
        paid INTEGER DEFAULT 0,
        payment_date TEXT,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    // Create external_income table
    await db.execute('''
      CREATE TABLE external_income (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        school_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        category TEXT NOT NULL,
        income_type TEXT NOT NULL,
        description TEXT,
        income_date DATE NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_external_income_school_id ON external_income(school_id)',
    );
    await db.execute(
      'CREATE INDEX idx_external_income_category ON external_income(category)',
    );
    await db.execute(
      'CREATE INDEX idx_external_income_date ON external_income(income_date)',
    );
    await db.execute(
      'CREATE INDEX idx_additional_fees_student_id ON additional_fees(student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_additional_fees_paid ON additional_fees(paid)',
    );

    // Insert default admin user (password: admin123)
    await db.insert('users', {
      'username': 'admin',
      'password_hash':
          'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', // SHA-256 of 'admin123'
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add external_income table for version 2
      await db.execute('''
        CREATE TABLE external_income (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          school_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          amount DECIMAL(10,2) NOT NULL,
          category TEXT NOT NULL,
          income_type TEXT NOT NULL,
          description TEXT,
          income_date DATE NOT NULL,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for better performance
      await db.execute(
        'CREATE INDEX idx_external_income_school_id ON external_income(school_id)',
      );
      await db.execute(
        'CREATE INDEX idx_external_income_category ON external_income(category)',
      );
      await db.execute(
        'CREATE INDEX idx_external_income_date ON external_income(income_date)',
      );
      await db.execute(
        'CREATE INDEX idx_additional_fees_student_id ON additional_fees(student_id)',
      );
      await db.execute(
        'CREATE INDEX idx_additional_fees_paid ON additional_fees(paid)',
      );
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
