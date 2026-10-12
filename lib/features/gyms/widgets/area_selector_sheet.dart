import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_gyms.dart';

class AreaSelectorSheet extends StatefulWidget {
  final String currentArea;
  final Function(String) onAreaSelected;

  const AreaSelectorSheet({
    super.key,
    required this.currentArea,
    required this.onAreaSelected,
  });

  static Future<String?> show(BuildContext context, String currentArea) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AreaSelectorSheet(
        currentArea: currentArea,
        onAreaSelected: (area) => Navigator.pop(context, area),
      ),
    );
  }

  @override
  State<AreaSelectorSheet> createState() => _AreaSelectorSheetState();
}

class _AreaSelectorSheetState extends State<AreaSelectorSheet> {
  String _searchQuery = '';

  final Map<String, int> _areaGymCount = {
    'All Areas': MockGyms.gyms.length,
    'Nasr City': MockGyms.gyms.where((g) => g.city == 'Nasr City').length,
    'New Cairo': MockGyms.gyms.where((g) => g.city == 'New Cairo').length,
    'Maadi': MockGyms.gyms.where((g) => g.city == 'Maadi').length,
    'Sheikh Zayed': MockGyms.gyms.where((g) => g.city == 'Sheikh Zayed').length,
    '6th of October': MockGyms.gyms.where((g) => g.city == '6th of October').length,
    'Heliopolis': MockGyms.gyms.where((g) => g.city == 'Heliopolis').length,
    'Zamalek': MockGyms.gyms.where((g) => g.city == 'Zamalek').length,
    'Dokki': MockGyms.gyms.where((g) => g.city == 'Dokki').length,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredAreas = MockGyms.popularAreas.where((area) {
      if (_searchQuery.isEmpty) return true;
      return area.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
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
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Select Your Training Area',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search city or area...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Area list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filteredAreas.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.borderDark.withOpacity(0.5) : AppColors.border.withOpacity(0.5),
              ),
              itemBuilder: (context, index) {
                final area = filteredAreas[index];
                final isSelected = widget.currentArea == area;
                final count = _areaGymCount[area] ?? 0;

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => widget.onAreaSelected(area),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            area == 'All Areas' ? Icons.public_rounded : Icons.location_city_rounded,
                            size: 18,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                area,
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : null,
                                ),
                              ),
                              Text(
                                '$count available gyms',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
