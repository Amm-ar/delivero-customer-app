import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart' as user_models;
import '../../l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cash';
  user_models.Address? _selectedAddress;
  final _addressController = TextEditingController();
  final _labelController = TextEditingController(text: 'Home');

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.addresses.isNotEmpty) {
      _selectedAddress = user.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => user.addresses.first,
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (_selectedAddress == null && _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a delivery address')),
      );
      return;
    }

    // Show loading while getting location
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Getting precise location...'), duration: Duration(seconds: 1)),
      );
    }

    // Try to get precise location
    user_models.Location? preciseLocation;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        preciseLocation = user_models.Location(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        // Request permission if not granted
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.always || requestedPermission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
          preciseLocation = user_models.Location(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }

    final Map<String, dynamic> deliveryAddress = _selectedAddress != null
        ? _selectedAddress!.toJson()
        : {
            'label': _labelController.text,
            'address': _addressController.text,
            'location': {
              'type': 'Point',
              'coordinates': [32.5332, 15.5007], // Default to Khartoum center fallback
            }
          };

    // Override with precise location if available
    if (preciseLocation != null) {
      deliveryAddress['location'] = preciseLocation.toJson();
    }

    final result = await orderProvider.createOrder(
      restaurantId: cart.currentRestaurant!.id,
      items: cart.getOrderItems(cart.currentRestaurant!.id),
      deliveryAddress: deliveryAddress,
      paymentMethod: _paymentMethod,
    );

    if (result['success']) {
      cart.clearCart();
      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to place order')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.palmGreen, size: 60),
            const SizedBox(height: 16),
            const Text('Your order has been placed successfully. You can track it in the Orders tab.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cart, auth, child) {
          final items = cart.getRestaurantItems(cart.currentRestaurant?.id ?? '');
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Order Summary Selection
              _buildSectionTitle('Order Summary'),
              _buildOrderSummary(cart),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Address Selection
              _buildSectionTitle('Delivery Address'),
              _buildAddressSection(auth.user),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Payment Method Selection
              _buildSectionTitle('Payment Method'),
              _buildPaymentSection(),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Bill Summary
              _buildBillDetails(cart),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Place Order Button
              ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: context.watch<OrderProvider>().isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Place Order • ${AppConstants.currencySymbol} ${cart.total.toStringAsFixed(2)}'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: AppTextStyles.h4),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    final items = cart.getRestaurantItems(cart.currentRestaurant?.id ?? '');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.quantity}x ${item.name}', style: AppTextStyles.bodyMedium),
              Text('${AppConstants.currencySymbol} ${(item.price * item.quantity).toStringAsFixed(2)}'),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAddressSection(user_models.User? user) {
    if (user != null && user.addresses.isNotEmpty) {
      return Column(
        children: [
          ...user.addresses.map((addr) => RadioListTile<user_models.Address>(
            value: addr,
            groupValue: _selectedAddress,
            onChanged: (value) => setState(() => _selectedAddress = value),
            title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(addr.address),
            contentPadding: EdgeInsets.zero,
          )).toList(),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement Add Address Screen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Address feature coming soon!')));
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Address Label (e.g., Home, Work)',
              hintText: 'Home',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Delivery Address',
              hintText: 'Enter your full address',
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
    value: 'cash',
    groupValue: _paymentMethod,
    onChanged: (value) => setState(() => _paymentMethod = value!),
    title: const Text('Cash on Delivery'),
            secondary: const Icon(Icons.money, color: AppColors.palmGreen),
          ),
          RadioListTile<String>(
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value!),
            title: const Text('Credit/Debit Card'),
            subtitle: const Text('Pay securely with your card'),
            secondary: const Icon(Icons.credit_card, color: AppColors.nileBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(CartProvider cart) {
    return Column(
      children: [
        _buildBillRow('Subtotal', cart.subtotal),
        _buildBillRow('Delivery Fee', cart.deliveryFee),
        _buildBillRow('Service Fee', cart.serviceFee),
        const Divider(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: AppTextStyles.h3),
            Text(
              '${AppConstants.currencySymbol} ${cart.total.toStringAsFixed(2)}',
              style: AppTextStyles.h3.copyWith(color: AppColors.nileBlue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray)),
          Text('${AppConstants.currencySymbol} ${amount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
