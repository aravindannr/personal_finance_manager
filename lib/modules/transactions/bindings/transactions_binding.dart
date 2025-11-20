import 'package:get/instance_manager.dart';
import 'package:personal_finance_manager/modules/transactions/controllers/transactions_controller.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}
