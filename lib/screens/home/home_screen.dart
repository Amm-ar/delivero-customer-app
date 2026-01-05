import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/restaurant_card.dart';
import '../restaurant/restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const OrdersTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: AppLocalizations.of(context)!.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}

// Home Tab
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.nileBlue,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Delivero',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.appTagline,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              Provider.of<RestaurantProvider>(context, listen: false).setSearch(value);
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchHint,
                              prefixIcon: Icon(Icons.search, color: AppColors.gray),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  Text(AppLocalizations.of(context)!.categories, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: AppConstants.cuisineTypes.map((cuisine) {
                        return Consumer<RestaurantProvider>(
                          builder: (context, provider, _) {
                            final isSelected = provider.selectedCuisine == cuisine;
                            return GestureDetector(
                              onTap: () {
                                provider.setCuisine(isSelected ? null : cuisine);
                              },
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.nileBlue : AppColors.desertSand,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant, 
                                      color: isSelected ? Colors.white : AppColors.nileBlue, 
                                      size: 32
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cuisine,
                                      style: AppTextStyles.caption.copyWith(
                                        color: isSelected ? Colors.white : AppColors.nileBlue,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Popular Restaurants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.popularRestaurants, style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () {},
                        child: Text(AppLocalizations.of(context)!.seeAll),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Restaurant List
                  Consumer<RestaurantProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.restaurants.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (provider.errorMessage != null && provider.restaurants.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Text(provider.errorMessage!),
                              ElevatedButton(
                                onPressed: () => provider.fetchRestaurants(refresh: true),
                                child: Text(AppLocalizations.of(context)!.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.restaurants.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Icon(Icons.restaurant_menu, size: 48, color: AppColors.gray),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.noRestaurantsFound,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.restaurants.length + (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.restaurants.length) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          final restaurant = provider.restaurants[index];
                          return RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Orders Tab
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orders),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.gray),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.noOrders,
              style: AppTextStyles.h3.copyWith(color: AppColors.gray),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start ordering from your favorite restaurants',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: auth.user?.avatar != null ? NetworkImage(auth.user!.avatar!) : null,
                    child: auth.user?.avatar == null ? const Icon(Icons.person, size: 40, color: AppColors.nileBlue) : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.name ?? 'User Name',
                          style: AppTextStyles.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user?.email ?? 'user@example.com',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Menu items
            _buildMenuItem(context, Icons.language, AppLocalizations.of(context)!.language, () {
               final provider = Provider.of<LocaleProvider>(context, listen: false);
               showDialog(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: Text(AppLocalizations.of(context)!.language),
                   content: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       ListTile(
                         title: const Text('English'),
                         onTap: () {
                           provider.setLocale(const Locale('en'));
                           Navigator.pop(context);
                         },
                         trailing: provider.locale.languageCode == 'en' ? const Icon(Icons.check, color: AppColors.nileBlue) : null,
                       ),
                       ListTile(
                         title: const Text('العربية'),
                         onTap: () {
                           provider.setLocale(const Locale('ar'));
                           Navigator.pop(context);
                         },
                         trailing: provider.locale.languageCode == 'ar' ? const Icon(Icons.check, color: AppColors.nileBlue) : null,
                       ),
                     ],
                   ),
                 ),
               );
            }),
            _buildMenuItem(context, Icons.location_on_outlined, AppLocalizations.of(context)!.addresses, () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)));
            }),
            _buildMenuItem(context, Icons.payment_outlined, AppLocalizations.of(context)!.paymentMethods, () {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)));
            }),
            _buildMenuItem(context, Icons.notifications_outlined, AppLocalizations.of(context)!.notifications, () {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)));
            }),
            _buildMenuItem(context, Icons.help_outline, AppLocalizations.of(context)!.helpSupport, () {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)));
            }),
            _buildMenuItem(context, Icons.info_outline, AppLocalizations.of(context)!.about, () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivero Sudan v1.0.0')));
            }),
            _buildMenuItem(context, Icons.logout, AppLocalizations.of(context)!.logout, () {
              auth.logout();
            }, color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.nileBlue),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.gray),
      onTap: onTap,
    );
  }
}
