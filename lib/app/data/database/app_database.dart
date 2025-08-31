import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:new_koperasi_apps/app/model/customer.dart';
import 'package:new_koperasi_apps/app/model/document.dart';
import 'package:new_koperasi_apps/app/utils/app_paths.dart';
import 'dart:io';

part 'app_database.g.dart';

@DataClassName('DbDocument')
class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get year => integer()();
  TextColumn get rack => text()();
  TextColumn get ambalan => text()();
  TextColumn get box => text()();
  TextColumn get filePath => text().named('file_path')();
}

@DataClassName('DbCustomer')
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nik => text()();
  TextColumn get address => text()();
  TextColumn get status => text()();
  TextColumn get phone => text().nullable()();
}

@DriftDatabase(tables: [Documents, Customers])
class AppDatabase extends _$AppDatabase {
  @override
  bool _initialized = false;

  AppDatabase._internal(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  static Future<AppDatabase> create() async {
    final path = await AppPaths.dbPath('koperasi.db');
    final file = File(path);
    return AppDatabase._internal(NativeDatabase(file));
  }

  Future<void> resetDatabase() async {
    // tutup koneksi dulu
    await close();

    final path = await AppPaths.dbPath('koperasi.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print("✅ Database deleted: $path");
    } else {
      print("⚠️ Database file not found at $path");
    }
  }

  Future<void> deleteDbFile() async {
    final path = await AppPaths.dbPath('koperasi.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print("✅ Database deleted: $path");
    } else {
      print("⚠️ Database file not found at $path");
    }
  }

  Future<List<Document>> getAllDocuments() async {
    final rows = await select(documents).get();
    return rows
        .map(
          (e) => Document(
            id: e.id,
            title: e.title,
            year: e.year,
            rack: e.rack,
            ambalan: e.ambalan,
            box: e.box,
            filePath: e.filePath,
          ),
        )
        .toList();
  }

  Future<AppDatabase> init() async {
    if (_initialized) return this;
    // Drift otomatis create1 table
    _initialized = true;
    // await resetDatabase();
    return this;
  }

  // DOCUMENTS CRUD
  Future<int> insertDocument(Document d) async {
    return into(documents).insert(
      DocumentsCompanion.insert(
        title: d.title,
        year: d.year,
        rack: d.rack,
        ambalan: d.ambalan,
        box: d.box,
        filePath: d.filePath,
      ),
    );
  }

  Future<List<Document>> searchDocumentsByTitle(String keyword) async {
    try {
      if (keyword.isEmpty) {
        final result = await (select(
          documents,
        )..orderBy([(t) => OrderingTerm.asc(t.title)])).get();
        return result.map(_mapDbDocToModel).toList();
      }

      final result =
          await (select(documents)
                ..where(
                  (tbl) => tbl.title.lower().like('%${keyword.toLowerCase()}%'),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.title)]))
              .get();

      return result.map(_mapDbDocToModel).toList();
    } catch (e) {
      print('Error searching by title: $e');
      return [];
    }
  }

  Document _mapDbDocToModel(DbDocument dbDoc) {
    return Document(
      id: dbDoc.id,
      title: dbDoc.title,
      year: dbDoc.year,
      rack: dbDoc.rack,
      ambalan: dbDoc.ambalan,
      box: dbDoc.box,
      filePath: dbDoc.filePath,
    );
  }

  Future<List<Document>> searchDocumentsByYear(String yearInput) async {
    try {
      if (yearInput.isEmpty) {
        final result =
            await (select(documents)..orderBy([
                  (t) => OrderingTerm.desc(t.year),
                  (t) => OrderingTerm.asc(t.title),
                ]))
                .get();
        return result.map(_mapDbDocToModel).toList();
      }

      final year = int.tryParse(yearInput);
      if (year != null) {
        final result =
            await (select(documents)
                  ..where((tbl) => tbl.year.equals(year))
                  ..orderBy([(t) => OrderingTerm.asc(t.title)]))
                .get();
        return result.map(_mapDbDocToModel).toList();
      }

      final result =
          await (select(documents)
                ..where(
                  (tbl) =>
                      tbl.title.lower().like('%${yearInput.toLowerCase()}%'),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.title)]))
              .get();

      return result.map(_mapDbDocToModel).toList();
    } catch (e) {
      print('Error searching by year: $e');
      return [];
    }
  }

  Future<List<Document>> searchDocuments(String q) async {
    try {
      if (q.isEmpty) {
        final result = await (select(
          documents,
        )..orderBy([(t) => OrderingTerm.asc(t.title)])).get();
        return result.map((row) => Document.fromRow(row.toJson())).toList();
      }

      final year = int.tryParse(q);
      if (year != null) {
        final result =
            await (select(documents)
                  ..where((tbl) => tbl.year.equals(year))
                  ..orderBy([(t) => OrderingTerm.asc(t.title)]))
                .get();
        if (result.isNotEmpty) {
          return result.map((row) => Document.fromRow(row.toJson())).toList();
        }
      }

      final result =
          await (select(documents)
                ..where((tbl) => tbl.title.like('%$q%'))
                ..orderBy([(t) => OrderingTerm.asc(t.title)]))
              .get();

      return result.map((row) => Document.fromRow(row.toJson())).toList();
    } catch (e) {
      print('Error searching documents: $e');
      return [];
    }
  }

  Future<void> deleteDocument(int id) =>
      (delete(documents)..where((tbl) => tbl.id.equals(id))).go();

  // CUSTOMERS CRUD
  Future<int> insertCustomer(Customer c) {
    return into(customers).insert(
      CustomersCompanion.insert(
        name: c.name,
        nik: c.nik,
        address: c.address,
        status: c.status,
        phone: Value(c.phone),
      ),
    );
  }

  Future<int> updateCustomer(Customer c) {
    if (c.id == null) {
      throw ArgumentError('Customer id cannot be null for update.');
    }
    return (update(customers)..where((tbl) => tbl.id.equals(c.id!))).write(
      CustomersCompanion(
        name: Value(c.name),
        nik: Value(c.nik),
        address: Value(c.address),
        status: Value(c.status),
        phone: Value(c.phone),
      ),
    );
  }

  Future<void> deleteCustomer(int id) =>
      (delete(customers)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Customer>> listCustomers({String keyword = ''}) async {
    if (keyword.trim().isEmpty) {
      final rows = await (select(
        customers,
      )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
      return rows.map((row) => Customer.fromRow(row.toJson())).toList();
    } else {
      final k = '%${keyword.trim()}%';
      final rows =
          await (select(customers)
                ..where(
                  (tbl) =>
                      tbl.name.like(k) |
                      tbl.nik.like(k) |
                      tbl.address.like(k) |
                      tbl.status.like(k) |
                      tbl.phone.like(k),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.name)]))
              .get();
      return rows.map((row) => Customer.fromRow(row.toJson())).toList();
    }
  }
}
