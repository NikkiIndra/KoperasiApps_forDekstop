// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../routes/app_pages.dart';

// // class ShellController extends GetxController {
// //   var currentPage = Routes.DOCUMENT.obs;

// //   // simpan title & actions
// //   var title = "Pencarian Dokumen".obs;
// //   Widget? topActions;

// //   void changePage(String route) {
// //     currentPage.value = route;

// //     if (route == Routes.DOCUMENT) {
// //       title.value = "Pencarian Dokumen";
// //       topActions = null; // nanti diisi sama DocumentView
// //     } else if (route == Routes.COSTOMER) {
// //       title.value = "Data Nasabah";
// //       topActions = null;
// //     }
// //   }
// // }
// class ShellController extends GetxController {
//   var currentPage = Routes.DOCUMENT.obs;
//   var topActions = Rx<Widget?>(null);

//   void changePage(String route) {
//     currentPage.value = route;
//     // reset top actions tiap ganti page
//     topActions.value = null;
//   }
// }
