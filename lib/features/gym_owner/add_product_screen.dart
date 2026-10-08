import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textTertiary),
                    const SizedBox(height: 8),
                    Text('Upload Image', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(label: 'Product Name', hint: 'e.g. Optimum Nutrition Gold Standard'),
            const SizedBox(height: 16),
            AppTextField(label: 'Price (EGP)', hint: '0.00', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            AppTextField(label: 'Description', hint: 'Describe the product...', maxLines: 4),
            const SizedBox(height: 32),
            AppButton(label: 'Save Product', onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
