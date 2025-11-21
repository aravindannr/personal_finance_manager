import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/app/constants/app_constants.dart';
import 'package:personal_finance_manager/modules/analytics/controllers/analytics_controller.dart';
import 'package:personal_finance_manager/modules/analytics/widgets/bar_chart_widget.dart';
import 'package:personal_finance_manager/modules/analytics/widgets/pie_chart_widget.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                // Summary Cards
                _buildSummaryCards(context),

                const SizedBox(height: 24),

                // Insights Section
                _buildInsightsSection(context),

                const SizedBox(height: 24),

                // Category Wise Spending (Pie Chart)
                _buildSectionHeader('Spending by Category'),
                const SizedBox(height: 16),
                PieChartWidget(
                  categoryExpenses: controller.categoryWiseExpenses,
                  totalExpense: controller.totalExpense.value,
                ),

                const SizedBox(height: 24),

                // Daily Spending (Bar Chart)
                BarChartWidget(dailySpending: controller.dailySpending),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context: context,
                  title: 'Income',
                  amount: controller.totalIncome.value,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context: context,
                  title: 'Expense',
                  amount: controller.totalExpense.value,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSavingsCard(context),
        ],
      );
    });
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context) {
    return Obx(() {
      final savings = controller.savings;
      final percentage = controller.savingPercentage;
      final isPositive = savings >= 0;
      return Card(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        child: Padding(
          padding: .all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      isPositive ? 'Savings' : 'Deficit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.currencySymbol}${savings.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    'of income',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInsightsSection(BuildContext context) {
    return Obx(() {
      return Card(
        child: Padding(
          padding: .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const Text(
                'Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              _buildInsightItem(
                icon: Icons.category,
                title: 'Top Spending',
                value: controller.topSpendingCategory,
                color: Colors.orange,
              ),
              const Divider(height: 24),
              _buildInsightItem(
                icon: Icons.calendar_today,
                title: 'Avg Daily Spending',
                value: '₹${controller.averageDailySpending.toStringAsFixed(2)}',
                color: Colors.blue,
              ),
              const Divider(height: 24),
              _buildInsightItem(
                icon: Icons.receipt_long,
                title: 'Total Transactions',
                value: '${controller.categoryWiseExpenses.length} categories',
                color: Colors.purple,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
