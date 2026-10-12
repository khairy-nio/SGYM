import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class GymFilterOptions {
  String sortBy; // 'distance', 'rating', 'price_asc', 'price_desc'
  double maxDistance; // in km
  double maxPrice; // in EGP
  double minRating; // 0, 4.0, 4.5, 4.8
  bool openNowOnly;
  String gender; // 'All', 'Mixed', 'Ladies Only'
  Set<String> selectedServices;
  Set<String> selectedFacilities;

  GymFilterOptions({
    this.sortBy = 'distance',
    this.maxDistance = 15.0,
    this.maxPrice = 2500.0,
    this.minRating = 0.0,
    this.openNowOnly = false,
    this.gender = 'All',
    Set<String>? selectedServices,
    Set<String>? selectedFacilities,
  })  : selectedServices = selectedServices ?? {},
        selectedFacilities = selectedFacilities ?? {};

  GymFilterOptions clone() {
    return GymFilterOptions(
      sortBy: sortBy,
      maxDistance: maxDistance,
      maxPrice: maxPrice,
      minRating: minRating,
      openNowOnly: openNowOnly,
      gender: gender,
      selectedServices: Set.from(selectedServices),
      selectedFacilities: Set.from(selectedFacilities),
    );
  }

  int get activeFiltersCount {
    int count = 0;
    if (sortBy != 'distance') count++;
    if (maxDistance < 15.0) count++;
    if (maxPrice < 2500.0) count++;
    if (minRating > 0.0) count++;
    if (openNowOnly) count++;
    if (gender != 'All') count++;
    count += selectedServices.length;
    count += selectedFacilities.length;
    return count;
  }
}

class FilterBottomSheet extends StatefulWidget {
  final GymFilterOptions initialFilters;
  final Function(GymFilterOptions) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<GymFilterOptions?> show(
    BuildContext context,
    GymFilterOptions currentFilters,
  ) {
    return showModalBottomSheet<GymFilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialFilters: currentFilters,
        onApply: (filters) => Navigator.pop(context, filters),
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late GymFilterOptions _filters;

  final List<String> _availableServices = const [
    'Weight Training',
    'Personal Training',
    'CrossFit',
    'Boxing Academy',
    'Swimming Lessons',
    'Yoga & Pilates',
    'Nutrition Coaching',
    'Physiotherapy',
  ];

  final List<String> _availableFacilities = const [
    'Swimming Pool',
    'Sauna',
    'Steam Room',
    'Free Weights',
    'Eleiko Plates',
    'Boxing Ring',
    'Pro Shop',
    'Juice Bar',
    'Valet Parking',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.clone();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters & Sort',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters = GymFilterOptions();
                    });
                  },
                  child: Text(
                    'Reset All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                // 1. Sort By
                _buildSectionHeader('Sort Gyms By'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortPill('Nearest First', 'distance', Icons.near_me_rounded),
                    _buildSortPill('Highest Rating', 'rating', Icons.star_rounded),
                    _buildSortPill('Lowest Price', 'price_asc', Icons.arrow_downward_rounded),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. Open Now Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time_filled_rounded,
                            color: Color(0xFF00E676), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open Right Now',
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Show only gyms operating at this hour',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _filters.openNowOnly,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _filters.openNowOnly = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Gender Environment
                _buildSectionHeader('Gym Environment / Gender'),
                Row(
                  children: [
                    Expanded(child: _buildGenderCard('All Gyms', 'All', Icons.groups_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGenderCard('Mixed', 'Mixed', Icons.wc_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildGenderCard('Ladies Only', 'Ladies Only', Icons.female_rounded)),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Maximum Monthly Budget
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Starting Price Limit'),
                    Text(
                      'Up to EGP ${_filters.maxPrice.toInt()}/mo',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _filters.maxPrice,
                  min: 500,
                  max: 2500,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _filters.maxPrice = val),
                ),

                const SizedBox(height: 20),

                // 5. Minimum Rating
                _buildSectionHeader('Minimum Rating'),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildRatingPill('Any', 0.0),
                    _buildRatingPill('4.0+ ★', 4.0),
                    _buildRatingPill('4.5+ ★', 4.5),
                    _buildRatingPill('4.8+ ★', 4.8),
                  ],
                ),

                const SizedBox(height: 24),

                // 6. Services Filter
                _buildSectionHeader('Key Services Offered'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableServices.map((service) {
                    final isSelected = _filters.selectedServices.contains(service);
                    return FilterChip(
                      label: Text(service),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _filters.selectedServices.add(service);
                          } else {
                            _filters.selectedServices.remove(service);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // 7. Facilities Filter
                _buildSectionHeader('Facilities & Amenities'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableFacilities.map((facility) {
                    final isSelected = _filters.selectedFacilities.contains(facility);
                    return FilterChip(
                      label: Text(facility),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _filters.selectedFacilities.add(facility);
                          } else {
                            _filters.selectedFacilities.remove(facility);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Bottom CTA Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => widget.onApply(_filters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Apply Filters (${_filters.activeFiltersCount} Active)',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSortPill(String label, String value, IconData icon) {
    final isSelected = _filters.sortBy == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _filters.sortBy = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingPill(String label, double rating) {
    final isSelected = _filters.minRating == rating;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _filters.minRating = rating),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String label, String value, IconData icon) {
    final isSelected = _filters.gender == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _filters.gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
