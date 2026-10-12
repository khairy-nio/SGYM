import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../data/mock/mock_gyms.dart';
import 'widgets/gym_card.dart';
import 'widgets/gym_map_view.dart';
import 'widgets/filter_bottom_sheet.dart';

class GymsScreen extends ConsumerStatefulWidget {
  const GymsScreen({super.key});

  @override
  ConsumerState<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends ConsumerState<GymsScreen> {
  String _selectedArea = 'All Areas';
  String _sortBy = 'distance';
  bool _isMapView = false;
  GymFilterOptions _filters = GymFilterOptions();

  @override
  Widget build(BuildContext context) {
    final gyms = ref.watch(gymsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<GymModel> filtered = _selectedArea == 'All Areas'
        ? List.from(gyms)
        : gyms.where((g) => g.area == _selectedArea).toList();

    if (_filters.openNowOnly) {
      filtered = filtered.where((g) => g.isOpen).toList();
    }
    if (_filters.maxPrice < 2500.0) {
      filtered = filtered.where((g) => g.startingPrice <= _filters.maxPrice).toList();
    }
    if (_filters.minRating > 0.0) {
      filtered = filtered.where((g) => g.rating >= _filters.minRating).toList();
    }
    if (_filters.gender != 'All') {
      filtered = filtered.where((g) => g.gender == _filters.gender).toList();
    }

    if (_sortBy == 'distance') {
      filtered.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'price') {
      filtered.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Gyms'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isMapView ? Icons.view_agenda_rounded : Icons.map_rounded,
              color: AppColors.primary,
            ),
            tooltip: _isMapView ? 'Show List' : 'Show Map',
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () async {
              final result = await FilterBottomSheet.show(context, _filters);
              if (result != null) {
                setState(() => _filters = result);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Area Selector Pills
          Container(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: MockGyms.popularAreas.length,
                itemBuilder: (_, i) {
                  final area = MockGyms.popularAreas[i];
                  final isSelected = _selectedArea == area;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedArea = area),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          area,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Count & Sort row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Text(
                  '${filtered.length} gyms available',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text('Sort: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_sortBy == 'distance') {
                        _sortBy = 'rating';
                      } else if (_sortBy == 'rating') {
                        _sortBy = 'price';
                      } else {
                        _sortBy = 'distance';
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _sortBy == 'distance'
                          ? 'Distance ▾'
                          : (_sortBy == 'rating' ? 'Rating ▾' : 'Price ▾'),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main View (Map or List)
          Expanded(
            child: _isMapView
                ? GymMapView(
                    gyms: filtered,
                    currentArea: _selectedArea,
                  )
                : (filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_off_rounded, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text('No gyms found in $_selectedArea', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() => _selectedArea = 'All Areas'),
                              child: const Text('View All Areas'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => GymCard(
                          gym: filtered[i],
                          onFavoriteToggle: () {
                            ref.read(gymsProvider.notifier).toggleFavorite(filtered[i].id);
                          },
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}
