import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:personal_finance_manager/modules/home/controllers/home_controller.dart';
import 'package:personal_finance_manager/modules/home/widgets/balance_card.dart';
import 'package:personal_finance_manager/modules/home/widgets/recent_transactions.dart';
import 'package:personal_finance_manager/modules/home/widgets/spending_chart.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finance Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: controller.goToAnalytics,
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.goToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                BalanceCard(
                  balance: controller.totalBalance.value,
                  income: controller.totalIncome.value,
                  expense: controller.totalExpense.value,
                ),
                const SizedBox(height: 24),

                // Spending Chart
                SpendingChart(dailySpending: controller.dailySpending),

                const SizedBox(height: 24),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.goToAllTransactions,
                      child: const Text('See All'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const SizedBox(height: 12),

                // Recent Transactions List
                RecentTransactions(
                  transactions: controller.recentTransactions,
                  onRefresh: controller.loadRecentTransactions,
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
