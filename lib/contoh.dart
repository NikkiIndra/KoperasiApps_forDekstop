import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init SQLite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Register database (tunggu init selesai)
  await Get.putAsync<AppDatabase>(() async => await AppDatabase().init());

  // Register controllers
  Get.put<AppRouter>(AppRouter());
  Get.put<DocumentController>(DocumentController());
  Get.put<CustomerController>(CustomerController());

  runApp(const KoperasiApp());
}

class KoperasiApp extends StatelessWidget {
  const KoperasiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Koperasi Desktop',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.documents,
      getPages: AppRouter.pages,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.black12.withOpacity(.06)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        dataTableTheme: const DataTableThemeData(
          headingRowColor: WidgetStatePropertyAll(Color(0xFFF7F8FC)),
          headingTextStyle: TextStyle(fontWeight: FontWeight.w600),
          dividerThickness: .6,
        ),
      ),
    );
  }
}

/* ------------------------------- ROUTING ------------------------------- */

class Routes {
  static const documents = '/';
  static const customers = '/customers';
}

class AppRouter {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.documents,
      page: () => const DocumentSearchPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.customers,
      page: () => const CustomersPage(),
      transition: Transition.fadeIn,
    ),
  ];
}

/* ---------------------------- DATABASE LAYER --------------------------- */

class AppDatabase extends GetxService {
  late final Database db;
  bool _initialized = false;

