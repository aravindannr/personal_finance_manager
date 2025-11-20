import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:personal_finance_manager/data/models/transaction_model.dart';
import 'package:personal_finance_manager/data/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/utils/enums/transaction_type.dart';
import 'package:personal_finance_manager/utils/helpers/date_helper.dart';

enum TransactionFilter { all, today, thisWeek, thisMonth, income, expense }

class TransactionsController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();

  // Observable variables
  final RxList<TransactionModel> allTransaction = <TransactionModel>[].obs;
  final RxList<TransactionModel> filteredTransaction = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<TransactionFilter> currentFilter = TransactionFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // Load all transactions
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final transaction = await _transactionRepository.getAllTransactions();
      allTransaction.value = transaction;
      applyFilter(currentFilter.value);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading transactions: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load transactions',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filter
  void applyFilter(TransactionFilter filter) {
    currentFilter.value = filter;
    switch (filter) {
      case TransactionFilter.all:
        filteredTransaction.value = allTransaction;
        break;
      case TransactionFilter.today:
        final today = DateHelper.getDateOnly(DateTime.now());
        filteredTransaction.value = allTransaction.where((transaction) {
          final transactionDate = DateHelper.getDateOnly(transaction.date);
          return transactionDate.isAtSameMomentAs(today);
        }).toList();
      case TransactionFilter.thisWeek:
        final startOfWeek = DateHelper.startOfWeek(DateTime.now());
        final endOfWeek = DateHelper.endOfWeek(DateTime.now());
        filteredTransaction.value = allTransaction.where((transaction) {
          return transaction.date.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              ) &&
              transaction.date.isBefore(
                endOfWeek.add(const Duration(seconds: 1)),
              );
        }).toList();
        break;
      case TransactionFilter.thisMonth:
        final startOfMonth = DateHelper.startOfMonth(DateTime.now());
        final endOfMonth = DateHelper.endOfMonth(DateTime.now());
        filteredTransaction.value = allTransaction.where((transaction) {
          return transaction.date.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              ) &&
              transaction.date.isBefore(
                endOfMonth.subtract(const Duration(seconds: 1)),
              );
        }).toList();
        break;
      case TransactionFilter.income:
        filteredTransaction.value = allTransaction
            .where((transaction) => transaction.type == TransactionType.income)
            .toList();
        break;
      case TransactionFilter.expense:
        filteredTransaction.value = allTransaction
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList();
        break;
    }
  }

  // Get filter name
  String getFilteredName(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return 'All';
      case TransactionFilter.today:
        return 'Today';
      case TransactionFilter.thisWeek:
        return 'This Week';
      case TransactionFilter.thisMonth:
        return 'This Month';
      case TransactionFilter.income:
        return ' Income';
      case TransactionFilter.expense:
        return 'Expense';
    }
  }

  // Show filter bottom sheet
  void showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              const Text(
                'Filter Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ...TransactionFilter.values.map((e) {
                return Obx(() {
                  final isSelected = currentFilter.value == e;
                  return ListTile(
                    title: Text(getFilteredName(e)),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () {
                      applyFilter(e);
                      Navigator.pop(context);
                    },
                  );
                });
              }),
            ],
          ),
        );
      },
    );
  }

  // Edit transaction
  void editTransaction(TransactionModel transaction) {
    Get.toNamed('/add-transaction', arguments: transaction)?.then((value) {
      if (value == true) {
        loadTransactions();
      }
    });
  }

  // Delete transaction with confirmation
  void deleteTransaction(TransactionModel transaction) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _confirmDelete(transaction);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Confirm delete
  Future<void> _confirmDelete(TransactionModel transaction) async {
    try {
      await _transactionRepository.deleteTransaction(transaction.id!);
      Get.snackbar(
        'Success',
        'Transaction deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      loadTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting transaction: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to delete transaction',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  // Refresh transactions
  Future<void> refreshTransaction() async {
    await loadTransactions();
  }

  // Group transactions by date
  Map<String, List<TransactionModel>> get groupedTransactions {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var transaction in filteredTransaction) {
      final dateKey = DateHelper.formatDate(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    return grouped;
  }

  // Calculate total for filtered transactions
  double get filterdTotal {
    double total = 0;
    for (var transaction in filteredTransaction) {
      if (transaction.isIncome) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  }

  // Get income total for filtered
  double get filteredIncome {
    return filteredTransaction
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get expense total for filtered
  double get filteredExpense {
    return filteredTransaction
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }
}
