import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class ProductionConfig {
  static void enforceProductionSettings() {
    // Disable debug banner
    WidgetsApp.debugAllowBannerOverride = false;
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static bool get isProductionMode {
    return const bool.fromEnvironment('dart.vm.product', defaultValue: false);
  }

  static String get environmentName {
    if (isProductionMode) return 'Production';
    if (const bool.hasEnvironment('FLUTTER_TEST')) return 'Test';
    return 'Development';
  }

  static void showEnvironmentBanner(BuildContext context) {
    if (!isProductionMode) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            '${environmentName} Mode',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isProductionMode 
              ? Colors.green 
              : Colors.orange,
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text(
                'DISMISS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  static void initializeErrorHandling() {
    // Set global error handling for production
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!isProductionMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        // In production, you might want to send errors to a logging service
        // For example: Crashlytics, Sentry, etc.
        print('Production Error: ${details.exception}');
      }
    };

    // Handle uncaught async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!isProductionMode) {
        print('Async Error: $error');
        print('Stack: $stack');
      } else {
        // Send to error reporting service
        print('Production Async Error: $error');
      }
      return true;
    };
  }

  static void validateConfiguration(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is authenticated for protected routes
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginRequired ?? 'Please login to continue'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              // Navigate to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      );
    }
  }

  static void initializeApp() {
    enforceProductionSettings();
    initializeErrorHandling();
  }
}
