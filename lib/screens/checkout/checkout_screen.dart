import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 80, color: AppColors.gray),
            const SizedBox(height: 16),
            const Text(
              'Checkout',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Review your order and place it.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
