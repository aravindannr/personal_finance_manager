import 'package:get/instance_manager.dart';
import 'package:personal_finance_manager/modules/analytics/controllers/analytics_controller.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}
