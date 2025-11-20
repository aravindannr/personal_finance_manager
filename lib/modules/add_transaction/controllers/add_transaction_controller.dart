import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/data/models/category_model.dart';
import 'package:personal_finance_manager/data/models/transaction_model.dart';
import 'package:personal_finance_manager/data/repositories/category_repository.dart';
import 'package:personal_finance_manager/data/repositories/transaction_repository.dart';
import 'package:personal_finance_manager/utils/enums/transaction_type.dart';

class AddTransactionController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Form controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Observable variables
  final Rx<TransactionType> selectedType = TransactionType.expense.obs;
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // For editing existing transaction
  TransactionModel? editingTransaction;

  @override
  void onInit() {
    super.onInit();
    // Check if we're editing a transaction
    if (Get.arguments != null && Get.arguments is TransactionModel) {
      editingTransaction = Get.arguments as TransactionModel;
      _loadTransactionForEdit();
    }
    loadCategories();
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // Load transaction data for editing
  void _loadTransactionForEdit() {
    if (editingTransaction != null) {
      amountController.text = editingTransaction!.amount.toString();
      noteController.text = editingTransaction!.note;
      selectedType.value = editingTransaction!.type;
      selectedDate.value = editingTransaction!.date;
      // selectedCategory will be set after categories are loaded
    }
  }

  // Load categories based on transaction type

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final loadedCategories = await _categoryRepository.getCategoriesByType(
        selectedType.value,
      );
      categories.value = loadedCategories;

      // Set selected category for editing
      if (editingTransaction != null && categories.isNotEmpty) {
        selectedCategory.value = categories.firstWhereOrNull(
          (element) => element.id == editingTransaction!.categoryId,
        );
      }

      // Auto-select first category if none selected
      if (selectedCategory.value == null && categories.isNotEmpty) {
        selectedCategory.value = categories.first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load categories',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Change transaction type (Income/Expense)
  void changeTransactionType(TransactionType type) {
    if (selectedType.value != type) {
      selectedType.value = type;
      selectedCategory.value = null; // Reset category
      loadCategories(); // Load categories for new type
    }
  }

  // Select category
  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  // Select date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  // Validate form
  bool _validateForm() {
    if (amountController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }

    if (selectedCategory.value == null) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }

    return true;
  }

  // Save transaction
  Future<void> saveTransaction() async {
    if (!_validateForm()) return;
    try {
      isSaving.value = true;

      final amount = double.parse(amountController.text.trim());
      final note = noteController.text.trim();

      final transaction = TransactionModel(
        id: editingTransaction?.id,
        amount: amount,
        type: selectedType.value,
        categoryId: selectedCategory.value!.id!,
        note: note,
        date: selectedDate.value,
        createdAt: editingTransaction?.createdAt,
      );
      if (editingTransaction != null) {
        // Update existing transaction
        await _transactionRepository.updateTransaction(transaction);
        Get.snackbar(
          'Success',
          'Transaction updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        // Insert new transaction
        await _transactionRepository.insertTransaction(transaction);
        Get.snackbar(
          'Success',
          'Transaction added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      }
      // Go back
      Get.back(result: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving transaction: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to save transaction',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
