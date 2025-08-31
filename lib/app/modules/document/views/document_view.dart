import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/document.dart';
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
                      const SizedBox(height: 8),

                      /// Pisahkan tabel jadi widget Stateful biar ScrollController aman
                      Expanded(child: DocumentTable(rows: rows)),
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

class DocumentTable extends StatefulWidget {
  final List<Document> rows;

  const DocumentTable({super.key, required this.rows});

  @override
  State<DocumentTable> createState() => _DocumentTableState();
}

class _DocumentTableState extends State<DocumentTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  final DocumentController controller = Get.find<DocumentController>();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(10),
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 150,
              horizontalMargin: 20,
              showBottomBorder: true,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.blueGrey.shade50,
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
              dataRowHeight: 48,
              dataTextStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('Judul')),
                DataColumn(label: Text('Tahun')),
                DataColumn(label: Text('Lokasi Fisik')),
                DataColumn(label: Text('Path File\n')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: List<DataRow>.generate(widget.rows.length, (index) {
                final d = widget.rows[index];
                return DataRow(
                  color: MaterialStateColor.resolveWith(
                    (states) =>
                        index.isEven ? Colors.grey.shade100 : Colors.white,
                  ),
                  cells: [
                    DataCell(Text(d.title)),
                    DataCell(Text('${d.year}')),
                    DataCell(
                      Tooltip(
                        message:
                            "Blok ${d.rack} - Ambalan ${d.ambalan} - Box ${d.box}",
                        child: Text('${d.rack} - ${d.ambalan} -  ${d.box}'),
                      ),
                    ),
                    DataCell(
                      Tooltip(
                        message: d.filePath,
                        child: Text(
                          d.filePath.length > 20
                              ? '...${d.filePath.substring(d.filePath.length - 20)}'
                              : d.filePath,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Unduh PDF',
                            onPressed: () => controller.downloadPdf(d),
                            icon: const Icon(
                              Icons.download,
                              color: Colors.blue,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => controller.deleteDoc(d.id!),
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
              }),
            ),
          ),
        ),
      ),
    );
  }
}
