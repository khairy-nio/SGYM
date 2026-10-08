import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const deliveryFee = 50.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Cart?'),
                    content: const Text('Remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your Cart is Empty',
              message: 'Add products from gyms near you',
              buttonLabel: 'Explore Products',
              onButtonPressed: () => context.go('/home'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (_, i) => _CartItemCard(item: cartItems[i]),
                  ),
                ),
                // Order summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _SummaryRow(label: 'Subtotal', value: 'EGP ${subtotal.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _SummaryRow(label: 'Delivery', value: 'EGP ${deliveryFee.toStringAsFixed(0)}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        _SummaryRow(
                          label: 'Total',
                          value: 'EGP ${total.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Proceed to Checkout',
                          onPressed: () => context.push('/checkout'),
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(cartProvider.notifier).removeItem(item.product.id),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: AppNetworkImage(url: item.product.imageUrl, width: 90, height: 100),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: AppTextStyles.titleSmall,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(item.product.gymName,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriceWidget(price: item.product.finalPrice, fontSize: 14),
                        const Spacer(),
                        // Quantity control
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(cartProvider.notifier).updateQuantity(
                                    item.product.id, item.quantity - 1,
                                  );
                                },
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Icon(Icons.remove_rounded, size: 16,
                                      color: item.quantity <= 1 ? AppColors.textTertiary : null),
                                ),
                              ),
                              Text('${item.quantity}', style: AppTextStyles.titleSmall),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(cartProvider.notifier).updateQuantity(
                                    item.product.id, item.quantity + 1,
                                  );
                                },
                                child: const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Icon(Icons.add_rounded, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: EGP ${item.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)
              : AppTextStyles.titleSmall,
        ),
      ],
    );
  }
}
