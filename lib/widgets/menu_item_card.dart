import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/menu_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../models/cart_item_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final Restaurant restaurant;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.restaurant,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          // Show details dialog or navigate to detail screen
          _showItemDialog(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: CachedNetworkImage(
                  imageUrl: '${ApiConstants.baseUrl}/uploads/${menuItem.image}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.desertSand,
                    child: Icon(Icons.fastfood, color: AppColors.gray),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.desertSand,
                    child: Icon(Icons.fastfood, color: AppColors.gray),
                  ),
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(menuItem.name, style: AppTextStyles.h4),
                    
                    if (menuItem.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        menuItem.description,
                        style: AppTextStyles.caption.copyWith(color: AppColors.gray),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Tags
                    if (menuItem.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: menuItem.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.palmGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.palmGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Price and button
                    Row(
                      children: [
                        if (menuItem.hasDiscount) ...[
                          Text(
                            '${AppConstants.currencySymbol} ${menuItem.price.toStringAsFixed(2)}',
                            style: AppTextStyles.caption.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.gray,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${AppConstants.currencySymbol} ${menuItem.price.toStringAsFixed(2)}',
                          style: AppTextStyles.h4.copyWith(color: AppColors.nileBlue),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: menuItem.isAvailable ? onAddToCart : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(menuItem.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (menuItem.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: '${ApiConstants.baseUrl}/uploads/${menuItem.image}',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              
              const SizedBox(height: AppSpacing.md),
              
              Text(menuItem.description),
              
              const SizedBox(height: AppSpacing.md),
              
              if (menuItem.tags.isNotEmpty) ...[
                Text('Tags:', style: AppTextStyles.h4),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: menuItem.tags.map((tag) => Chip(
                    label: Text(tag, style: TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.desertSand,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAddToCart();
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
