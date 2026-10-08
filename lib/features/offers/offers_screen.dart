import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(offersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Offers & Deals')),
      body: offers.isEmpty
          ? const EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No Offers',
              message: 'Check back later for new deals',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.offerGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🏷️ Exclusive Deals',
                                style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Save up to 25% on\nfitness products',
                                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('🎁', style: TextStyle(fontSize: 32))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('${offers.length} Active Offers',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ...offers.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _OfferCard(offer: offer),
                )),
              ],
            ),
    );
  }
}

class _OfferCard extends ConsumerWidget {
  final OfferModel offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = offer.expiryDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;

    return GestureDetector(
      onTap: () => context.push('/product/${offer.productId}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent
                ? AppColors.error.withOpacity(0.3)
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isUrgent ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: AppNetworkImage(url: offer.imageUrl, width: 110, height: 120),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.productName, style: AppTextStyles.titleMedium,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.store_outlined, size: 13, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Expanded(child: Text(offer.gymName,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text('${offer.gymDistance} km',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EGP ${offer.discountedPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
                                ),
                                Text(
                                  'EGP ${offer.originalPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            DiscountBadge(percent: offer.discountPercent, fontSize: 13),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.error.withOpacity(0.06) : AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: isUrgent ? AppColors.error : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    daysLeft <= 0
                        ? 'Expires today!'
                        : isUrgent
                            ? 'Expires in $daysLeft days!'
                            : 'Expires in $daysLeft days',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isUrgent ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Save EGP ${offer.savings.toStringAsFixed(0)}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


