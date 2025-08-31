import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_koperasi_apps/app/data/database/app_database.dart';
import 'package:new_koperasi_apps/app/utils/app_paths.dart';
import 'package:new_koperasi_apps/app/utils/generate_placeholder_pdf.dart';
import 'package:new_koperasi_apps/app/utils/sanitize_file_name.dart';
import 'package:path/path.dart' as p;

import '../../../model/document.dart';

class DocumentController extends GetxController {
  final db = Get.find<AppDatabase>();
  final searchCtrl = TextEditingController();
  final isLoading = false.obs;
  final results = <Document>[].obs;
  final searchBy = 'year'.obs;
  final formKey = GlobalKey<FormState>();
  var placeholderCreated = false.obs;
  // File? selectedFile;
  var selectedFile = Rxn<File>();

  // String? filePath;

  @override
  void onInit() {
    super.onInit();
    // _seedIfEmpty();
    doSearch('');
  }

  Future<void> uploadPdfDocument() async {
    // Pilih file PDF terlebih dahulu
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );

    if (file == null) {
      Get.snackbar(
        'Info',
        'Upload dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String filePath = file.path;
    // final String fileName = file.name;

    // Langsung buka dialog form dengan file yang sudah dipilih
    final title = TextEditingController();
    final year = TextEditingController(text: DateTime.now().year.toString());
    final rack = TextEditingController();
    final ambalan = TextEditingController();
    final box = TextEditingController();
    selectedFile.value = File(file.path);

    bool? result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Tambah Dokumen"),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 500,

            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 16),

                // Judul
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(
                    hintText: "Judul",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Judul wajib diisi"
                      : null,
                ),
                SizedBox(height: 16),

                // Tahun
                TextFormField(
                  controller: year,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Tahun",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Tahun wajib diisi";
                    if (int.tryParse(value) == null) return "Tahun harus angka";
                    return null;
                  },
                ),
                SizedBox(height: 16),
                const SizedBox(width: 10),
                // Rak
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: rack,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Blok",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Nomor Blok wajib diisi"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: TextFormField(
                        controller: ambalan,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Ambalan",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Ambalan wajib diisi"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: TextFormField(
                        controller: box,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Box",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Box wajib diisi"
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // File PDF
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        height: 50,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Obx(() {
                          final file = selectedFile.value;
                          return Text(
                            file?.path.split(Platform.pathSeparator).last ??
                                "Belum ada file dipilih",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ["pdf"],
                        );
                        if (result != null) {
                          selectedFile.value = File(result.files.single.path!);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // batal -> langsung close
              Get.back();
            },
            child: const Text("Batal"),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (selectedFile.value == null) {
                  Get.snackbar(
                    "Error",
                    "Pilih file PDF terlebih dahulu",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                final d = DocumentsCompanion.insert(
                  title: title.text,
                  year: int.parse(year.text),
                  rack: rack.text,
                  ambalan: ambalan.text,
                  box: box.text,
                  filePath: selectedFile.value!.path,
                );

                await db.into(db.documents).insert(d);

                // refresh list
                await doSearch("");

                // close dialog setelah berhasil
                Get.back();

                Get.snackbar(
                  "Sukses",
                  "Dokumen berhasil disimpan",
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
      barrierDismissible: false, // biar ga bisa tutup dengan klik luar
    );

    // Jika user klik Simpan Dokumen (result = true)
    if (result == true) {
      try {
        isLoading.value = true;

        // Baca file yang dipilih
        final originalFile = XFile(filePath);
        final bytes = await originalFile.readAsBytes();

        // Simpan ke direktori aplikasi
        final pdfDir = await AppPaths.ensureSubdir('pdf');
        final sanitizedFileName = SanitizeFileName(
          '${title.text}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        final newPath = p.join(pdfDir, sanitizedFileName);

        await File(newPath).writeAsBytes(bytes, flush: true);

        final d = Document(
          title: title.text,
          year: int.parse(year.text),
          rack: rack.text,
          ambalan: ambalan.text,
          box: box.text,
          filePath: newPath,
        );

        await db.insertDocument(d);
        // refresh list
        await doSearch(searchCtrl.text);

        // 🚀 ini yang bikin dialog close
        Get.back();
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Terjadi kesalahan saat mengupload file: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.transparent,
          // snackStyle: SnackStyle.FLOATING,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> doSearch(String query) async {
    isLoading.value = true;

    if (query.isEmpty) {
      results.value = await db.getAllDocuments();
    } else {
      if (searchBy.value == 'title') {
        results.value = await db.searchDocumentsByTitle(query);
      } else {
        final year = int.tryParse(query);
        if (year != null) {
          results.value = await db.searchDocumentsByYear("$year");
        } else {
          results.clear();
        }
      }
    }

    isLoading.value = false;
  }
  // Future<void> doSearch(String q) async {
  //   isLoading.value = true;
  //   results.assignAll(await db.searchDocuments(q));
  //   isLoading.value = false;
  // }

  void toggleSearchMode() {
    if (searchBy.value == 'title') {
      searchBy.value = 'year';
      searchCtrl.clear();
      doSearch('');
    } else {
      searchBy.value = 'title';
      searchCtrl.clear();
      doSearch('');
    }
  }

  Future<void> addDocumentDialog() async {
    final title = TextEditingController();
    final year = TextEditingController(text: DateTime.now().year.toString());
    final rack = TextEditingController();
    final ambalan = TextEditingController();
    final box = TextEditingController();
    String? filePath;
    placeholderCreated.value = false;
    filePath = null;

    await Get.dialog(
      AlertDialog(
        title: const Text('Tambah Dokumen'),
        content: SizedBox(
          width: 500, // Lebarkan dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // JUDUL
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  hintText: 'Judul Dokumen *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TAHUN
              TextField(
                controller: year,
                decoration: const InputDecoration(
                  hintText: 'Tahun *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // RAK DAN BOX DALAM ROW
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rack,
                      decoration: const InputDecoration(
                        hintText: 'Nomor Blok *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ambalan,
                      decoration: const InputDecoration(
                        hintText: 'Nomor Ambalan *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: box,
                      decoration: const InputDecoration(
                        hintText: 'Nomor Box *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TOMBOL BUAT PDF
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'File PDF',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Obx(
                      () => placeholderCreated.value
                          ? Text(
                              'PDF Placeholder sudah dibuat',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.green.shade700,
                              ),
                            )
                          : const Text(
                              'Belum ada file PDF',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),

                    Obx(
                      () => FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            placeholderCreated.value
                                ? Colors.green
                                : Colors.grey, // warna berubah
                          ),
                        ),
                        onPressed: () async {
                          if (title.text.isEmpty) {
                            Get.snackbar(
                              'Perhatian',
                              'Silakan isi judul dokumen terlebih dahulu',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.transparent,
                            );
                            return;
                          }

                          // generate placeholder PDF
                          final bytes = await GeneratePlaceholderPdf(
                            title.text,
                            int.tryParse(year.text) ?? DateTime.now().year,
                          );
                          final pdfDir = await AppPaths.ensureSubdir('pdf');
                          final fname =
                              'doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
                          final path = p.join(pdfDir, fname);
                          await File(path).writeAsBytes(bytes, flush: true);

                          filePath = path;
                          placeholderCreated.value = true; // ✅ ubah state
                        },
                        child: Text(
                          placeholderCreated.value
                              ? 'Placeholder Berhasil Dibuat'
                              : 'Buat PDF Placeholder',
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      '* PDF placeholder akan dibuat otomatis dengan judul dan tahun yang diisi',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // INFORMASI WAJIB DIISI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Semua field bertanda * wajib diisi. PDF placeholder akan dibuat otomatis.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              // VALIDASI LENGKAP
              if (title.text.isEmpty) {
                Get.snackbar(
                  'Gagal',
                  'Judul dokumen harus diisi',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
                return;
              }

              if (year.text.isEmpty || int.tryParse(year.text) == null) {
                Get.snackbar(
                  'Gagal',
                  'Tahun harus berupa angka yang valid',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
                return;
              }

              if (rack.text.isEmpty) {
                Get.snackbar(
                  'Gagal',
                  'Nomor rak harus diisi',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
                return;
              }

              if (ambalan.text.isEmpty) {
                Get.snackbar(
                  'Gagal',
                  'Nomor ambalan harus diisi',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
                return;
              }

              if (box.text.isEmpty) {
                Get.snackbar(
                  'Gagal',
                  'Nomor box harus diisi',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
                return;
              }

              if (filePath == null) {
                Get.snackbar(
                  'Gagal',
                  'Silakan buat PDF placeholder terlebih dahulu',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
                return;
              }

              final d = Document(
                title: title.text,
                year: int.tryParse(year.text) ?? DateTime.now().year,
                rack: rack.text,
                ambalan: ambalan.text,
                box: box.text,
                filePath: filePath!,
              );

              try {
                await db.insertDocument(d);
                await doSearch(searchCtrl.text);
                Get.back();

                Get.snackbar(
                  'Berhasil',
                  'Dokumen "${title.text}" berhasil ditambahkan',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
              } catch (e) {
                Get.snackbar(
                  'Gagal',
                  'Terjadi kesalahan: $e',
                  colorText: const Color.fromARGB(255, 66, 6, 2),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.transparent,
                );
              }
            },
            child: const Text('Simpan Dokumen'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      barrierDismissible: false,
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
      suggestedName: '${SanitizeFileName(d.title)}_${d.year}.pdf',
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

  // Future<void> _seedIfEmpty() async {
  //   final hasAny = (await db.searchDocuments('')).isNotEmpty;
  //   if (hasAny) return;
  //   final pdfDir = await AppPaths.ensureSubdir('pdf');
  // for (final year in [2023, 2024, 2025]) {
  //   final bytes = await GeneratePlaceholderPdf('Laporan Tahunan', year);
  //   final path = p.join(pdfDir, 'laporan_$year.pdf');
  //   await File(path).writeAsBytes(bytes);
  //   await db.insertDocument(
  //     Document(
  //       title: 'Laporan Tahunan',
  //       year: year,
  //       rack: 'R-$year',
  //       box: 'B-${year % 10}',
  //       filePath: path,
  //     ),
  //   );
  // }
}
