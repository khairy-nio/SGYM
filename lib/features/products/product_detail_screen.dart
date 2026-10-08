import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../shared/widgets/shared_widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));
    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final inCart = ref.watch(cartProvider.notifier).isInCart(product.id);
    final reviews = MockData.reviews.where((r) => r.productId == product.id).toList();
    final relatedProducts = ref.watch(productsProvider)
        .where((p) => p.category == product.category && p.id != product.id)
        .take(4)
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image gallery
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                  child: Icon(
                    product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: product.isFavorite ? AppColors.error : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => ref.read(productsProvider.notifier).toggleFavorite(product.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    onPageChanged: (i) => setState(() => _selectedImageIndex = i),
                    itemCount: product.images.isNotEmpty ? product.images.length : 1,
                    itemBuilder: (_, i) => AppNetworkImage(
                      url: product.images.isNotEmpty ? product.images[i] : product.imageUrl,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        product.images.isNotEmpty ? product.images.length : 1,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _selectedImageIndex == i ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _selectedImageIndex == i ? AppColors.primary : Colors.white60,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(product.category,
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                                ),
                                const SizedBox(height: 10),
                                Text(product.name, style: AppTextStyles.headlineLarge),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => context.push('/gym/${product.gymId}'),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.store_outlined, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(product.gymName,
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FavoriteButton(
                            isFavorite: product.isFavorite,
                            size: 40,
                            onTap: () => ref.read(productsProvider.notifier).toggleFavorite(product.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          RatingWidget(rating: product.rating, reviewCount: product.reviewCount),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.stock > 10
                                  ? AppColors.secondaryLight
                                  : AppColors.accentLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.stock > 10 ? 'In Stock' : '${product.stock} left',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: product.stock > 10 ? AppColors.success : AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Price section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                PriceWidget(
                                  price: product.finalPrice,
                                  originalPrice: product.hasDiscount ? product.price : null,
                                  fontSize: 24,
                                ),
                              ],
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 12),
                              DiscountBadge(percent: product.discountPercent!, fontSize: 13),
                            ],
                            const Spacer(),
                            // Quantity selector
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_quantity > 1) setState(() => _quantity--);
                                    },
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      child: const Icon(Icons.remove_rounded, size: 18),
                                    ),
                                  ),
                                  Text('$_quantity', style: AppTextStyles.titleMedium),
                                  GestureDetector(
                                    onTap: () => setState(() => _quantity++),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      child: const Icon(Icons.add_rounded, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Text('Description', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Product info
                      Text('Product Information', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _InfoTable(rows: [
                        ['SKU', product.sku],
                        ['Category', product.category],
                        ['Sold By', product.gymName],
                        ['Stock', '${product.stock} units'],
                      ]),
                    ],
                  ),
                ),
                // Reviews
                if (reviews.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text('Reviews', style: AppTextStyles.headlineSmall),
                        const SizedBox(width: 8),
                        Text('(${reviews.length})', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reviews.take(3).map((r) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _ReviewCard(review: r),
                  )),
                ],
                // Related products
                if (relatedProducts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Related Products', actionLabel: 'See All',
                      onActionTap: () => context.push('/products')),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemCount: relatedProducts.length,
                      itemBuilder: (_, i) {
                        final p = relatedProducts[i];
                        return GestureDetector(
                          onTap: () => context.pushReplacement('/product/${p.id}'),
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  child: AppNetworkImage(url: p.imageUrl, height: 120, width: 160),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: AppTextStyles.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      PriceWidget(price: p.finalPrice, fontSize: 13),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -4))],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      ref.read(cartProvider.notifier).addItem(product);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$_quantity x ${product.name} added to cart')),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      ref.read(cartProvider.notifier).addItem(product);
                    }
                    context.push('/checkout');
                  },
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  final List<List<String>> rows;
  const _InfoTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(row[0], style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(row[1], style: AppTextStyles.titleSmall),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(review.userAvatar),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTextStyles.titleSmall),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 12,
                        color: AppColors.star,
                      )),
                    ),
                  ],
                ),
              ),
              Text(
                _timeAgo(review.date),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
