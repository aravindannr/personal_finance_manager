import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/data/repositories/transaction_repository.dart';

class AnalyticsController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxMap<String, double> categoryWiseExpenses = <String, double>{}.obs;
  final RxMap<DateTime, double> dailySpending = <DateTime, double>{}.obs;

  // Selected period
  final RxString selectedPeriod = 'This Month'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
  }

  // Load all analytics data
  Future<void> loadAnalyticsData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadTotals(),
        loadCategoryWiseExpense(),
        loadDailySpending(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading analytics data: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load totals
  Future<void> loadTotals() async {
    try {
      final income = await _transactionRepository.getTotalIncome();
      final expense = await _transactionRepository.getTotalExpense();
      final balance = await _transactionRepository.getTotalBalance();
      totalIncome.value = income;
      totalBalance.value = balance;
      totalExpense.value = expense;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading totals: $e');
      }
    }
  }

  // Load category wise expenses
  Future<void> loadCategoryWiseExpense() async {
    try {
      final expenses = await _transactionRepository.getCategoryWiseExpenses();
      categoryWiseExpenses.value = expenses;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading category wise expenses: $e');
      }
    }
  }

  // Load daily spending
  Future<void> loadDailySpending() async {
    try {
      final spending = await _transactionRepository.getDailySpending(days: 7);
      dailySpending.value = spending;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading daily spending: $e');
      }
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadAnalyticsData();
  }

  // Get spending percentage for category
  double getCategoryPercentage(double amount) {
    if (totalExpense.value == 0) return 0;
    return (amount / totalExpense.value) * 100;
  }

  // Get top spending category
  String get topSpendingCategory {
    if (categoryWiseExpenses.isEmpty) return 'None';
    var maxEntry = categoryWiseExpenses.entries.first;
    for (var entry in categoryWiseExpenses.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  // Get average daily spending
  double get averageDailySpending {
    if (dailySpending.isEmpty) return 0;
    final total = dailySpending.values.fold(
      0.0,
      (previousValue, element) => previousValue + element,
    );
    return total / dailySpending.length;
  }

  // Get savings (income - expense)
  double get savings {
    final savings = totalIncome.value - totalExpense.value;
    return savings;
  }

  // Get savings percentage
  double get savingPercentage {
    if (totalIncome.value == 0) return 0;
    return (savings / totalIncome.value) * 100;
  }
}
