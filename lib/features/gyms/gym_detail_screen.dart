import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'widgets/weekly_schedule_sheet.dart';

class GymDetailScreen extends ConsumerStatefulWidget {
  final String gymId;
  const GymDetailScreen({super.key, required this.gymId});

  @override
  ConsumerState<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends ConsumerState<GymDetailScreen> {
  int _currentImageIndex = 0;
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(gymByIdProvider(widget.gymId));
    if (gym == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Gym not found')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photos = gym.photos.isNotEmpty ? gym.photos : [gym.imageUrl, gym.coverUrl];
    final selectedPlan = gym.plans.firstWhere(
      (p) => p.id == (_selectedPlanId ?? (gym.plans.isNotEmpty ? gym.plans.first.id : '')),
      orElse: () => gym.plans.isNotEmpty
          ? gym.plans.first
          : MembershipPlanModel(
              id: 'plan_default',
              name: 'Standard Monthly',
              duration: '1 Month',
              price: gym.startingPrice,
              features: const ['Gym Floor Access', 'Locker & Showers'],
            ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO GALLERY SLIVER ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    gym.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: gym.isFavorite ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => ref.read(gymsProvider.notifier).toggleFavorite(gym.id),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing ${gym.name} link')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _currentImageIndex = i),
                    itemBuilder: (context, i) {
                      return AppNetworkImage(
                        url: photos[i],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  // Gradient shadow
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Image count badge (e.g. 1/4)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_rounded, size: 13, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text(
                            '${_currentImageIndex + 1}/${photos.length}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── GYM DETAILS SECTIONS ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gym Name, Type & Gender
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  gym.name,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 20, color: AppColors.primary),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${gym.gymType} · ${gym.gender}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Rating, Reviews & Distance row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              gym.rating.toStringAsFixed(1),
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${gym.reviewCount} reviews',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      Icon(Icons.near_me_rounded, size: 15, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${gym.distance} km away',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── LIVE OPENING HOURS CARD ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: gym.isOpen
                                ? const Color(0xFF00E676).withOpacity(0.15)
                                : const Color(0xFFFF5252).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time_filled_rounded,
                            color: gym.isOpen ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gym.isOpen
                                    ? (gym.is24Hours ? 'Open 24 Hours' : 'Open Now · Closes ${gym.closingHours}')
                                    : 'Closed · Opens ${gym.openingHours}',
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: gym.isOpen ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mon – Sun schedule available',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => WeeklyScheduleSheet.show(context, gym),
                          child: Text(
                            'Schedule',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── MEMBERSHIP PRICING PLANS ─────────────────────────────────
                  _buildSectionTitle('Membership Plans & Pricing'),
                  Text(
                    'Transparent subscription pricing with no hidden registration fees.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  if (gym.plans.isNotEmpty)
                    ...gym.plans.map((plan) {
                      final isSelected = plan.id == selectedPlan.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(isDark ? 0.12 : 0.05)
                              : (isDark ? AppColors.surfaceDark : Colors.white),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.borderDark : AppColors.border),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() => _selectedPlanId = plan.id),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          plan.name,
                                          style: AppTextStyles.titleMedium.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (plan.badge != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          plan.badge!,
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      'EGP ${plan.price.toStringAsFixed(0)}',
                                      style: AppTextStyles.headlineSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ' / ${plan.duration}',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                    ),
                                    if (plan.originalPrice != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'EGP ${plan.originalPrice!.toStringAsFixed(0)}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (plan.features.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
                                  const SizedBox(height: 10),
                                  ...plan.features.map((feat) => Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded,
                                                size: 15, color: Color(0xFF00E676)),
                                            const SizedBox(width: 8),
                                            Text(
                                              feat,
                                              style: AppTextStyles.bodySmall.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // ── SERVICES SECTION ─────────────────────────────────────────
                  _buildSectionTitle('Services & Coaching'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gym.services.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_gymnastics_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              service,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── FACILITIES SECTION ───────────────────────────────────────
                  _buildSectionTitle('Available Facilities & Equipment'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gym.facilities.map((facility) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded, size: 16, color: Color(0xFF00E676)),
                            const SizedBox(width: 6),
                            Text(
                              facility,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── ABOUT / DESCRIPTION SECTION ──────────────────────────────
                  _buildSectionTitle('About the Gym'),
                  const SizedBox(height: 8),
                  Text(
                    gym.about,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── LOCATION & DIRECTIONS CARD ───────────────────────────────
                  _buildSectionTitle('Location & Area'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gym.area,
                                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    gym.address,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.directions_rounded, size: 18),
                            label: const Text('Get Directions (0.8 km)'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Opening maps to ${gym.address}')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── CONTACT INFORMATION ──────────────────────────────────────
                  _buildSectionTitle('Contact Gym Management'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone_rounded, size: 18, color: AppColors.primary),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${gym.phone}...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 18, color: Color(0xFF00E676)),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00E676),
                            side: const BorderSide(color: Color(0xFF00E676)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Connecting to ${gym.name} via WhatsApp')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── STICKY BOTTOM ACTION BAR ─────────────────────────────────────────────
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Plan',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'EGP ${selectedPlan.price.toStringAsFixed(0)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        ' / ${selectedPlan.duration}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inquiring membership for ${selectedPlan.name} at ${gym.name}!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Join / Inquire',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }
}
