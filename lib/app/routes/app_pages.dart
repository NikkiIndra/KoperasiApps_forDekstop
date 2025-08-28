import 'package:get/get.dart';
import '../modules/costomer/bindings/costomer_binding.dart';
import '../modules/costomer/views/costomer_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/document/bindings/document_binding.dart';
import '../modules/document/views/document_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.DOCUMENT,
      page: () => DocumentView(),
      binding: DocumentBinding(),
    ),
    GetPage(
      name: _Paths.COSTOMER,
      page: () => CustomersView(),
      binding: CostomerBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
