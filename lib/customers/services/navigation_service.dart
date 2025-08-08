import 'package:flutter/material.dart';

/// Centralized navigation service for instant transitions throughout the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a page with instant transition (no animation)
  static Future<T?> pushInstant<T>(Widget page) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      return navigator.push<T>(_instantRoute<T>(page));
    }
    throw Exception('Navigator not found');
  }

  /// Replace current page with instant transition (no animation)
  static Future<T?> pushReplacementInstant<T>(Widget page) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      return navigator.pushReplacement<T, dynamic>(_instantRoute<T>(page));
    }
    throw Exception('Navigator not found');
  }

  /// Pop current page
  static void pop<T>([T? result]) {
    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }

  /// Create a PageRouteBuilder with zero duration for instant transitions
  static PageRouteBuilder<T> _instantRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}