import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_koperasi_apps/app/utils/status_chip.dart';

import '../controllers/costomer_controller.dart';

class CustomersView extends GetView<CustomerController> {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
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
                                    controller.refreshList();
                                  },
                                  child: const Text('Kembali ke Semua Data'),
                                ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 100,
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
                                  DataCell(StatusChip(text: c.status)),
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
                                          onPressed: () =>
                                              controller.remove(c.id!),
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
    );
  }
}
