import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../../data/mock/mock_data.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _promoController = TextEditingController();
  bool _isPlacingOrder = false;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    final cartItems = ref.read(cartProvider);
    final checkout = ref.read(checkoutProvider);
    final subtotal = ref.read(cartSubtotalProvider);
    final promoDiscount = (checkout['promoDiscount'] as double?) ?? 0.0;
    const deliveryFee = 50.0;
    final discount = subtotal * promoDiscount;
    final total = subtotal - discount + deliveryFee;
    final address = checkout['selectedAddress'] as AddressModel;
    final payment = checkout['selectedPayment'] as PaymentMethodModel;

    final orderNumber = '#GYM${10200 + (DateTime.now().millisecondsSinceEpoch % 1000)}';
    final order = OrderModel(
      id: const Uuid().v4(),
      orderNumber: orderNumber,
      date: DateTime.now(),
      items: cartItems.map((item) => OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        imageUrl: item.product.imageUrl,
        price: item.product.finalPrice,
        quantity: item.quantity,
        gymName: item.product.gymName,
      )).toList(),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      status: OrderStatus.processing,
      deliveryAddress: address.fullAddress,
      paymentMethod: payment.label,
    );

    ref.read(ordersProvider.notifier).addOrder(order);
    ref.read(cartProvider.notifier).clear();
    ref.read(checkoutProvider.notifier).reset();

    if (mounted) {
      context.go('/order-success?orderNumber=$orderNumber');
    }
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    final promo = MockData.promoCodes.firstWhere(
      (p) => p.code == code,
      orElse: () => const PromoCode(code: '', discountPercent: 0, description: '', isValid: false),
    );

    if (promo.code.isEmpty) {
      setState(() => _promoError = 'Invalid promo code');
      ref.read(checkoutProvider.notifier).removePromo();
    } else if (!promo.isValid) {
      setState(() => _promoError = 'This promo code has expired');
      ref.read(checkoutProvider.notifier).removePromo();
    } else {
      setState(() => _promoError = null);
      ref.read(checkoutProvider.notifier).applyPromo(promo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${promo.discountPercent}% discount applied! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final promoDiscount = (checkout['promoDiscount'] as double?) ?? 0.0;
    final promoCode = checkout['promoCode'] as PromoCode?;
    const deliveryFee = 50.0;
    final discount = subtotal * promoDiscount;
    final total = subtotal - discount + deliveryFee;
    final selectedAddress = checkout['selectedAddress'] as AddressModel;
    final selectedPayment = checkout['selectedPayment'] as PaymentMethodModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            _SectionCard(
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              action: 'Change',
              onAction: () => _showAddressSheet(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(selectedAddress.label,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                      ),
                      if (selectedAddress.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Default',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(selectedAddress.fullAddress, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Summary
            _SectionCard(
              title: 'Order Summary',
              icon: Icons.receipt_outlined,
              child: Column(
                children: [
                  ...cartItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppNetworkImage(url: item.product.imageUrl, width: 50, height: 50),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: AppTextStyles.titleSmall,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('x${item.quantity}',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                        Text('EGP ${item.totalPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.titleSmall),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            _SectionCard(
              title: 'Payment Method',
              icon: Icons.payment_outlined,
              action: 'Change',
              onAction: () => _showPaymentSheet(context),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(
                        selectedPayment.type == 'apple_pay'
                            ? Icons.apple
                            : selectedPayment.type == 'card'
                                ? Icons.credit_card_rounded
                                : Icons.money_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(selectedPayment.label, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Promo Code
            _SectionCard(
              title: 'Promo Code',
              icon: Icons.local_offer_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: promoCode != null ? '${promoCode.code} applied ✓' : 'Enter code (try GYMIO20)',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: promoCode != null ? AppColors.success : AppColors.textTertiary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        errorText: _promoError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _applyPromo,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 46),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Price breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              child: Column(
                children: [
                  _PriceRow(label: 'Subtotal', value: 'EGP ${subtotal.toStringAsFixed(0)}'),
                  if (discount > 0) ...[
                    const SizedBox(height: 10),
                    _PriceRow(
                      label: 'Discount (${(promoDiscount * 100).toInt()}%)',
                      value: '-EGP ${discount.toStringAsFixed(0)}',
                      valueColor: AppColors.success,
                    ),
                  ],
                  const SizedBox(height: 10),
                  _PriceRow(label: 'Delivery', value: 'EGP ${deliveryFee.toStringAsFixed(0)}'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                  _PriceRow(
                    label: 'Total',
                    value: 'EGP ${total.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isPlacingOrder ? 'Placing Order...' : 'Place Order',
              onPressed: cartItems.isEmpty ? null : _placeOrder,
              isLoading: _isPlacingOrder,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '🔒 Secured checkout',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Address', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            ...MockData.addresses.map((addr) {
              final isSelected = ref.read(checkoutProvider)['selectedAddress'] == addr;
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                ),
                title: Text(addr.label),
                subtitle: Text(addr.street, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(checkoutProvider.notifier).setAddress(addr);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Payment', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            ...MockData.paymentMethods.map((pm) {
              final isSelected = ref.read(checkoutProvider)['selectedPayment'] == pm;
              return ListTile(
                leading: Icon(
                  pm.type == 'apple_pay' ? Icons.apple : pm.type == 'card' ? Icons.credit_card_rounded : Icons.money_rounded,
                  color: AppColors.primary,
                ),
                title: Text(pm.label),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () {
                  ref.read(checkoutProvider.notifier).setPayment(pm);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleMedium),
              const Spacer(),
              if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(action!,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            )),
        Text(value,
            style: isTotal
                ? AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)
                : AppTextStyles.titleSmall.copyWith(color: valueColor)),
      ],
    );
  }
}
