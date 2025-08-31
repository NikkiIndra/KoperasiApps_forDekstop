import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_koperasi_apps/app/model/customer.dart';
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
              const SizedBox(height: 8),
              Expanded(
                child: UserTable(items: items, controller: controller),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class UserTable extends StatefulWidget {
  const UserTable({super.key, required this.items, required this.controller});

  final RxList<Customer> items;
  final CustomerController controller;

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  final CustomerController controller = Get.find<CustomerController>();

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
            child: widget.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Data tidak ditemukan",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        if (widget.controller.searchCtrl.text.isNotEmpty)
                          FilledButton.tonal(
                            onPressed: () {
                              widget.controller.searchCtrl.clear();
                              widget.controller.refreshList();
                            },
                            child: const Text('Kembali ke Semua Data'),
                          ),
                      ],
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 800,
                    ), // atau sesuai kebutuhan
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
                      rows: widget.items.map((c) {
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
                                        widget.controller.addOrEdit(initial: c),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    onPressed: () =>
                                        widget.controller.remove(c.id!),
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
      ),
    );
  }
}
