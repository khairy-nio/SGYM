import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';

class WeeklyScheduleSheet extends StatelessWidget {
  final GymModel gym;

  const WeeklyScheduleSheet({super.key, required this.gym});

  static void show(BuildContext context, GymModel gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => WeeklyScheduleSheet(gym: gym),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final currentWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    final todayName = days[currentWeekday - 1];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Operating Schedule',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    gym.name,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
          const SizedBox(height: 12),
          ...days.map((day) {
            final isToday = day == todayName;
            final hours = gym.weeklySchedule[day] ?? '${gym.openingHours} – ${gym.closingHours}';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withOpacity(isDark ? 0.15 : 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    day,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday ? AppColors.primary : null,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TODAY',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    hours,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday
                          ? (gym.isOpen ? const Color(0xFF00E676) : AppColors.primary)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
