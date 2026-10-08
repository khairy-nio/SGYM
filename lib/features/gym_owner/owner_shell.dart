import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class OwnerShell extends ConsumerStatefulWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  @override
  ConsumerState<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends ConsumerState<OwnerShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/owner/dashboard'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Products', path: '/owner/products'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders', path: '/owner/orders'),
    _NavItem(icon: Icons.local_offer_rounded, label: 'Offers', path: '/owner/offers'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/owner/profile'),
  ];

  void _onTabTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_items[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isSelected = _selectedIndex == i;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.secondaryLight : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected ? AppColors.secondary : AppColors.textTertiary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected ? AppColors.secondary : AppColors.textTertiary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
