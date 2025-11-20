import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:personal_finance_manager/app/constants/app_constants.dart';
import 'package:personal_finance_manager/data/models/transaction_model.dart';
import 'package:personal_finance_manager/utils/helpers/date_helper.dart';

class RecentTransactions extends StatelessWidget {
  final RxList<TransactionModel> transactions;
  final VoidCallback onRefresh;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (transactions.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionItem(transaction, context);
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first transaction',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    TransactionModel transaction,
    BuildContext context,
  ) {
    final isIncome = transaction.isIncome;
    final categoryColor = transaction.category?.type.color ?? Colors.grey;
    final categoryIcon = transaction.category?.type.icon ?? Icons.help_outline;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // Category Icon
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(categoryIcon, color: categoryColor, size: 24),
        ),

        // Category Name and Date
        title: Text(
          transaction.category?.name ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          DateHelper.getDisplayDate(transaction.date),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),

        // Amount
        trailing: Text(
          '${isIncome ? '+' : '-'} ${AppConstants.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
