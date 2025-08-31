// dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_koperasi_apps/app/modules/document/controllers/document_controller.dart';
import 'package:new_koperasi_apps/app/modules/costomer/controllers/costomer_controller.dart';
import 'package:new_koperasi_apps/app/routes/app_pages.dart';

class DashboardController extends GetxController {
  final currentPage = RxString(Routes.DOCUMENT);
  final topActions = Rx<Widget?>(null);
  final isSearching = false.obs; // Tambahkan state untuk tracking pencarian

  final DocumentController documentC = Get.find<DocumentController>();
  final CustomerController customerC = Get.find<CustomerController>();

  @override
  void onInit() {
    super.onInit();
    setTopActionsForCurrentPage();

    // Listen perubahan pada search controller
    documentC.searchCtrl.addListener(_updateSearchState);
    customerC.searchCtrl.addListener(_updateSearchState);
  }

  @override
  void onClose() {
    documentC.searchCtrl.removeListener(_updateSearchState);
    customerC.searchCtrl.removeListener(_updateSearchState);
    super.onClose();
  }

  void _updateSearchState() {
    final isDocumentPage = currentPage.value == Routes.DOCUMENT;
    final searchCtrl = isDocumentPage
        ? documentC.searchCtrl
        : customerC.searchCtrl;
    isSearching.value = searchCtrl.text.isNotEmpty;
  }

  void changePage(String route) {
    currentPage.value = route;
    setTopActionsForCurrentPage();
  }

  void clearSearch() {
    if (currentPage.value == Routes.DOCUMENT) {
      documentC.searchCtrl.clear();
      documentC.doSearch('');
    } else if (currentPage.value == Routes.COSTOMER) {
      customerC.searchCtrl.clear();
      customerC.refreshList();
    }
    isSearching.value = false;
  }

  void setTopActionsForCurrentPage() {
    if (currentPage.value == Routes.DOCUMENT) {
      setDocumentTopActions();
    } else if (currentPage.value == Routes.COSTOMER) {
      setCustomerTopActions();
    } else {
      topActions.value = null;
    }
  }

  // dashboard_controller.dart - bagian setDocumentTopActions
  void setDocumentTopActions() {
    topActions.value = Obx(
      () => Row(
        children: [
          SizedBox(
            width: 320,
            height: 40,
            child: TextField(
              controller: documentC.searchCtrl,
              decoration: InputDecoration(
                hintText: documentC.searchBy.value == 'title'
                    ? 'Cari Berdasarkan Judul'
                    : 'Cari Berdasarkan Tahun',
                hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                prefixIcon: isSearching.value
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: clearSearch,
                        tooltip: 'Kembali ke semua data',
                      )
                    : const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        documentC.searchCtrl.clear();
                        documentC.doSearch('');
                        isSearching.value = false;
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        documentC.searchBy.value == 'title'
                            ? Icons.title
                            : Icons.calendar_today,
                      ),
                      onPressed: () => documentC.toggleSearchMode(),
                      tooltip: documentC.searchBy.value == 'title'
                          ? 'klik untuk cari berdasarkan TAHUN'
                          : 'klik untuk cari berdasarkan JUDUL',
                    ),
                  ],
                ),
              ),
              onSubmitted: (value) {
                documentC.doSearch(value);
                isSearching.value = value.isNotEmpty;
              },
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => documentC.uploadPdfDocument(),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload PDF'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => documentC.addDocumentDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Buat Baru'),
          ),
        ],
      ),
    );
  }

  void setCustomerTopActions() {
    topActions.value = Obx(
      () => Row(
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: customerC.searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama/NIK/alamat…',
                prefixIcon: isSearching.value
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: clearSearch,
                        tooltip: 'Kembali ke semua data',
                      )
                    : const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    customerC.searchCtrl.clear();
                    customerC.refreshList();
                    isSearching.value = false;
                  },
                ),
              ),
              onSubmitted: (value) {
                customerC.refreshList();
                isSearching.value = value.isNotEmpty;
              },
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {
              customerC.refreshList();
              isSearching.value = customerC.searchCtrl.text.isNotEmpty;
            },
            icon: const Icon(Icons.search),
            label: const Text('Cari'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () => customerC.addOrEdit(),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Tambah UserS'),
          ),
        ],
      ),
    );
  }
}
