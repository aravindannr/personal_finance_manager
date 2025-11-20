import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/data/models/transaction_model.dart';
import 'package:personal_finance_manager/modules/transactions/controllers/transactions_controller.dart';
import 'package:personal_finance_manager/modules/transactions/widgets/transaction_item.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => controller.showFilterOptions(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary Card
          _buildFilterSummary(context),
          // Transactions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTransaction.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshTransaction,
                child: _buildTransactionList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add-transaction')?.then((result) {
            if (result == true) {
              controller.loadTransactions();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Filter Summary Card
  Widget _buildFilterSummary(BuildContext context) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Filter Name
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  controller.getFilteredName(controller.currentFilter.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${controller.filteredTransaction.length} transactions',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Income and Expense
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    label: 'Income',
                    amount: controller.filteredIncome,
                    color: Colors.greenAccent,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    label: 'Expense',
                    amount: controller.filteredExpense,
                    color: Colors.redAccent,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filter or add new transactions',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Transactions List (Grouped by Date)
  Widget _buildTransactionList() {
    final grouppedTransactions = controller.groupedTransactions;
    final dates = grouppedTransactions.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final transactions = grouppedTransactions[date]!;
        return Column(
          crossAxisAlignment: .start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            // Transactions for this date
            ...transactions.map((transaction) {
              return TransactionItem(
                transaction: transaction,
                onTap: () => _showTransactionOptions(context, transaction),
              );
            }),
          ],
        );
      },
    );
  }

  // Show transaction options (Edit/Delete)
  void _showTransactionOptions(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Transaction'),
                onTap: () {
                  Navigator.pop(context);
                  controller.editTransaction(transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Transaction'),
                onTap: () {
                  Navigator.pop(context);
                  controller.deleteTransaction(transaction);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
