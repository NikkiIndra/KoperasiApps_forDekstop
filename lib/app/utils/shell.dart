// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:new_koperasi_apps/app/utils/shell_controller.dart';
// import 'package:new_koperasi_apps/app/modules/costomer/views/costomer_view.dart';
// import 'package:new_koperasi_apps/app/modules/document/views/document_view.dart';
// import '../routes/app_pages.dart';
// import 'side_item.dart';

// class Shell extends StatelessWidget {
//   final ShellController controller = Get.find<ShellController>();

//   final Widget? trailing;
//   final Widget? topActions;

//   Shell({super.key, this.trailing, this.topActions});

//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width >= 1100;

//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: isWide ? 260 : 72,
//             margin: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12.withOpacity(.05),
//                   blurRadius: 10,
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.school, color: Color(0xFF6366F1)),
//                       const SizedBox(width: 8),
//                       if (isWide)
//                         const Text(
//                           'KoperasiFy',
//                           style: TextStyle(fontWeight: FontWeight.w700),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const Divider(height: 1),
//                 Obx(
//                   () => SideItem(
//                     icon: Icons.search,
//                     label: 'Pencarian Dokumen',
//                     selected: controller.currentPage.value == Routes.DOCUMENT,
//                     onTap: () => controller.changePage(Routes.DOCUMENT),
//                     extended: isWide,
//                   ),
//                 ),
//                 Obx(
//                   () => SideItem(
//                     icon: Icons.people_alt_rounded,
//                     label: 'Data Nasabah',
//                     selected: controller.currentPage.value == Routes.COSTOMER,
//                     onTap: () => controller.changePage(Routes.COSTOMER),
//                     extended: isWide,
//                   ),
//                 ),
//                 const Spacer(),
//                 if (isWide)
//                   ListTile(
//                     leading: const CircleAvatar(
//                       radius: 16,
//                       child: Icon(Icons.person),
//                     ),
//                     title: const Text('Admin', style: TextStyle(fontSize: 13)),
//                     subtitle: const Text('Operator'),
//                     trailing: FilledButton.tonal(
//                       onPressed: () {},
//                       child: const Text('Logout'),
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),

//           // Content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
//               child: Column(
//                 children: [
//                   // Header
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12.withOpacity(.05),
//                           blurRadius: 10,
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Obx(() {
//                             String title =
//                                 controller.currentPage.value == Routes.DOCUMENT
//                                 ? "Pencarian Dokumen"
//                                 : "Data Nasabah";
//                             return Text(
//                               title,
//                               style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             );
//                           }),
//                         ),
//                         Obx(
//                           () => controller.topActions.value ?? const SizedBox(),
//                         ), // <── pakai ini
//                         const SizedBox(width: 16),
//                         trailing ?? const SizedBox(),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Halaman dinamis pakai IndexedStack
//                   Expanded(
//                     child: Obx(() {
//                       return IndexedStack(
//                         index: controller.currentPage.value == Routes.DOCUMENT
//                             ? 0
//                             : 1,
//                         children: const [DocumentView(), CustomersView()],
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
