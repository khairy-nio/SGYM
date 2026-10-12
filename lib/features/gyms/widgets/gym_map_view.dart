import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import 'gym_preview_card.dart';

class GymMapView extends StatefulWidget {
  final List<GymModel> gyms;
  final String currentArea;
  final Function(GymModel)? onGymSelected;

  const GymMapView({
    super.key,
    required this.gyms,
    required this.currentArea,
    this.onGymSelected,
  });

  @override
  State<GymMapView> createState() => _GymMapViewState();
}

class _GymMapViewState extends State<GymMapView> {
  GymModel? _selectedGym;

  @override
  void initState() {
    super.initState();
    if (widget.gyms.isNotEmpty) {
      _selectedGym = widget.gyms.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ── MAP CANVAS SIMULATION ──────────────────────────────────────────────
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF131722) : const Color(0xFFE8EEF5),
            child: Stack(
              children: [
                // Stylized map streets / grid lines
                CustomPaint(
                  size: Size.infinite,
                  painter: _MapGridPainter(isDark: isDark),
                ),

                // Area Header Tag on top of Map
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.currentArea} (${widget.gyms.length} Gyms)',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map Legend / Compass
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.my_location_rounded, size: 18, color: AppColors.primary),
                  ),
                ),

                // Gym Location Pins
                ...List.generate(widget.gyms.length, (index) {
                  final gym = widget.gyms[index];
                  final isSelected = _selectedGym?.id == gym.id;

                  // Distribute markers visually across map canvas
                  final positions = [
                    const Offset(0.25, 0.28),
                    const Offset(0.65, 0.22),
                    const Offset(0.48, 0.45),
                    const Offset(0.18, 0.58),
                    const Offset(0.72, 0.60),
                    const Offset(0.35, 0.75),
                    const Offset(0.80, 0.38),
                    const Offset(0.55, 0.72),
                    const Offset(0.30, 0.40),
                    const Offset(0.60, 0.82),
                  ];

                  final pos = positions[index % positions.length];

                  return Align(
                    alignment: FractionalOffset(pos.dx, pos.dy),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedGym = gym);
                        widget.onGymSelected?.call(gym);
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.15 : 1.0,
                        child: _buildGymMarker(gym, isSelected, isDark),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // ── FLOATING BOTTOM PREVIEW CARD ───────────────────────────────────────
        if (_selectedGym != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: GymPreviewCard(
                  key: ValueKey(_selectedGym!.id),
                  gym: _selectedGym!,
                  onClose: () => setState(() => _selectedGym = null),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGymMarker(GymModel gym, bool isSelected, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceDark : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.4)
                    : Colors.black.withOpacity(0.15),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: 13,
                color: isSelected
                    ? Colors.white
                    : (gym.isOpen ? const Color(0xFF00E676) : AppColors.primary),
              ),
              const SizedBox(width: 4),
              Text(
                gym.name,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.textPrimary),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EGP ${gym.startingPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Pin pointer triangle
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePainter(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceDark : Colors.white),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapGridPainter extends CustomPainter {
  final bool isDark;
  _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E2433).withOpacity(0.6)
          : const Color(0xFFD6E0EC).withOpacity(0.7)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadMinorPaint = Paint()
      ..color = isDark
          ? const Color(0xFF181D29).withOpacity(0.8)
          : const Color(0xFFDEE7F2).withOpacity(0.8)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Major ring road
    final path1 = Path()
      ..moveTo(0, size.height * 0.35)
      ..cubicTo(size.width * 0.3, size.height * 0.3, size.width * 0.7, size.height * 0.5, size.width, size.height * 0.45);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..cubicTo(size.width * 0.5, size.height * 0.4, size.width * 0.35, size.height * 0.7, size.width * 0.6, size.height);
    canvas.drawPath(path2, roadPaint);

    // Minor streets
    for (double y = 80; y < size.height; y += 110) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 40), roadMinorPaint);
    }
    for (double x = 70; x < size.width; x += 120) {
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), roadMinorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
