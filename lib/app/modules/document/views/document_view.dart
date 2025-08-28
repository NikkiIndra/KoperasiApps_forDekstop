import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/document_controller.dart';

class DocumentView extends GetView<DocumentController> {
  const DocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar dan tombol aksi
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: controller.searchCtrl,
              //         decoration: InputDecoration(
              //           labelText: 'Cari dokumen',
              //           suffixIcon: IconButton(
              //             icon: const Icon(Icons.search),
              //             onPressed: () =>
              //                 controller.doSearch(controller.searchCtrl.text),
              //           ),
              //         ),
              //         onSubmitted: (value) => controller.doSearch(value),
              //       ),
              //     ),
              //     const SizedBox(width: 8),
              //     FilledButton.icon(
              //       onPressed: () => controller.uploadPdfDocument(),
              //       icon: const Icon(Icons.upload_file),
              //       label: const Text('Upload PDF'),
              //     ),
              //     const SizedBox(width: 8),
              //     FilledButton.icon(
              //       onPressed: () => controller.addDocumentDialog(),
              //       icon: const Icon(Icons.add),
              //       label: const Text('Buat Baru'),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 16),

              // Tabel dokumen
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rows = controller.results;

                  if (rows.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Data tidak ditemukan",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (controller.searchCtrl.text.isNotEmpty)
                              FilledButton.tonal(
                                onPressed: () {
                                  controller.searchCtrl.clear();
                                  controller.doSearch('');
                                },
                                child: const Text('Kembali ke Semua Data'),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hasil Pencarian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              // horizontalMargin:
                              //     MediaQuery.of(context).size.width * 0.16,
                              columnSpacing: 200,
                              horizontalMargin: 20,
                              showBottomBorder: true,
                              // sortAscending: true,
                              columns: const [
                                DataColumn(label: Text('Judul')),
                                DataColumn(label: Text('Tahun')),
                                DataColumn(label: Text('Lokasi Fisik')),
                                DataColumn(label: Text('Path File')),
                                DataColumn(label: Text('Aksi')),
                              ],
                              rows: rows.map((d) {
                                return DataRow(
                                  cells: [
                                    // 1. Judul
                                    DataCell(Text(d.title)),

                                    // 2. Tahun
                                    DataCell(Text('${d.year}')),

                                    // 3. Lokasi Fisik
                                    DataCell(Text('${d.rack} / ${d.box}')),

                                    // 4. Path File
                                    DataCell(
                                      Tooltip(
                                        message: d
                                            .filePath, // Tampilkan full path saat dihover
                                        child: Text(
                                          d.filePath.length > 20
                                              ? '...${d.filePath.substring(d.filePath.length - 20)}'
                                              : d.filePath,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    // 5. Aksi
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Unduh PDF',
                                            onPressed: () =>
                                                controller.downloadPdf(d),
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
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
