import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'default';

  final List<String> _cats = ['All', 'Protein', 'Supplements', 'Accessories', 'Equipment', 'Clothing'];

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<ProductModel> filtered = _selectedCategory == 'All'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    if (_sortBy == 'price_asc') filtered.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
    else if (_sortBy == 'price_desc') filtered.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
    else if (_sortBy == 'rating') filtered.sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final cat = _cats[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
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
                      cat,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Text('${filtered.length} products', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                if (_sortBy != 'default')
                  GestureDetector(
                    onTap: () => setState(() => _sortBy = 'default'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Clear Sort', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Products',
                    message: 'No products in this category',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _ProductGridCard(product: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort By', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            ...[
              ('Default', 'default'),
              ('Price: Low to High', 'price_asc'),
              ('Price: High to Low', 'price_desc'),
              ('Top Rated', 'rating'),
            ].map((opt) => ListTile(
              title: Text(opt.$1),
              leading: Radio<String>(
                value: opt.$2,
                groupValue: _sortBy,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  setState(() => _sortBy = v!);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                setState(() => _sortBy = opt.$2);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── PRODUCT GRID CARD ──────────────────────────────────────────────────────

class _ProductGridCard extends ConsumerWidget {
  final ProductModel product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCart = ref.watch(cartProvider.notifier).isInCart(product.id);

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AppNetworkImage(url: product.imageUrl, height: 140, width: double.infinity),
                ),
                if (product.hasDiscount)
                  Positioned(top: 8, left: 8, child: DiscountBadge(percent: product.discountPercent!)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    isFavorite: product.isFavorite,
                    size: 32,
                    onTap: () => ref.read(productsProvider.notifier).toggleFavorite(product.id),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTextStyles.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(product.gymName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    PriceWidget(price: product.finalPrice, originalPrice: product.hasDiscount ? product.price : null, fontSize: 14),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} added'), duration: const Duration(seconds: 1)),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 32,
                        decoration: BoxDecoration(
                          color: inCart ? AppColors.secondary : AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(inCart ? '✓ In Cart' : '+ Add', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                        ),
                      ),
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
