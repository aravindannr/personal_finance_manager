import 'package:sqflite/sqflite.dart';
import '../../app/constants/app_constants.dart';
import '../../utils/enums/transaction_type.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableCategories,
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return CategoryModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Get categories by transaction type (income or expense)
  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableCategories,
        where: 'transaction_type = ?',
        whereArgs: [type.toString()],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return CategoryModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting categories by type: $e');
      return [];
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableCategories,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return CategoryModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting category by id: $e');
      return null;
    }
  }

  // Insert category
  Future<int> insertCategory(CategoryModel category) async {
    try {
      final db = await _databaseService.database;
      return await db.insert(
        AppConstants.tableCategories,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting category: $e');
      return 0;
    }
  }

  // Update category
  Future<int> updateCategory(CategoryModel category) async {
    try {
      final db = await _databaseService.database;
      return await db.update(
        AppConstants.tableCategories,
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      print('Error updating category: $e');
      return 0;
    }
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    try {
      final db = await _databaseService.database;
      return await db.delete(
        AppConstants.tableCategories,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting category: $e');
      return 0;
    }
  }
}
