import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class GymDetailScreen extends ConsumerStatefulWidget {
  final String gymId;
  const GymDetailScreen({super.key, required this.gymId});

  @override
  ConsumerState<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends ConsumerState<GymDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Overview', 'Products', 'Offers', 'Photos'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(gymByIdProvider(widget.gymId));
    if (gym == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final gymProducts = ref.watch(productsProvider.notifier).getByGym(widget.gymId);
    final gymOffers = ref.watch(offersProvider).where((o) => o.gymId == widget.gymId).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    gym.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: gym.isFavorite ? AppColors.error : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => ref.read(gymsProvider.notifier).toggleFavorite(gym.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(url: gym.coverUrl),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                          ),
                          child: Center(
                            child: Text(gym.name[0],
                                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(gym.name, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                              const SizedBox(height: 4),
                              RatingWidget(rating: gym.rating, reviewCount: gym.reviewCount, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: AppTextStyles.titleSmall,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(gym: gym),
            _ProductsTab(products: gymProducts),
            _OffersTab(offers: gymOffers),
            _PhotosTab(photos: gym.photos),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Call'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${gym.phone}...')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.store_rounded, size: 18),
                  label: const Text('View Products'),
                  onPressed: () => _tabController.animateTo(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TABS ───────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final GymModel gym;
  const _OverviewTab({required this.gym});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats row
        Row(
          children: [
            _StatChip(icon: Icons.star_rounded, label: '${gym.rating}', sublabel: 'Rating', color: AppColors.star),
            const SizedBox(width: 12),
            _StatChip(icon: Icons.group_rounded, label: '${gym.reviewCount}', sublabel: 'Reviews', color: AppColors.primary),
            const SizedBox(width: 12),
            _StatChip(icon: Icons.directions_walk_rounded, label: '${gym.distance}km', sublabel: 'Away', color: AppColors.secondary),
          ],
        ),
        const SizedBox(height: 20),
        // Hours
        _InfoRow(icon: Icons.schedule_rounded, label: 'Hours',
            value: '${gym.openingHours} - ${gym.closingHours}'),
        const Divider(height: 24),
        _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: gym.address),
        const Divider(height: 24),
        _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: gym.phone),
        const Divider(height: 24),
        // About
        Text('About', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        Text(gym.about, style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          height: 1.6,
        )),
        const SizedBox(height: 20),
        // Facilities
        Text('Facilities', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: gym.facilities.map((f) => Chip(
            label: Text(f),
            labelStyle: AppTextStyles.labelSmall,
            backgroundColor: AppColors.primaryLight,
            side: BorderSide.none,
          )).toList(),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.titleSmall.copyWith(color: color)),
            Text(sublabel, style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 10,
            )),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  final List<ProductModel> products;
  const _ProductsTab({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Products',
        message: 'This gym hasn\'t added products yet',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p = products[i];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: () => context.push('/product/${p.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AppNetworkImage(url: p.imageUrl, height: 120, width: double.infinity),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: AppTextStyles.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      PriceWidget(
                        price: p.finalPrice,
                        originalPrice: p.hasDiscount ? p.price : null,
                        fontSize: 13,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addItem(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${p.name} added'), duration: const Duration(seconds: 1)),
                          );
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('+ Add to Cart', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OffersTab extends StatelessWidget {
  final List<OfferModel> offers;
  const _OffersTab({required this.offers});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const EmptyState(
        icon: Icons.local_offer_outlined,
        title: 'No Offers',
        message: 'No active offers from this gym',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: offers.length,
      itemBuilder: (_, i) => _OfferMiniCard(offer: offers[i]),
    );
  }
}

class _OfferMiniCard extends StatelessWidget {
  final OfferModel offer;
  const _OfferMiniCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = offer.expiryDate.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: AppNetworkImage(url: offer.imageUrl, width: 90, height: 90),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.productName, style: AppTextStyles.titleSmall,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'EGP ${offer.discountedPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EGP ${offer.originalPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      DiscountBadge(percent: offer.discountPercent),
                      const Spacer(),
                      Text(
                        '$daysLeft days left',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
                      ),
                    ],
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

class _PhotosTab extends StatelessWidget {
  final List<String> photos;
  const _PhotosTab({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (_, i) => AppNetworkImage(url: photos[i]),
    );
  }
}
