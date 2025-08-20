import '../models/employee_model.dart';
import 'database_helper.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  // إضافة موظف جديد
  Future<int> insertEmployee(Employee employee) async {
    final db = await DatabaseHelper().database;
    final employeeMap = employee.toMap();
    employeeMap.remove('id'); // إزالة المعرف للإدراج
    return await db.insert('employees', employeeMap);
  }

  // الحصول على جميع الموظفين
  Future<List<Employee>> getAllEmployees() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  // الحصول على موظفين حسب المدرسة
  Future<List<Employee>> getEmployeesBySchool(int schoolId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  // الحصول على موظفين حسب نوع الوظيفة
  Future<List<Employee>> getEmployeesByJobType(String jobType) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'job_type = ?',
      whereArgs: [jobType],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  // البحث في الموظفين
  Future<List<Employee>> searchEmployees(String searchTerm) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'name LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  // البحث المفصل (بالاسم والمدرسة ونوع الوظيفة)
  Future<List<Employee>> searchEmployeesDetailed({
    String? name,
    int? schoolId,
    String? jobType,
  }) async {
    final db = await DatabaseHelper().database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClause += 'name LIKE ?';
      whereArgs.add('%$name%');
    }

    if (schoolId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'school_id = ?';
      whereArgs.add(schoolId);
    }

    if (jobType != null && jobType.isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'job_type = ?';
      whereArgs.add(jobType);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  // الحصول على موظف بالمعرف
  Future<Employee?> getEmployeeById(int id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    }
    return null;
  }

  // تحديث موظف
  Future<int> updateEmployee(Employee employee) async {
    final db = await DatabaseHelper().database;
    final employeeMap = employee.toMap();
    employeeMap['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'employees',
      employeeMap,
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  // حذف موظف
  Future<int> deleteEmployee(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  // الحصول على عدد الموظفين
  Future<int> getEmployeesCount() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM employees');
    return result.first['count'] as int;
  }

  // الحصول على عدد الموظفين حسب المدرسة
  Future<int> getEmployeesCountBySchool(int schoolId) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM employees WHERE school_id = ?',
      [schoolId],
    );
    return result.first['count'] as int;
  }

  // الحصول على عدد الموظفين حسب نوع الوظيفة
  Future<int> getEmployeesCountByJobType(String jobType) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM employees WHERE job_type = ?',
      [jobType],
    );
    return result.first['count'] as int;
  }

  // الحصول على إجمالي الرواتب
  Future<double> getTotalSalaries() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT SUM(monthly_salary) as total FROM employees',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // الحصول على أنواع الوظائف المختلفة
  Future<List<String>> getDistinctJobTypes() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT job_type FROM employees ORDER BY job_type ASC',
    );
    return maps.map((map) => map['job_type'] as String).toList();
  }

  // الحصول على الموظفين مع أسماء المدارس
  Future<List<Map<String, dynamic>>> getEmployeesWithSchoolNames() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.*, s.name as school_name 
      FROM employees e 
      LEFT JOIN schools s ON e.school_id = s.id 
      ORDER BY e.name ASC
    ''');
    return maps;
  }

  // حذف جميع الموظفين (للاختبار فقط)
  Future<void> deleteAllEmployees() async {
    final db = await DatabaseHelper().database;
    await db.delete('employees');
  }
}
