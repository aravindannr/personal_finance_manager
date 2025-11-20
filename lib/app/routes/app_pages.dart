import 'package:get/get.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/add_transaction/bindings/add_transaction_binding.dart';
import '../../modules/add_transaction/views/add_transaction_view.dart';
import '../../modules/transactions/bindings/transactions_binding.dart';
import '../../modules/transactions/views/transactions_view.dart';
import '../../modules/analytics/bindings/analytics_binding.dart';
import '../../modules/analytics/views/analytics_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.addTransaction,
      page: () => const AddTransactionView(),
      binding: AddTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
