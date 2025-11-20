import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:personal_finance_manager/app/constants/app_constants.dart';
import 'package:personal_finance_manager/modules/add_transaction/controllers/add_transaction_controller.dart';
import 'package:personal_finance_manager/utils/enums/transaction_type.dart';
import 'package:personal_finance_manager/utils/helpers/date_helper.dart';

class AddTransactionView extends GetView<AddTransactionController> {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.editingTransaction != null
              ? 'Edit Transaction'
              : 'Add Transaction',
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Transaction Type Toggle
              _buildTypetoggle(context),
              const SizedBox(height: 24),
              // Amount Input
              _buidAmountInput(context),
              const SizedBox(height: 24),
              // Category Selection
              _buildCategorySelection(context),
              const SizedBox(height: 24),
              // Date Selection
              _buildDateSelection(context),
              const SizedBox(height: 24),
              // Note Input
              _buildNoteInput(context),
              const SizedBox(height: 32),
              // Save Button
              _buildSaveButton(context),
            ],
          ),
        );
      }),
    );
  }

  // Transaction Type Toggle (Income/Expense)
  Widget _buildTypetoggle(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                context: context,
                type: TransactionType.expense,
                label: 'Expense',
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
            Expanded(
              child: _buildTypeButton(
                context: context,
                type: TransactionType.income,
                label: 'Income',
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = controller.selectedType.value == type;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => controller.changeTransactionType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Amount Input
  Widget _buidAmountInput(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: AppConstants.currencySymbol,
            prefixStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            hintText: '0.00',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Category Selection
  Widget _buildCategorySelection(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No categories available'),
              ),
            );
          }
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.categories.map((element) {
              final isSelected =
                  controller.selectedCategory.value?.id == element.id;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.selectCategory(element),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? element.type.color.withValues(alpha: 0.15)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? element.type.color
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        element.type.icon,
                        color: element.type.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        element.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? element.type.color : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // Date Selection
  Widget _buildDateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return InkWell(
            onTap: () => controller.selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateHelper.formatDate(controller.selectedDate.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // Note Input
  Widget _buildNoteInput(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const Text(
          'Note (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.noteController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Add a note...',
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // Save Button
  Widget _buildSaveButton(BuildContext context) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isSaving.value
              ? null
              : controller.saveTransaction,
          child: controller.isSaving.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  controller.editingTransaction != null
                      ? 'Update Transaction'
                      : 'Save Transaction',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }
}
