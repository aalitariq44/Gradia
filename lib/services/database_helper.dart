import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'gradia.db');

    return await openDatabase(
      path,
      version: 5, // زيادة رقم الإصدار
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // ترقية من الإصدار 1 إلى 2 - تحديث جدول المدارس

      // إنشاء جدول جديد بالهيكلية المطلوبة
      await db.execute('''
        CREATE TABLE schools_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name_ar TEXT NOT NULL,
          name_en TEXT,
          logo_path TEXT,
          address TEXT,
          phone TEXT,
          principal_name TEXT,
          school_types TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // نسخ البيانات الموجودة من الجدول القديم إلى الجديد
      await db.execute('''
        INSERT INTO schools_new (id, name_ar, address, phone, school_types, created_at, updated_at)
        SELECT id, name, address, phone, 'ابتدائي', created_at, updated_at
        FROM schools
      ''');

      // حذف الجدول القديم
      await db.execute('DROP TABLE schools');

      // إعادة تسمية الجدول الجديد
      await db.execute('ALTER TABLE schools_new RENAME TO schools');
    }

    if (oldVersion < 3) {
      // ترقية من الإصدار 2 إلى 3 - تحديث جدول الطلاب

      // إنشاء جدول جديد بالهيكلية المطلوبة
      await db.execute('''
        CREATE TABLE students_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          national_id_number TEXT,
          school_id INTEGER NOT NULL,
          grade TEXT NOT NULL,
          section TEXT NOT NULL,
          academic_year TEXT,
          gender TEXT NOT NULL,
          phone TEXT,
          total_fee DECIMAL(10,2) NOT NULL,
          start_date DATE NOT NULL,
          status TEXT DEFAULT 'نشط',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
        )
      ''');

      // نسخ البيانات الموجودة من الجدول القديم إلى الجديد
      await db.execute('''
        INSERT INTO students_new (id, name, school_id, grade, section, gender, phone, total_fee, start_date, status, created_at, updated_at)
        SELECT id, name, school_id, 
               COALESCE(grade, 'الأول'),
               COALESCE(class_section, 'أ'),
               'ذكر',
               parent_phone,
               0.0,
               enrollment_date,
               CASE WHEN is_active = 1 THEN 'نشط' ELSE 'منقطع' END,
               created_at,
               updated_at
        FROM students
      ''');

      // حذف الجدول القديم
      await db.execute('DROP TABLE students');

      // إعادة تسمية الجدول الجديد
      await db.execute('ALTER TABLE students_new RENAME TO students');

      // إعادة إنشاء الفهارس
      await db.execute(
        'CREATE INDEX idx_students_school_id ON students (school_id)',
      );
      await db.execute('CREATE INDEX idx_students_name ON students (name)');
      await db.execute('CREATE INDEX idx_students_status ON students (status)');
    }

    if (oldVersion < 4) {
      // ترقية من الإصدار 3 إلى 4 - تحديث جدول الأقساط
      await db.execute('DROP TABLE IF EXISTS installments');

      // إنشاء جدول الأقساط الجديد
      await db.execute('''
        CREATE TABLE IF NOT EXISTS installments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          amount DECIMAL(10,2) NOT NULL,
          payment_date DATE NOT NULL,
          payment_time TIME NOT NULL,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
        )
      ''');

      // إنشاء فهارس جديدة
      await db.execute(
        'CREATE INDEX idx_installments_student_id ON installments (student_id)',
      );
      await db.execute(
        'CREATE INDEX idx_installments_date ON installments (payment_date)',
      );
    }

    if (oldVersion < 5) {
      // ترقية من الإصدار 4 إلى 5 - إضافة جدول الرسوم الإضافية
      await db.execute('''
        CREATE TABLE IF NOT EXISTS additional_fees (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id INTEGER NOT NULL,
          fee_type TEXT NOT NULL,
          amount DECIMAL(10,2) NOT NULL,
          paid BOOLEAN DEFAULT FALSE,
          payment_date DATE,
          added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
        )
      ''');

      // إنشاء فهارس للجدول الجديد
      await db.execute(
        'CREATE INDEX idx_additional_fees_student_id ON additional_fees (student_id)',
      );
      await db.execute(
        'CREATE INDEX idx_additional_fees_paid ON additional_fees (paid)',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // إنشاء جدول المستخدمين
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // إنشاء جدول المدارس
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // إنشاء جدول الطلاب
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
        total_fee DECIMAL(10,2) NOT NULL,
        start_date DATE NOT NULL,
        status TEXT DEFAULT 'نشط',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
      )
    ''');

    // إنشاء جدول الأقساط
    await db.execute('''
      CREATE TABLE IF NOT EXISTS installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        payment_date DATE NOT NULL,
        payment_time TIME NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');

    // إنشاء جدول الرسوم الإضافية
    await db.execute('''
      CREATE TABLE IF NOT EXISTS additional_fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        fee_type TEXT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        paid BOOLEAN DEFAULT FALSE,
        payment_date DATE,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');

    // إنشاء فهارس للبحث السريع
    await db.execute(
      'CREATE INDEX idx_students_school_id ON students (school_id)',
    );
    await db.execute('CREATE INDEX idx_students_name ON students (name)');
    await db.execute('CREATE INDEX idx_students_status ON students (status)');
    await db.execute(
      'CREATE INDEX idx_installments_student_id ON installments (student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_installments_date ON installments (payment_date)',
    );
    await db.execute(
      'CREATE INDEX idx_additional_fees_student_id ON additional_fees (student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_additional_fees_paid ON additional_fees (paid)',
    );

    // إدراج مستخدم افتراضي (admin/admin123)
    await db.execute('''
      INSERT INTO users (username, password_hash, full_name, role, created_at)
      VALUES ('admin', 'c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec', 'مدير النظام', 'admin', datetime('now'))
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
