import 'package:sqflite/sqflite.dart';
import '../../app/constants/app_constants.dart';
import '../../utils/enums/transaction_type.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class TransactionRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Get all transactions with category details
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final db = await _databaseService.database;

      // SQL JOIN to get transaction with category
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          t.*,
          c.id as cat_id,
          c.name as cat_name,
          c.type as cat_type,
          c.transaction_type as cat_transaction_type
        FROM ${AppConstants.tableTransactions} t
        LEFT JOIN ${AppConstants.tableCategories} c ON t.category_id = c.id
        ORDER BY t.date DESC, t.created_at DESC
      ''');

      return _mapToTransactions(maps);
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.id as cat_id,
          c.name as cat_name,
          c.type as cat_type,
          c.transaction_type as cat_transaction_type
        FROM ${AppConstants.tableTransactions} t
        LEFT JOIN ${AppConstants.tableCategories} c ON t.category_id = c.id
        WHERE t.date BETWEEN ? AND ?
        ORDER BY t.date DESC, t.created_at DESC
      ''',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );

      return _mapToTransactions(maps);
    } catch (e) {
      print('Error getting transactions by date range: $e');
      return [];
    }
  }

  // Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(
    TransactionType type,
  ) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.id as cat_id,
          c.name as cat_name,
          c.type as cat_type,
          c.transaction_type as cat_transaction_type
        FROM ${AppConstants.tableTransactions} t
        LEFT JOIN ${AppConstants.tableCategories} c ON t.category_id = c.id
        WHERE t.type = ?
        ORDER BY t.date DESC, t.created_at DESC
      ''',
        [type.toString()],
      );

      return _mapToTransactions(maps);
    } catch (e) {
      print('Error getting transactions by type: $e');
      return [];
    }
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.id as cat_id,
          c.name as cat_name,
          c.type as cat_type,
          c.transaction_type as cat_transaction_type
        FROM ${AppConstants.tableTransactions} t
        LEFT JOIN ${AppConstants.tableCategories} c ON t.category_id = c.id
        WHERE t.id = ?
        LIMIT 1
      ''',
        [id],
      );

      if (maps.isNotEmpty) {
        return _mapToTransaction(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting transaction by id: $e');
      return null;
    }
  }

  // Get recent transactions (last N transactions)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final db = await _databaseService.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.id as cat_id,
          c.name as cat_name,
          c.type as cat_type,
          c.transaction_type as cat_transaction_type
        FROM ${AppConstants.tableTransactions} t
        LEFT JOIN ${AppConstants.tableCategories} c ON t.category_id = c.id
        ORDER BY t.date DESC, t.created_at DESC
        LIMIT ?
      ''',
        [limit],
      );

      return _mapToTransactions(maps);
    } catch (e) {
      print('Error getting recent transactions: $e');
      return [];
    }
  }

  // Insert transaction
  Future<int> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await _databaseService.database;
      return await db.insert(
        AppConstants.tableTransactions,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting transaction: $e');
      return 0;
    }
  }

  // Update transaction
  Future<int> updateTransaction(TransactionModel transaction) async {
    try {
      final db = await _databaseService.database;
      return await db.update(
        AppConstants.tableTransactions,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      print('Error updating transaction: $e');
      return 0;
    }
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _databaseService.database;
      return await db.delete(
        AppConstants.tableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting transaction: $e');
      return 0;
    }
  }

  // Get total income
  Future<double> getTotalIncome() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT SUM(amount) as total
        FROM ${AppConstants.tableTransactions}
        WHERE type = ?
      ''',
        [TransactionType.income.toString()],
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return result.first['total'] as double;
      }
      return 0.0;
    } catch (e) {
      print('Error getting total income: $e');
      return 0.0;
    }
  }

  // Get total expense
  Future<double> getTotalExpense() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT SUM(amount) as total
        FROM ${AppConstants.tableTransactions}
        WHERE type = ?
      ''',
        [TransactionType.expense.toString()],
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return result.first['total'] as double;
      }
      return 0.0;
    } catch (e) {
      print('Error getting total expense: $e');
      return 0.0;
    }
  }

  // Get total balance
  Future<double> getTotalBalance() async {
    try {
      final income = await getTotalIncome();
      final expense = await getTotalExpense();
      return income - expense;
    } catch (e) {
      print('Error getting total balance: $e');
      return 0.0;
    }
  }

  // Get category wise expenses (for pie chart)
  Future<Map<String, double>> getCategoryWiseExpenses() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          c.name as category_name,
          SUM(t.amount) as total
        FROM ${AppConstants.tableTransactions} t
        LEFT JOIN ${AppConstants.tableCategories} c ON t.category_id = c.id
        WHERE t.type = ?
        GROUP BY c.name
        ORDER BY total DESC
      ''',
        [TransactionType.expense.toString()],
      );

      Map<String, double> categoryExpenses = {};
      for (var row in result) {
        categoryExpenses[row['category_name'] as String] =
            row['total'] as double;
      }
      return categoryExpenses;
    } catch (e) {
      print('Error getting category wise expenses: $e');
      return {};
    }
  }

  // Get daily spending for last N days (for bar chart)
  Future<Map<DateTime, double>> getDailySpending({int days = 7}) async {
    try {
      final db = await _databaseService.database;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final result = await db.rawQuery(
        '''
        SELECT 
          DATE(date) as day,
          SUM(amount) as total
        FROM ${AppConstants.tableTransactions}
        WHERE type = ? AND date BETWEEN ? AND ?
        GROUP BY DATE(date)
        ORDER BY date ASC
      ''',
        [
          TransactionType.expense.toString(),
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
      );

      Map<DateTime, double> dailySpending = {};
      for (var row in result) {
        final date = DateTime.parse(row['day'] as String);
        dailySpending[date] = row['total'] as double;
      }
      return dailySpending;
    } catch (e) {
      print('Error getting daily spending: $e');
      return {};
    }
  }

  // Delete all transactions
  Future<int> deleteAllTransactions() async {
    try {
      final db = await _databaseService.database;
      return await db.delete(AppConstants.tableTransactions);
    } catch (e) {
      print('Error deleting all transactions: $e');
      return 0;
    }
  }

  // Helper: Map single result to TransactionModel with category
  TransactionModel _mapToTransaction(Map<String, dynamic> map) {
    final transaction = TransactionModel.fromMap(map);

    // Add category if exists
    if (map['cat_id'] != null) {
      transaction.category = CategoryModel.fromMap({
        'id': map['cat_id'],
        'name': map['cat_name'],
        'type': map['cat_type'],
        'transaction_type': map['cat_transaction_type'],
      });
    }

    return transaction;
  }

  // Helper: Map list of results to List<TransactionModel>
  List<TransactionModel> _mapToTransactions(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return _mapToTransaction(maps[i]);
    });
  }
}
