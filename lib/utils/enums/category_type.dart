import 'package:flutter/material.dart';

enum CategoryType {
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  education,
  salary,
  freelance,
  investment,
  other;

  String get name {
    switch (this) {
      case CategoryType.food:
        return 'Food & Dining';
      case CategoryType.transport:
        return 'Transport';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.bills:
        return 'Bills & Utilities';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.health:
        return 'Health';
      case CategoryType.education:
        return 'Education';
      case CategoryType.salary:
        return 'Salary';
      case CategoryType.freelance:
        return 'Freelance';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.food:
        return Icons.restaurant;
      case CategoryType.transport:
        return Icons.directions_car;
      case CategoryType.shopping:
        return Icons.shopping_bag;
      case CategoryType.bills:
        return Icons.receipt_long;
      case CategoryType.entertainment:
        return Icons.movie;
      case CategoryType.health:
        return Icons.local_hospital;
      case CategoryType.education:
        return Icons.school;
      case CategoryType.salary:
        return Icons.account_balance_wallet;
      case CategoryType.freelance:
        return Icons.work;
      case CategoryType.investment:
        return Icons.trending_up;
      case CategoryType.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.food:
        return const Color(0xFFEF4444);
      case CategoryType.transport:
        return const Color(0xFF3B82F6);
      case CategoryType.shopping:
        return const Color(0xFFEC4899);
      case CategoryType.bills:
        return const Color(0xFFF59E0B);
      case CategoryType.entertainment:
        return const Color(0xFF8B5CF6);
      case CategoryType.health:
        return const Color(0xFF10B981);
      case CategoryType.education:
        return const Color(0xFF14B8A6);
      case CategoryType.salary:
        return const Color(0xFF10B981);
      case CategoryType.freelance:
        return const Color(0xFF8B5CF6);
      case CategoryType.investment:
        return const Color(0xFF06B6D4);
      case CategoryType.other:
        return const Color(0xFF6B7280);
    }
  }
}
