import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:new_koperasi_apps/app/model/customer.dart';
import 'package:new_koperasi_apps/app/model/document.dart';
import 'package:new_koperasi_apps/app/utils/app_paths.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase extends GetxService {
  late final Database db;
  bool _initialized = false;

  Future<AppDatabase> init() async {
    if (_initialized) return this;
    final path = await AppPaths.dbPath('koperasi.db');
    db = await databaseFactory.openDatabase(path);
    // Create tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        year INTEGER NOT NULL,
        rack TEXT NOT NULL,
        box TEXT NOT NULL,
        file_path TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nik TEXT NOT NULL,
        address TEXT NOT NULL,
        status TEXT NOT NULL,
        phone TEXT
      );
    ''');
    _initialized = true;
    return this;
  }

  // AppDatabase() {
  //   init();
  // }

  // DOCUMENTS CRUD
  Future<int> insertDocument(Document d) async {
    return db.insert('documents', d.toMap());
  }

  // Future<List<Document>> searchDocuments(String keyword) async {
  //   final k = '%${keyword.trim()}%';
  //   final rows = await db.rawQuery(
  //     '''
  //     SELECT * FROM documents
  //     WHERE title LIKE ? OR cast(year as TEXT) LIKE ? OR rack LIKE ? OR box LIKE ?
  //     ORDER BY year DESC, title ASC
  //   ''',
  //     [k, k, k, k],
  //   );
  //   return rows.map(Document.fromRow).toList();
  // }

  // cari dokument berdasarkan judul
  // app_database.dart
  Future<List<Document>> searchDocumentsByTitle(String keyword) async {
    // final db = await database;

    try {
      if (keyword.isEmpty) {
        final result = await db.query(
          'documents',
          orderBy: 'title COLLATE NOCASE ASC',
        );
        return result.map((json) => Document.fromRow(json)).toList();
      }

      final result = await db.query(
        'documents',
        where: 'title LIKE ? COLLATE NOCASE',
        whereArgs: ['%$keyword%'],
        orderBy: 'title COLLATE NOCASE ASC',
      );

      return result.map((json) => Document.fromRow(json)).toList();
    } catch (e) {
      print('Error searching by title: $e');
      return [];
    }
  }

  Future<List<Document>> searchDocumentsByYear(String yearInput) async {
    // final db = await database;

    try {
      if (yearInput.isEmpty) {
        final result = await db.query(
          'documents',
          orderBy: 'year DESC, title ASC',
        );
        return result.map((json) => Document.fromRow(json)).toList();
      }

      final year = int.tryParse(yearInput);
      if (year == null) {
        // Jika input bukan angka, coba cari sebagai string
        final result = await db.query(
          'documents',
          where: 'year LIKE ?',
          whereArgs: ['%$yearInput%'],
          orderBy: 'year DESC, title ASC',
        );
        return result.map((json) => Document.fromRow(json)).toList();
      }

      final result = await db.query(
        'documents',
        where: 'year = ?',
        whereArgs: [year],
        orderBy: 'title ASC',
      );

      return result.map((json) => Document.fromRow(json)).toList();
    } catch (e) {
      print('Error searching by year: $e');
      return [];
    }
  }

  // Method lama searchDocuments (jika masih ada)
  Future<List<Document>> searchDocuments(String q) async {
    // final db = await database;

    try {
      if (q.isEmpty) {
        final result = await db.query('documents', orderBy: 'title ASC');
        return result.map((json) => Document.fromRow(json)).toList();
      }

      // Coba search by year dulu (jika input adalah angka)
      final year = int.tryParse(q);
      if (year != null) {
        final result = await db.query(
          'documents',
          where: 'year = ?',
          whereArgs: [year],
          orderBy: 'title ASC',
        );
        if (result.isNotEmpty) {
          return result.map((json) => Document.fromRow(json)).toList();
        }
      }

      // Jika tidak ditemukan by year, search by title
      final result = await db.query(
        'documents',
        where: 'title LIKE ?',
        whereArgs: ['%$q%'],
        orderBy: 'title ASC',
      );

      return result.map((json) => Document.fromRow(json)).toList();
    } catch (e) {
      print('Error searching documents: $e');
      return [];
    }
  }

  // delete document by id
  Future<void> deleteDocument(int id) =>
      db.delete('documents', where: 'id=?', whereArgs: [id]);

  // CUSTOMERS CRUD
  Future<int> insertCustomer(Customer c) => db.insert('customers', c.toMap());
  Future<int> updateCustomer(Customer c) =>
      db.update('customers', c.toMap(), where: 'id=?', whereArgs: [c.id]);
  Future<void> deleteCustomer(int id) =>
      db.delete('customers', where: 'id=?', whereArgs: [id]);

  Future<List<Customer>> listCustomers({String keyword = ''}) async {
    if (keyword.trim().isEmpty) {
      final rows = await db.rawQuery(
        'SELECT * FROM customers ORDER BY name ASC',
      );
      return rows.map(Customer.fromRow).toList();
    } else {
      final k = '%${keyword.trim()}%';
      final rows = await db.rawQuery(
        '''
        SELECT * FROM customers
        WHERE name LIKE ? OR nik LIKE ? OR address LIKE ? OR status LIKE ? OR phone LIKE ?
        ORDER BY name ASC
      ''',
        [k, k, k, k, k],
      );
      return rows.map(Customer.fromRow).toList();
    }
  }
}
