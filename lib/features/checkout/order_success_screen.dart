import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderNumber;
  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: const Interval(0, 0.4)),
    );
    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated check circle
                AnimatedBuilder(
                  animation: _checkController,
                  builder: (_, __) => Opacity(
                    opacity: _checkOpacity.value,
                    child: Transform.scale(
                      scale: _checkScale.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          gradient: AppColors.successGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Content
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      children: [
                        Text('Order Confirmed 🎉',
                            style: AppTextStyles.displaySmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          'Your order has been placed successfully.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Order number
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text('Order Number',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(widget.orderNumber,
                                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Steps
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _StepRow(icon: Icons.check_circle_rounded, label: 'Order placed', isDone: true),
                              _StepDivider(),
                              _StepRow(icon: Icons.inventory_rounded, label: 'Preparing your order', isDone: false),
                              _StepDivider(),
                              _StepRow(icon: Icons.local_shipping_outlined, label: 'On the way', isDone: false),
                              _StepDivider(),
                              _StepRow(icon: Icons.home_rounded, label: 'Delivered', isDone: false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          label: 'View Order',
                          onPressed: () => context.go('/orders'),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Continue Shopping',
                          onPressed: () => context.go('/home'),
                          isOutlined: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;

  const _StepRow({required this.icon, required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: isDone ? AppColors.success : AppColors.textTertiary),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(
          color: isDone ? Theme.of(context).colorScheme.onSurface : AppColors.textTertiary,
        )),
        if (isDone) ...[
          const Spacer(),
          const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
        ],
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: AppColors.border,
      ),
    );
  }
}
