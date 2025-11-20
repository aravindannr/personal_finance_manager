import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/data/models/transaction_model.dart';
import 'package:personal_finance_manager/data/repositories/category_repository.dart';
import 'package:personal_finance_manager/data/repositories/transaction_repository.dart';

class HomeController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Observable variables
  final RxBool isLoading = true.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxMap<DateTime, double> dailySpending = <DateTime, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  // Load all home screen data
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      // Load all data in parallel
      await Future.wait([
        loadBalance(),
        loadRecentTransactions(),
        loadDailySpending(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading home data: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load balance, income, expense
  Future<void> loadBalance() async {
    try {
      final income = await _transactionRepository.getTotalIncome();
      final expense = await _transactionRepository.getTotalExpense();
      final balance = await _transactionRepository.getTotalBalance();
      totalIncome.value = income;
      totalExpense.value = expense;
      totalBalance.value = balance;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading balance: $e');
      }
    }
  }

  // Load recent transactions (last 5)
  Future<void> loadRecentTransactions() async {
    try {
      final transaction = await _transactionRepository.getRecentTransactions(
        limit: 5,
      );
      recentTransactions.value = transaction;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent transactions: $e');
      }
    }
  }

  // Load daily spending for last 7 days
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

  // Refresh data (pull to refresh)
  Future<void> refreshData() async {
    await loadHomeData();
  }

  // Navigate to add transaction
  void goToAddTransaction() {
    Get.toNamed('/add-transaction')?.then((value) {
      // Refresh data when coming back
      loadHomeData();
    });
  }

  // Navigate to all transactions
  void goToAllTransactions() {
    Get.toNamed('/transactions');
  }

  // Navigate to analytics
  void goToAnalytics() {
    Get.toNamed('/analytics');
  }

  // Navigate to settings
  void goToSettings() {
    Get.toNamed('/settings');
  }
}
