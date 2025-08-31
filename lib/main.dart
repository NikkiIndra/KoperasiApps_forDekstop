import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'app/data/database/app_database.dart';
import 'app/modules/costomer/controllers/costomer_controller.dart';
import 'app/modules/document/controllers/document_controller.dart';
import 'koperasi_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await windowManager.ensureInitialized();

  // WindowOptions windowOptions = WindowOptions(
  //   title: "F A G",
  //   center: true,
  //   // backgroundColor: Colors.white,
  //   titleBarStyle: TitleBarStyle.normal,
  //   // alwaysOnTop: true,
  // );
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    title: "F A G",
    center: true,
    // size: Size(1300, 700),
    minimumSize: Size(1300, 700), // biar ga bisa terlalu kecil
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show(); // ini cukup sekali
    await windowManager.focus(); // fokuskan window utama
  });
  // await windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   final defaultSize = const Size(1300, 700);
  //   await windowManager.setSize(defaultSize);
  //   // Pengaturan lainnya
  //   // await windowManager.setMinimumSize(defaultSize);
  //   // await windowManager.setResizable(true);
  //   // await windowManager.setClosable(true);
  //   // await windowManager.minimize();
  //   // await windowManager.setMinimizable(true);
  //   // await windowManager.setMaximizable(true);

  //   await windowManager.show();
  // });
  // Init SQLite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await Get.putAsync<AppDatabase>(() async {
    final db = await AppDatabase.create();
    return db.init();
  });

  // Register controllers
  Get.put<DocumentController>(DocumentController());
  Get.put<CustomerController>(CustomerController());

  runApp(const KoperasiApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Init SQLite
//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;
//   try {
//     await Get.putAsync<AppDatabase>(() async {
//       final db = await AppDatabase.create();
//       return db.init();
//     });
//   } catch (e) {
//     print('Error initializing database: $e');
//   }
//   // Register controllers
//   Get.put<DocumentController>(DocumentController());
//   Get.put<CustomerController>(CustomerController());

//   runApp(const KoperasiApp());
// }