  Future<AppDatabase> init() async {
    if (_initialized) return this;
    final path = await _AppPaths.dbPath('koperasi.db');
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

  Future<List<Document>> searchDocuments(String keyword) async {
    final k = '%${keyword.trim()}%';
    final rows = await db.rawQuery(
      '''
      SELECT * FROM documents
      WHERE title LIKE ? OR cast(year as TEXT) LIKE ? OR rack LIKE ? OR box LIKE ?
      ORDER BY year DESC, title ASC
    ''',
      [k, k, k, k],
    );
    return rows.map(Document.fromRow).toList();
  }

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

/* ------------------------------- MODELS -------------------------------- */

class Document {
  final int? id;
  final String title;
  final int year;
  final String rack;
  final String box;
  final String filePath; // local path to PDF

  Document({
    this.id,
    required this.title,
    required this.year,
    required this.rack,
    required this.box,
    required this.filePath,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'year': year,
    'rack': rack,
    'box': box,
    'file_path': filePath,
  };

  static Document fromRow(Map<String, Object?> row) => Document(
    id: row['id'] as int?,
    title: row['title'] as String,
    year: (row['year'] as num).toInt(),
    rack: row['rack'] as String,
    box: row['box'] as String,
    filePath: row['file_path'] as String,
  );
}

class Customer {
  final int? id;
  final String name;
  final String nik;
  final String address;
  final String status;
  final String? phone;

  Customer({
    this.id,
    required this.name,
    required this.nik,
    required this.address,
    required this.status,
    this.phone,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'nik': nik,
    'address': address,
    'status': status,
    'phone': phone,
  };

  static Customer fromRow(Map<String, Object?> row) => Customer(
    id: row['id'] as int?,
    name: row['name'] as String,
    nik: row['nik'] as String,
    address: row['address'] as String,
    status: row['status'] as String,
    phone: row['phone'] as String?,
  );

  Customer copyWith({
    int? id,
    String? name,
    String? nik,
    String? address,
    String? status,
    String? phone,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    nik: nik ?? this.nik,
    address: address ?? this.address,
    status: status ?? this.status,
    phone: phone ?? this.phone,
  );
}

/* ----------------------------- CONTROLLERS ----------------------------- */

class DocumentController extends GetxController {
  final db = Get.find<AppDatabase>();
  final searchCtrl = TextEditingController();
  final isLoading = false.obs;
  final results = <Document>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedIfEmpty();
    doSearch('');
  }

  Future<void> doSearch(String q) async {
    isLoading.value = true;
    results.assignAll(await db.searchDocuments(q));
    isLoading.value = false;
  }

  Future<void> addDocumentDialog() async {
    final title = TextEditingController();
    final year = TextEditingController();
    final rack = TextEditingController();
    final box = TextEditingController();
    String? filePath;

    await Get.dialog(
      AlertDialog(
        title: const Text('Tambah Dokumen'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: year,
                decoration: const InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rack,
                      decoration: const InputDecoration(labelText: 'Nomor Rak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: box,
                      decoration: const InputDecoration(labelText: 'Nomor Box'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: () async {
                    // generate placeholder PDF and store in app dir
                    final bytes = await _generatePlaceholderPdf(
                      title.text.isEmpty ? 'Dokumen Baru' : title.text,
                      int.tryParse(year.text) ?? DateTime.now().year,
                    );
                    final pdfDir = await _AppPaths.ensureSubdir('pdf');
                    final fname =
                        'doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
                    final path = p.join(pdfDir, fname);
                    await File(path).writeAsBytes(bytes, flush: true);
                    filePath = path;
                    Get.snackbar(
                      'File',
                      'PDF tersimpan di lokal',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('Buat PDF Placeholder'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (filePath == null) {
                Get.snackbar(
                  'Gagal',
                  'Silakan buat/sediakan PDF dulu.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.amber.shade100,
                );
                return;
              }
              final d = Document(
                title: title.text,
                year: int.tryParse(year.text) ?? DateTime.now().year,
                rack: rack.text,
                box: box.text,
                filePath: filePath!,
              );
              await db.insertDocument(d);
              await doSearch(searchCtrl.text);
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteDoc(int id) async {
    await db.deleteDocument(id);
    await doSearch(searchCtrl.text);
  }

  Future<void> downloadPdf(Document d) async {
    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
      suggestedName: '${_sanitizeFileName(d.title)}_${d.year}.pdf',
    );

    if (saveLocation == null) return; // user cancel

    final src = File(d.filePath);
    if (!await src.exists()) {
      Get.snackbar(
        'File tidak ada',
        'PDF sumber tidak ditemukan di perangkat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final file = XFile.fromData(
      await src.readAsBytes(),
      name: p.basename(saveLocation.path),
      mimeType: 'application/pdf',
    );

    await file.saveTo(saveLocation.path);

    Get.snackbar(
      'Berhasil',
      'PDF diunduh ke ${saveLocation.path}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
    );
  }

  Future<void> _seedIfEmpty() async {
    final hasAny = (await db.searchDocuments('')).isNotEmpty;
    if (hasAny) return;
    final pdfDir = await _AppPaths.ensureSubdir('pdf');
    for (final year in [2023, 2024, 2025]) {
      final bytes = await _generatePlaceholderPdf('Laporan Tahunan', year);
      final path = p.join(pdfDir, 'laporan_$year.pdf');
      await File(path).writeAsBytes(bytes);
      await db.insertDocument(
        Document(
          title: 'Laporan Tahunan',
          year: year,
          rack: 'R-$year',
          box: 'B-${year % 10}',
          filePath: path,
        ),
      );
    }
  }
}

class CustomerController extends GetxController {
  final db = Get.find<AppDatabase>();
  final searchCtrl = TextEditingController();
  final isLoading = false.obs;
  final items = <Customer>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedIfEmpty();
    refreshList();
  }

  Future<void> refreshList() async {
    isLoading.value = true;
    items.assignAll(await db.listCustomers(keyword: searchCtrl.text));
    isLoading.value = false;
  }

  Future<void> addOrEdit({Customer? initial}) async {
    final name = TextEditingController(text: initial?.name);
    final nik = TextEditingController(text: initial?.nik);
    final address = TextEditingController(text: initial?.address);
    final status = TextEditingController(text: initial?.status);
    final phone = TextEditingController(text: initial?.phone);

    await Get.dialog(
      AlertDialog(
        title: Text(initial == null ? 'Tambah Nasabah' : 'Edit Nasabah'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: nik,
                      decoration: const InputDecoration(labelText: 'NIK'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: status,
                      decoration: const InputDecoration(
                        labelText: 'Status (Aktif/Nonaktif)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: phone,
                      decoration: const InputDecoration(labelText: 'Telepon'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty || nik.text.trim().isEmpty) {
                Get.snackbar(
                  'Validasi',
                  'Nama dan NIK wajib diisi',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.amber.shade100,
                );
                return;
              }
              if (initial == null) {
                await db.insertCustomer(
                  Customer(
                    name: name.text.trim(),
                    nik: nik.text.trim(),
                    address: address.text.trim(),
                    status: status.text.trim().isEmpty
                        ? 'Aktif'
                        : status.text.trim(),
                    phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                  ),
                );
              } else {
                await db.updateCustomer(
                  initial.copyWith(
                    name: name.text.trim(),
                    nik: nik.text.trim(),
                    address: address.text.trim(),
                    status: status.text.trim(),
                    phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                  ),
                );
              }
              await refreshList();
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> remove(int id) async {
    await db.deleteCustomer(id);
    await refreshList();
  }

  Future<void> _seedIfEmpty() async {
    final list = await db.listCustomers();
    if (list.isNotEmpty) return;
    await db.insertCustomer(
      Customer(
        name: 'Budi Santoso',
        nik: '317xxxxxxxxxxx',
        address: 'Jl. Melati No. 10',
        status: 'Aktif',
        phone: '0812-0000-1111',
      ),
    );
    await db.insertCustomer(
      Customer(
        name: 'Siti Aminah',
        nik: '320xxxxxxxxxxx',
        address: 'Jl. Anggrek No. 2',
        status: 'Nonaktif',
        phone: '0813-2222-3333',
      ),
    );
  }
}

/* ------------------------------- UI PAGES ------------------------------- */

class Shell extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? trailing;
  final Widget? topActions;
  const Shell({
    super.key,
    required this.child,
    required this.title,
    this.trailing,
    this.topActions,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: isWide ? 260 : 72,
            margin: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      if (isWide)
                        const Text(
                          'KoperasiFy',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _SideItem(
                  icon: Icons.search,
                  label: 'Pencarian Dokumen',
                  selected: Get.currentRoute == Routes.documents,
                  onTap: () => Get.offAllNamed(Routes.documents),
                  extended: isWide,
                ),
                _SideItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Data Nasabah',
                  selected: Get.currentRoute == Routes.customers,
                  onTap: () => Get.offAllNamed(Routes.customers),
                  extended: isWide,
                ),
                const Spacer(),
                if (isWide)
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person),
                    ),
                    title: const Text('Admin', style: TextStyle(fontSize: 13)),
                    subtitle: const Text('Operator'),
                    trailing: FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('Logout'),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (topActions != null) topActions!,
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 260,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search…',
                              suffixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (_) {},
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          child: Icon(Icons.notifications_none),
                        ),
                        const SizedBox(width: 8),
                        trailing ?? const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool extended;

  const _SideItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color(0xFF6366F1) : Colors.black54,
      ),
      title: extended ? Text(label) : null,
      selected: selected,
      onTap: onTap,
      selectedTileColor: const Color(0xFFEFF0FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dense: true,
    );
  }
}

/* ------------------------- DOCUMENT SEARCH PAGE ------------------------ */

class DocumentSearchPage extends GetView<DocumentController> {
  const DocumentSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: 'Pencarian Dokumen Koperasi',
      topActions: Row(
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: controller.searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Ketik kata kunci (mis: 2025)',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: controller.doSearch,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => controller.doSearch(controller.searchCtrl.text),
            icon: const Icon(Icons.search),
            label: const Text('Cari'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: controller.addDocumentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Dokumen'),
          ),
        ],
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = controller.results;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil Pencarian',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Judul')),
                        DataColumn(label: Text('Tahun')),
                        DataColumn(label: Text('Lokasi Fisik (Rak/Box)')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: rows.map((d) {
                        return DataRow(
                          cells: [
                            DataCell(Text(d.title)),
                            DataCell(Text('${d.year}')),
                            DataCell(Text('${d.rack} / ${d.box}')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Unduh PDF',
                                    onPressed: () => controller.downloadPdf(d),
                                    icon: const Icon(Icons.download),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    onPressed: () =>
                                        controller.deleteDoc(d.id!),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/* ---------------------------- CUSTOMERS PAGE --------------------------- */

class CustomersPage extends GetView<CustomerController> {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: 'Manage Nasabah',
      topActions: Row(
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: controller.searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari nama/NIK/alamat…',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => controller.refreshList(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: controller.refreshList,
            icon: const Icon(Icons.search),
            label: const Text('Cari'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () => controller.addOrEdit(),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Tambah Nasabah'),
          ),
        ],
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = controller.items;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Nasabah',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('NIK')),
                        DataColumn(label: Text('Alamat')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Telepon')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: items.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text(c.name)),
                            DataCell(Text(c.nik)),
                            DataCell(Text(c.address)),
                            DataCell(_StatusChip(text: c.status)),
                            DataCell(Text(c.phone ?? '-')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () =>
                                        controller.addOrEdit(initial: c),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    onPressed: () => controller.remove(c.id!),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  const _StatusChip({required this.text});
  @override
  Widget build(BuildContext context) {
    final active = text.toLowerCase().contains('aktif');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F6EA) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
        ),
      ),
    );
  }
}

/* ------------------------------ UTILITIES ------------------------------ */

// class _AppPaths {
//   static Future<String> appDirectory() async {
//     final dir = await getApplicationDocumentsDirectory();
//     return p.join(dir.path, 'koperasi_desktop');
//     // On web this path_provider differs, but app is desktop-first.
//   }

//   static Future<String> dbPath(String name) async {
//     final dir = await appDirectory();
//     return p.join(dir, name);
//   }

//   static Future<String> ensureSubdir(String sub) async {
//     final base = await appDirectory();
//     final d = Directory(p.join(base, sub));
//     if (!await d.exists()) await d.create(recursive: true);
//     return d.path;
//   }
// }
class _AppPaths {
  static Future<String> appDirectory() async {
    // Tentukan folder aplikasi secara manual untuk desktop
    final base = Directory.current.path; // folder tempat exe dijalankan
    final dir = Directory(p.join(base, 'koperasi_desktop'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<String> dbPath(String name) async {
    final dir = await appDirectory();
    return p.join(dir, name);
  }

  static Future<String> ensureSubdir(String sub) async {
    final dir = await appDirectory();
    final d = Directory(p.join(dir, sub));
    if (!await d.exists()) await d.create(recursive: true);
    return d.path;
  }
}

String _sanitizeFileName(String input) {
  return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
}

Future<Uint8List> _generatePlaceholderPdf(String title, int year) async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final fmt = DateFormat('dd MMM yyyy HH:mm');
  pdf.addPage(
    pw.Page(
      build: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.all(36),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Tahun: $year'),
            pw.SizedBox(height: 24),
            pw.Text('Dokumen placeholder untuk demonstrasi aplikasi koperasi.'),
            pw.Spacer(),
            pw.Text('Generated: ${fmt.format(now)}'),
          ],
        ),
      ),
    ),
  );
  return Uint8List.fromList(await pdf.save());
}
