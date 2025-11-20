import 'package:path/path.dart';
import 'package:personal_finance_manager/app/constants/app_constants.dart';
import 'package:personal_finance_manager/data/models/category_model.dart';
import 'package:personal_finance_manager/utils/enums/category_type.dart';
import 'package:personal_finance_manager/utils/enums/transaction_type.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  // Singleton pattern
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  // Initialize Database
  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDb,
    );
  }

  // Create Tables
  Future<void> _createDb(Database db, int version) async {
    // Categories Table
    await db.execute(''' 
    CREATE TABLE ${AppConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        transaction_type TEXT NOT NULL
      )
    ''');

    // Transactions Table
    await db.execute(''' 
    CREATE TABLE ${AppConstants.tableTransactions} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category_id INTEGER NOT NULL,
      note TEXT,
      date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES ${AppConstants.tableCategories} (id)
          ON DELETE CASCADE
    )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final expenseCategories = [
      CategoryType.food,
      CategoryType.transport,
      CategoryType.shopping,
      CategoryType.bills,
      CategoryType.entertainment,
      CategoryType.health,
      CategoryType.education,
      CategoryType.other,
    ];

    final incomeCategories = [
      CategoryType.salary,
      CategoryType.freelance,
      CategoryType.investment,
      CategoryType.other,
    ];

    // Insert expense categories
    for (var catType in expenseCategories) {
      final category = CategoryModel(
        name: catType.name,
        type: catType,
        transactionType: TransactionType.expense,
      );
      await db.insert(AppConstants.tableCategories, category.toMap());
    }
    // Insert income categories
    for (var catType in incomeCategories) {
      final category = CategoryModel(
        name: catType.name,
        type: catType,
        transactionType: TransactionType.income,
      );
      await db.insert(AppConstants.tableCategories, category.toMap());
    }
  }

  // Close Database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
