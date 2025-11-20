import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_manager/app/constants/app_constants.dart';

class SpendingChart extends StatelessWidget {
  final RxMap<DateTime, double> dailySpending;

  const SpendingChart({super.key, required this.dailySpending});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (dailySpending.isEmpty) {
        return _buildEmptyChart(context);
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Last 7 Days Spending',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 200,
                child: BarChart(_buildBarChartData(context)),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Card(
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No spending data yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Start adding expenses to see your chart',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartData _buildBarChartData(BuildContext context) {
    // Get last 7 days
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (index) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
    });

    // Find max value for scaling
    double maxY = 100;
    if (dailySpending.isNotEmpty) {
      maxY = dailySpending.values.reduce((a, b) => a > b ? a : b);
      maxY = maxY * 1.2; // Add 20% padding
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final date = last7Days[group.x.toInt()];
            final amount = dailySpending[_normalizeDate(date)] ?? 0.0;
            return BarTooltipItem(
              '${DateFormat('MMM dd').format(date)}\n${AppConstants.currencySymbol}${amount.toStringAsFixed(0)}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                final date = last7Days[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${AppConstants.currencySymbol}${value.toInt()}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: _buildBarGroups(last7Days, context),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<DateTime> dates,
    BuildContext context,
  ) {
    return List.generate(dates.length, (index) {
      final date = dates[index];
      final amount = dailySpending[_normalizeDate(date)] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: Theme.of(context).primaryColor,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  // Normalize date to remove time component for comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
