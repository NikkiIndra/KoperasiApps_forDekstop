import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/data/database/app_database.dart';
import 'app/modules/costomer/controllers/costomer_controller.dart';
import 'app/modules/document/controllers/document_controller.dart';
import 'koperasi_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init SQLite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Register database (tunggu init selesai)
  await Get.putAsync<AppDatabase>(() async => await AppDatabase().init());

  // Register controllers
  Get.put<DocumentController>(DocumentController());
  Get.put<CustomerController>(CustomerController());

  runApp(const KoperasiApp());
}
