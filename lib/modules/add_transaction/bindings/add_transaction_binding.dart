import 'package:get/instance_manager.dart';
import 'package:personal_finance_manager/modules/add_transaction/controllers/add_transaction_controller.dart';

class AddTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTransactionController>(() => AddTransactionController());
  }
}
