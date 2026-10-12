import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../gyms/widgets/gym_card.dart';
import '../gyms/widgets/gym_map_view.dart';
import '../gyms/widgets/filter_bottom_sheet.dart';
import '../gyms/widgets/area_selector_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMapView = false;
  String _activeQuickFilter = 'All';

  GymFilterOptions _filters = GymFilterOptions();

  final List<String> _quickFilterTags = const [
    'All',
    'Open Now 🟢',
    'Under EGP 1000',
    'Rating 4.5+ ★',
    'Open 24/7',
    'Swimming Pool',
    'CrossFit',
    'Ladies Only',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GymModel> _filterAndSortGyms(List<GymModel> allGyms, String selectedArea) {
    List<GymModel> list = List.from(allGyms);

    // 1. Area filter (if not "All Areas")
    if (selectedArea != 'All Areas') {
      list = list.where((g) => g.area.toLowerCase() == selectedArea.toLowerCase()).toList();
    }

    // 2. Search query filter (matches name, type, services, facilities, area)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((g) {
        final matchesName = g.name.toLowerCase().contains(query);
        final matchesType = g.gymType.toLowerCase().contains(query);
        final matchesArea = g.area.toLowerCase().contains(query);
        final matchesService = g.services.any((s) => s.toLowerCase().contains(query));
        final matchesFacility = g.facilities.any((f) => f.toLowerCase().contains(query));
        final matchesGender = g.gender.toLowerCase().contains(query);
        final matches24h = query.contains('24') && g.is24Hours;

        return matchesName ||
            matchesType ||
            matchesArea ||
            matchesService ||
            matchesFacility ||
            matchesGender ||
            matches24h;
      }).toList();
    }

    // 3. Quick Filter Pill
    switch (_activeQuickFilter) {
      case 'Open Now 🟢':
        list = list.where((g) => g.isOpen).toList();
        break;
      case 'Under EGP 1000':
        list = list.where((g) => g.startingPrice <= 1000).toList();
        break;
      case 'Rating 4.5+ ★':
        list = list.where((g) => g.rating >= 4.5).toList();
        break;
      case 'Open 24/7':
        list = list.where((g) => g.is24Hours).toList();
        break;
      case 'Swimming Pool':
        list = list.where((g) => g.facilities.any((f) => f.toLowerCase().contains('pool'))).toList();
        break;
      case 'CrossFit':
        list = list.where((g) => g.services.any((s) => s.toLowerCase().contains('crossfit'))).toList();
        break;
      case 'Ladies Only':
        list = list.where((g) => g.gender == 'Ladies Only').toList();
        break;
    }

    // 4. Advanced Filter Criteria
    if (_filters.openNowOnly) {
      list = list.where((g) => g.isOpen).toList();
    }
    if (_filters.maxPrice < 2500.0) {
      list = list.where((g) => g.startingPrice <= _filters.maxPrice).toList();
    }
    if (_filters.minRating > 0.0) {
      list = list.where((g) => g.rating >= _filters.minRating).toList();
    }
    if (_filters.gender != 'All') {
      list = list.where((g) => g.gender == _filters.gender).toList();
    }
    if (_filters.selectedServices.isNotEmpty) {
      list = list.where((g) {
        return _filters.selectedServices.any((service) => g.services.contains(service));
      }).toList();
    }
    if (_filters.selectedFacilities.isNotEmpty) {
      list = list.where((g) {
        return _filters.selectedFacilities.any((facility) => g.facilities.contains(facility));
      }).toList();
    }

    // 5. Sorting
    switch (_filters.sortBy) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_asc':
        list.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
        break;
      case 'price_desc':
        list.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
        break;
      case 'distance':
      default:
        list.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final currentArea = ref.watch(locationProvider);
    final allGyms = ref.watch(gymsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredGyms = _filterAndSortGyms(allGyms, currentArea);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP HEADER SECTION ─────────────────────────────────────────────
            _buildTopHeader(context, currentArea, isDark),

            // ── PROMINENT SEARCH BAR ───────────────────────────────────────────
            _buildSearchBar(context, isDark),

            // ── HORIZONTAL QUICK FILTERS & ADVANCED BUTTON ─────────────────────
            _buildFiltersRow(context, isDark),

            // ── DISCOVERY CONTROLS ROW: RESULTS COUNT & LIST/MAP TOGGLE ────────
            _buildDiscoveryControls(context, filteredGyms.length, currentArea, isDark),

            // ── CONTENT BODY (LIST VIEW OR MAP VIEW) ───────────────────────────
            Expanded(
              child: _isMapView
                  ? GymMapView(
                      gyms: filteredGyms,
                      currentArea: currentArea,
                    )
                  : (filteredGyms.isEmpty
                      ? _buildEmptyState(context, currentArea, isDark)
                      : _buildGymsList(context, filteredGyms)),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER: SGYM LOGO, AREA SELECTOR & NOTIFICATIONS ───────────────────────
  Widget _buildTopHeader(BuildContext context, String currentArea, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: [
          // SGYM Brand Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'S',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: 'GYM',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Area / Location Selector Button
          GestureDetector(
            onTap: () async {
              final newArea = await AreaSelectorSheet.show(context, currentArea);
              if (newArea != null && newArea.isNotEmpty) {
                ref.read(locationProvider.notifier).state = newArea;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      currentArea,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Notification Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search gyms, services, facilities...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── HORIZONTAL FILTERS & ADVANCED BUTTON ───────────────────────────────────
  Widget _buildFiltersRow(BuildContext context, bool isDark) {
    final activeCount = _filters.activeFiltersCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // Advanced Filter Modal Button
            GestureDetector(
              onTap: () async {
                final applied = await FilterBottomSheet.show(context, _filters);
                if (applied != null) {
                  setState(() => _filters = applied);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: activeCount > 0
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activeCount > 0 ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: activeCount > 0 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeCount > 0 ? 'Filters ($activeCount)' : 'Filters',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: activeCount > 0 ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Quick Filter Pills
            ..._quickFilterTags.map((tag) {
              final isSelected = _activeQuickFilter == tag;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeQuickFilter = isSelected ? 'All' : tag;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.surfaceDark : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tag,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── DISCOVERY CONTROLS ROW: RESULTS COUNT & [LIST] [MAP] TOGGLE ────────────
  Widget _buildDiscoveryControls(
    BuildContext context,
    int count,
    String area,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Results Count & Area Label
          Row(
            children: [
              Text(
                '$count Gyms',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'in $area',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Segmented [ List ] [ Map ] Toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleItem(
                  title: 'List',
                  icon: Icons.view_agenda_rounded,
                  isActive: !_isMapView,
                  onTap: () => setState(() => _isMapView = false),
                  isDark: isDark,
                ),
                _buildToggleItem(
                  title: 'Map',
                  icon: Icons.map_rounded,
                  isActive: _isMapView,
                  onTap: () => setState(() => _isMapView = true),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.surfaceDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GYMS COMPARISON LIST ───────────────────────────────────────────────────
  Widget _buildGymsList(BuildContext context, List<GymModel> gyms) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: gyms.length,
      itemBuilder: (context, index) {
        final gym = gyms[index];
        return GymCard(
          gym: gym,
          onFavoriteToggle: () {
            ref.read(gymsProvider.notifier).toggleFavorite(gym.id);
          },
        );
      },
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, String area, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No gyms match "$_searchQuery"'
                  : 'No gyms found in $area',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search filters or discover top gyms in other areas like Nasr City, New Cairo, or Maadi.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _activeQuickFilter = 'All';
                      _filters = GymFilterOptions();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Reset Filters'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.read(locationProvider.notifier).state = 'All Areas';
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Explore All Areas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
