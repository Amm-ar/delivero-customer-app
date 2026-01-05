import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/restaurant_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/cart_item_model.dart';
import '../../services/restaurant_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/menu_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    
    final result = await _restaurantService.getMenu(
      widget.restaurant.id,
      category: _selectedCategory,
    );

    if (result['success']) {
      setState(() {
        _menuItems = result['menuItems'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<String> get _categories {
    final categories = _menuItems.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with cover image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: ApiConstants.getImageUrl(widget.restaurant.coverImage),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.desertSand,
                      child: Icon(Icons.restaurant, size: 80, color: AppColors.gray),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: AppColors.sunsetAmber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.restaurant.rating} (${widget.restaurant.totalReviews})',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              widget.restaurant.cuisineText,
                              style: TextStyle(color: Colors.white70),
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

          // Restaurant info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoChip(Icons.access_time, widget.restaurant.deliveryTimeText),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(Icons.attach_money, widget.restaurant.priceRange),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(
                        Icons.delivery_dining,
                        widget.restaurant.hasFreeDelivery 
                            ? 'Free' 
                            : '${AppConstants.currencySymbol} ${widget.restaurant.deliveryFee}',
                      ),
                    ],
                  ),
                  
                  if (widget.restaurant.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(widget.restaurant.description, style: AppTextStyles.bodyMedium),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  Divider(color: AppColors.lightGray),
                  
                  // Categories
                  if (_categories.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip('All', null),
                          ..._categories.map((cat) => _buildCategoryChip(cat, cat)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Menu items
          if (_isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.nileBlue)),
            )
          else if (_menuItems.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No menu items available', style: AppTextStyles.bodyMedium),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _menuItems[index];
                    return MenuItemCard(
                      menuItem: item,
                      restaurant: widget.restaurant,
                      onAddToCart: () => _addToCart(item),
                    );
                  },
                  childCount: _menuItems.length,
                ),
              ),
            ),
        ],
      ),
      
      // Cart floating button
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) return const SizedBox();
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            backgroundColor: AppColors.nileBlue,
            icon: const Icon(Icons.shopping_cart),
            label: Text('${cart.itemCount} items • ${AppConstants.currencySymbol} ${cart.total.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.desertSand,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.nileBlue),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
            _loadMenu();
          });
        },
        backgroundColor: AppColors.desertSand,
        selectedColor: AppColors.nileBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _addToCart(MenuItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Simple add to cart (in production, show customization dialog if item has customizations)
    final cartItem = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      menuItemId: item.id!,
      name: item.name,
      price: item.price,
      quantity: 1,
    );

    cartProvider.addItem(widget.restaurant.id, widget.restaurant, cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.palmGreen,
      ),
    );
  }
}
