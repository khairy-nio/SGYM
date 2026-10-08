import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class GymsScreen extends ConsumerStatefulWidget {
  const GymsScreen({super.key});

  @override
  ConsumerState<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends ConsumerState<GymsScreen> {
  String _selectedCity = 'All';
  String _sortBy = 'distance';

  final List<String> _cities = ['All', 'Nasr City', 'Heliopolis', 'New Cairo', 'Maadi', '6th of October'];

  @override
  Widget build(BuildContext context) {
    final gyms = ref.watch(gymsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<GymModel> filtered = _selectedCity == 'All'
        ? gyms
        : gyms.where((g) => g.city == _selectedCity).toList();

    if (_sortBy == 'distance') {
      filtered.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            title: const Text('Explore Gyms'),
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Container(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                child: Column(
                  children: [
                    // Filter chips
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: _cities.length,
                        itemBuilder: (_, i) {
                          final city = _cities[i];
                          final isSelected = _selectedCity == city;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCity = city),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Text(
                                city,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Sort row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} gyms found',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text('Sort: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => setState(() => _sortBy = _sortBy == 'distance' ? 'rating' : 'distance'),
                            child: Text(
                              _sortBy == 'distance' ? 'Distance' : 'Rating',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: filtered.isEmpty
            ? const EmptyState(
                icon: Icons.location_off_outlined,
                title: 'No Gyms Found',
                message: 'Try selecting a different city',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: filtered.length,
                itemBuilder: (_, i) => GymListCard(gym: filtered[i]),
              ),
      ),
    );
  }
}

// ── GYM LIST CARD ──────────────────────────────────────────────────────────

class GymListCard extends ConsumerWidget {
  final GymModel gym;
  const GymListCard({super.key, required this.gym});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/gym/${gym.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: AppNetworkImage(url: gym.imageUrl, width: 110, height: 110),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(gym.name, style: AppTextStyles.titleMedium,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: gym.isOpen ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            gym.isOpen ? 'Open' : 'Closed',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: gym.isOpen ? AppColors.success : AppColors.error,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(gym.address, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingWidget(rating: gym.rating, reviewCount: gym.reviewCount, size: 13),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.directions_walk_rounded, size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${gym.distance} km away',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                        ),
                        const Spacer(),
                        FavoriteButton(
                          isFavorite: gym.isFavorite,
                          size: 30,
                          onTap: () => ref.read(gymsProvider.notifier).toggleFavorite(gym.id),
                        ),
                      ],
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
