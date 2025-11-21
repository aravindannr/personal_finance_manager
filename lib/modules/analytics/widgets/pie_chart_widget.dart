import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';

class PieChartWidget extends StatelessWidget {
  final RxMap<String, double> categoryExpenses;
  final double totalExpense;
  const PieChartWidget({
    super.key,
    required this.categoryExpenses,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (categoryExpenses.isEmpty) {
        return _buildEmptyState();
      }
      return Card(
        child: Padding(
          padding: .all(16),
          child: Column(
            children: [
              // Pie Chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieChartSections(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Legend
              _buildLegend(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Card(
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No expense data yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int index = 0;
    return categoryExpenses.entries.map((e) {
      final percentage = (e.value / totalExpense) * 100;
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        value: e.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return Column(
      children: categoryExpenses.entries.map((entry) {
        final index = categoryExpenses.keys.toList().indexOf(entry.key);
        final color = colors[index % colors.length];
        final percentage = (entry.value / totalExpense) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              // Category name
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Amount and percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
