import 'package:get/get.dart';

import '../controllers/costomer_controller.dart';

class CostomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}
