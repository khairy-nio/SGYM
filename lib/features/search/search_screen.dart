import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  
  final List<String> _recentSearches = ['Protein powder', 'Gold\'s Gym', 'Dumbbells', 'Yoga mat'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<GymModel> allGyms = ref.watch(gymsProvider);
    final List<ProductModel> allProducts = ref.watch(productsProvider);
    
    final gymResults = _query.isEmpty ? <GymModel>[] : allGyms.where((g) => 
        (g.name).toLowerCase().contains(_query.toLowerCase()) || 
        (g.city).toLowerCase().contains(_query.toLowerCase())).toList();
        
    final productResults = _query.isEmpty ? <ProductModel>[] : allProducts.where((p) => 
        (p.name).toLowerCase().contains(_query.toLowerCase()) || 
        (p.category).toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search gyms, products, categories...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildRecentSearches()
          : _buildSearchResults(gymResults, productResults),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: AppTextStyles.titleMedium),
              Text('Clear All', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: _recentSearches.map((search) => GestureDetector(
              onTap: () {
                _searchController.text = search;
                setState(() => _query = search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Text(search, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Text('Suggested Categories', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          _CategoryChip(icon: '🏋️', label: 'Gyms', onTap: () => context.go('/explore')),
          _CategoryChip(icon: '💊', label: 'Supplements', onTap: () {}),
          _CategoryChip(icon: '👕', label: 'Clothing', onTap: () {}),
          _CategoryChip(icon: '🥊', label: 'Accessories', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<GymModel> gyms, List<ProductModel> products) {
    if (gyms.isEmpty && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('No results found for "$_query"', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text('Try checking for typos or using broader terms', 
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (gyms.isNotEmpty) ...[
          Text('Gyms (${gyms.length})', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...gyms.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SearchResultItem(
              imageUrl: g.imageUrl,
              title: g.name,
              subtitle: '${g.city} • ${g.distance}km away',
              onTap: () => context.push('/gym/${g.id}'),
            ),
          )),
          const SizedBox(height: 16),
        ],
        
        if (products.isNotEmpty) ...[
          Text('Products (${products.length})', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...products.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SearchResultItem(
              imageUrl: p.imageUrl,
              title: p.name,
              subtitle: '${p.gymName} • EGP ${p.finalPrice.toStringAsFixed(0)}',
              onTap: () => context.push('/product/${p.id}'),
            ),
          )),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(url: imageUrl, width: 56, height: 56),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
