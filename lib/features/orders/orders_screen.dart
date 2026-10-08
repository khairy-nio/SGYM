import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Processing'),
              Tab(text: 'Ready'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(orders: orders),
            _OrderList(orders: orders.where((o) => o.status == OrderStatus.processing).toList()),
            _OrderList(orders: orders.where((o) => o.status == OrderStatus.ready).toList()),
            _OrderList(orders: orders.where((o) => o.status == OrderStatus.completed).toList()),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders',
        message: 'Your orders will appear here',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusStr = order.status.name;

    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(order.orderNumber, style: AppTextStyles.titleMedium),
                      const Spacer(),
                      StatusBadge(status: statusStr),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(order.date),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 12),
                  // Product images
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        ...order.items.take(3).map((item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AppNetworkImage(url: item.imageUrl, width: 44, height: 44),
                          ),
                        )),
                        if (order.items.length > 3)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('+${order.items.length - 3}',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                            ),
                          ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                            Text('EGP ${order.total.toStringAsFixed(0)}',
                                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }
}

// ── ORDER DETAIL ───────────────────────────────────────────────────────────

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => orders.first,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderNumber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          StatusBadge(status: order.status.name),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Status', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),
                  _StatusStep(label: 'Order Placed', sublabel: _formatDate(order.date), isDone: true),
                  _StepLine(),
                  _StatusStep(
                    label: 'Processing',
                    sublabel: 'Gym is preparing your order',
                    isDone: order.status != OrderStatus.processing,
                    isActive: order.status == OrderStatus.processing,
                  ),
                  _StepLine(),
                  _StatusStep(
                    label: 'Ready for Pickup / Delivery',
                    sublabel: 'Your order is ready',
                    isDone: order.status == OrderStatus.completed,
                    isActive: order.status == OrderStatus.ready,
                  ),
                  _StepLine(),
                  _StatusStep(
                    label: 'Delivered',
                    sublabel: 'Order completed',
                    isDone: order.status == OrderStatus.completed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Items', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppNetworkImage(url: item.imageUrl, width: 60, height: 60),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: AppTextStyles.titleSmall),
                              Text(item.gymName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                              Text('x${item.quantity}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text('EGP ${item.total.toStringAsFixed(0)}', style: AppTextStyles.titleSmall),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Summary', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _Row('Subtotal', 'EGP ${order.subtotal.toStringAsFixed(0)}'),
                  if (order.discount > 0) _Row('Discount', '-EGP ${order.discount.toStringAsFixed(0)}', color: AppColors.success),
                  _Row('Delivery', 'EGP ${order.deliveryFee.toStringAsFixed(0)}'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                  _Row('Total', 'EGP ${order.total.toStringAsFixed(0)}', isTotal: true),
                  const SizedBox(height: 12),
                  _Row('Payment', order.paymentMethod),
                  const SizedBox(height: 4),
                  _Row('Delivery To', order.deliveryAddress),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _Row(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
              textAlign: TextAlign.end,
              style: isTotal
                  ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
                  : AppTextStyles.titleSmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day} at ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isDone;
  final bool isActive;

  const _StatusStep({
    required this.label,
    required this.sublabel,
    this.isDone = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.success : isActive ? AppColors.primary : AppColors.textTertiary;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone || isActive ? color.withOpacity(0.15) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: isDone ? Icon(Icons.check_rounded, size: 14, color: color) : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.titleSmall.copyWith(
              color: isDone || isActive ? null : AppColors.textTertiary,
            )),
            Text(sublabel, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: Container(width: 2, height: 20, color: AppColors.border),
    );
  }
}
