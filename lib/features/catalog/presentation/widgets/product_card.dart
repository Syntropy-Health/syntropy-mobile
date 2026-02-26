import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  Color _getCategoryColor() {
    switch (product.category) {
      case ProductCategory.supplements:
        return AppColors.supplements;
      case ProductCategory.foods:
        return AppColors.nutrition;
      case ProductCategory.equipment:
        return AppColors.exercise;
      case ProductCategory.books:
        return AppColors.mental;
      case ProductCategory.other:
        return AppColors.secondary;
    }
  }

  IconData _getCategoryIcon() {
    switch (product.category) {
      case ProductCategory.supplements:
        return Icons.medication;
      case ProductCategory.foods:
        return Icons.restaurant;
      case ProductCategory.equipment:
        return Icons.fitness_center;
      case ProductCategory.books:
        return Icons.menu_book;
      case ProductCategory.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            AspectRatio(
              aspectRatio: 1.2,
              child: Container(
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                ),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(categoryColor);
                        },
                      )
                    : _buildPlaceholder(categoryColor),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: categoryColor,
                              fontSize: 9,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Rating
                    if (product.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (product.reviewCount != null) ...[
                            Text(
                              ' (${product.reviewCount})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ],
                      ),

                    const SizedBox(height: 4),

                    // Price and Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: onAddToCart,
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
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Center(
      child: Icon(
        _getCategoryIcon(),
        size: 48,
        color: color.withOpacity(0.5),
      ),
    );
  }
}
