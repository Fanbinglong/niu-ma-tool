import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'niu_ma_tool.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customer_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES customer_categories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        delivery_date TEXT NOT NULL,
        status TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE delivery_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        delivery_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');
  }

  // Customer Category Operations
  Future<int> insertCustomerCategory(Map<String, dynamic> category) async {
    final db = await database;
    category['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('customer_categories', category);
  }

  Future<List<Map<String, dynamic>>> getCustomerCategories() async {
    final db = await database;
    return await db.query('customer_categories', orderBy: 'created_at DESC');
  }

  Future<int> updateCustomerCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update(
      'customer_categories',
      category,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCustomerCategory(int id) async {
    final db = await database;
    return await db.delete(
      'customer_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Customer Operations
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    customer['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('customers', customer);
  }

  Future<List<Map<String, dynamic>>> getCustomers({int? categoryId}) async {
    final db = await database;
    if (categoryId != null) {
      return await db.query(
        'customers',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'name ASC',
      );
    }
    return await db.query('customers', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getCustomer(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateCustomer(int id, Map<String, dynamic> customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Order Operations
  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    order['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> getOrdersByDate(String date) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'delivery_date = ?',
      whereArgs: [date],
      orderBy: 'sort_order ASC',
    );
  }

  Future<int> updateOrderSortOrder(int id, int sortOrder) async {
    final db = await database;
    return await db.update(
      'orders',
      {'sort_order': sortOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delivery Record Operations
  Future<int> insertDeliveryRecord(Map<String, dynamic> record) async {
    final db = await database;
    record['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('delivery_records', record);
  }

  Future<List<Map<String, dynamic>>> getDeliveryRecords({int? days}) async {
    final db = await database;
    if (days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      return await db.query(
        'delivery_records',
        where: 'delivery_date >= ?',
        whereArgs: [cutoffDate],
        orderBy: 'delivery_date DESC',
      );
    }
    return await db.query('delivery_records', orderBy: 'delivery_date DESC');
  }

  Future<int> getDeliveryCountByDate(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM delivery_records WHERE delivery_date = ?',
      [date],
    );
    return result.first['count'] as int;
  }
}