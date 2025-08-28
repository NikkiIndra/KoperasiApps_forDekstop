// costomer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_koperasi_apps/app/model/customer.dart';

import '../../../data/database/app_database.dart';

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

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ... (method addOrEdit, remove, _seedIfEmpty tetap sama)
  // Pastikan method addOrEdit() tanpa parameter initial memiliki default value
  Future<void> addOrEdit({Customer? initial}) async {
    final nameCtrl = TextEditingController(text: initial?.name ?? '');
    final nikCtrl = TextEditingController(text: initial?.nik ?? '');
    final addressCtrl = TextEditingController(text: initial?.address ?? '');
    final phoneCtrl = TextEditingController(text: initial?.phone ?? '');

    // Validasi dan normalisasi nilai status
    String getValidStatus(String? status) {
      const validStatuses = ['active', 'inactive', 'blocked'];
      if (status == null || !validStatuses.contains(status)) {
        return 'active'; // Default value
      }
      return status;
    }

    String selectedStatus = getValidStatus(initial?.status);

    final isEditMode = initial != null;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(isEditMode ? 'Edit Status Nasabah' : 'Tambah Nasabah'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TAMPILKAN DATA NASABAH (READ-ONLY) JIKA EDIT MODE
              if (isEditMode) ...[
                _buildReadOnlyField('Nama', initial!.name),
                const SizedBox(height: 12),
                _buildReadOnlyField('NIK', initial.nik),
                const SizedBox(height: 12),
                _buildReadOnlyField('Alamat', initial.address),
                const SizedBox(height: 12),
                _buildReadOnlyField('Telepon', initial.phone ?? '-'),
                const SizedBox(height: 12),
                const Text(
                  'Edit Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],

              // FIELD INPUT UNTUK TAMBAH NASABAH (HANYA MUNCUL JIKA BUKAN EDIT MODE)
              if (!isEditMode) ...[
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nikCtrl,
                  decoration: const InputDecoration(
                    labelText: 'NIK *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alamat *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Telepon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
              ],

              // DROPDOWN STATUS (SELALU MUNCUL)
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Aktif')),
                  DropdownMenuItem(value: 'inactive', child: Text('Non-Aktif')),
                  DropdownMenuItem(value: 'blocked', child: Text('Diblokir')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text(
                '* wajib diisi',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              // Validasi input hanya untuk tambah nasabah
              if (!isEditMode) {
                if (nameCtrl.text.isEmpty) {
                  Get.snackbar(
                    'Gagal',
                    'Nama harus diisi',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                if (nikCtrl.text.isEmpty) {
                  Get.snackbar(
                    'Gagal',
                    'NIK harus diisi',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                if (addressCtrl.text.isEmpty) {
                  Get.snackbar(
                    'Gagal',
                    'Alamat harus diisi',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
              }
              Get.back(result: true);
            },
            child: Text(isEditMode ? 'Update Status' : 'Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        isLoading.value = true;

        final customer = Customer(
          id: initial?.id,
          name: isEditMode
              ? initial!.name
              : nameCtrl.text, // Gunakan nilai lama jika edit
          nik: isEditMode
              ? initial!.nik
              : nikCtrl.text, // Gunakan nilai lama jika edit
          address: isEditMode
              ? initial!.address
              : addressCtrl.text, // Gunakan nilai lama jika edit
          phone: isEditMode
              ? initial!.phone
              : (phoneCtrl.text.isNotEmpty
                    ? phoneCtrl.text
                    : null), // Gunakan nilai lama jika edit
          status: selectedStatus, // Status selalu bisa diubah
        );

        if (!isEditMode) {
          await db.insertCustomer(customer);
        } else {
          await db.updateCustomer(customer);
        }

        await refreshList();

        Get.snackbar(
          'Berhasil',
          'Nasabah ${!isEditMode ? 'ditambahkan' : 'diperbarui'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Helper method untuk menampilkan field read-only
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade50,
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  // VERSI ALTERNATIF: JIKA SUATU SAAT INGIN BISA EDIT SEMUA FIELD
  /*
Future<void> addOrEdit({Customer? initial}) async {
  final nameCtrl = TextEditingController(text: initial?.name ?? '');
  final nikCtrl = TextEditingController(text: initial?.nik ?? '');
  final addressCtrl = TextEditingController(text: initial?.address ?? '');
  final phoneCtrl = TextEditingController(text: initial?.phone ?? '');

  // Validasi dan normalisasi nilai status
  String getValidStatus(String? status) {
    const validStatuses = ['active', 'inactive', 'blocked'];
    if (status == null || !validStatuses.contains(status)) {
      return 'active'; // Default value
    }
    return status;
  }

  String selectedStatus = getValidStatus(initial?.status);

  final isEditMode = initial != null;

  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(isEditMode ? 'Edit Nasabah' : 'Tambah Nasabah'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // UNCOMMENT FIELD BERIKUT JIKA INGIN BISA EDIT SEMUA DATA
            /*
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama *',
                border: OutlineInputBorder(),
              ),
              enabled: !isEditMode, // Non-aktifkan jika edit mode
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nikCtrl,
              decoration: const InputDecoration(
                labelText: 'NIK *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: !isEditMode, // Non-aktifkan jika edit mode
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Alamat *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Telepon',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            */
            
            // DROPDOWN STATUS (SELALU BISA DIEDIT)
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Aktif')),
                DropdownMenuItem(value: 'inactive', child: Text('Non-Aktif')),
                DropdownMenuItem(value: 'blocked', child: Text('Diblokir')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedStatus = value;
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              '* wajib diisi',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            // Validasi input
            if (nameCtrl.text.isEmpty) {
              Get.snackbar(
                'Gagal',
                'Nama harus diisi',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            if (nikCtrl.text.isEmpty) {
              Get.snackbar(
                'Gagal',
                'NIK harus diisi',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            if (addressCtrl.text.isEmpty) {
              Get.snackbar(
                'Gagal',
                'Alamat harus diisi',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            Get.back(result: true);
          },
          child: Text(isEditMode ? 'Update' : 'Simpan'),
        ),
      ],
    ),
  );

  if (result == true) {
    try {
      isLoading.value = true;

      final customer = Customer(
        id: initial?.id,
        name: nameCtrl.text,
        nik: nikCtrl.text,
        address: addressCtrl.text,
        phone: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
        status: selectedStatus,
      );

      if (!isEditMode) {
        await db.insertCustomer(customer);
      } else {
        await db.updateCustomer(customer);
      }

      await refreshList();

      Get.snackbar(
        'Berhasil',
        'Nasabah ${!isEditMode ? 'ditambahkan' : 'diperbarui'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
*/

  Future<void> remove(int id) async {
    await db.deleteCustomer(id);
    await refreshList();
  }

  Future<void> _seedIfEmpty() async {
    final hasAny = (await db.listCustomers()).isNotEmpty;
    if (hasAny) return;

    // Data sample nasabah
    final sampleCustomers = [
      Customer(
        name: 'Ahmad Santoso',
        nik: '1234567890123456',
        address: 'Jl. Merdeka No. 123, Jakarta',
        phone: '081234567890',
        status: 'active',
        // createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      Customer(
        name: 'Siti Rahayu',
        nik: '2345678901234567',
        address: 'Jl. Sudirman No. 45, Bandung',
        phone: '082345678901',
        status: 'active',
        // createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      Customer(
        name: 'Budi Pratama',
        nik: '3456789012345678',
        address: 'Jl. Gatot Subroto No. 67, Surabaya',
        status: 'inactive',
        // createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ];

    for (final customer in sampleCustomers) {
      await db.insertCustomer(customer);
    }
  }
}
