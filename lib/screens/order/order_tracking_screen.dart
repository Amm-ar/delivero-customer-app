import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: AppColors.gray),
            const SizedBox(height: 16),
            const Text(
              'Order Tracking',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your delivery in real-time.',
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
