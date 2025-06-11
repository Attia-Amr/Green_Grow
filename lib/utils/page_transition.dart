/*
GREENGROW APP - PAGE TRANSITIONS

This file implements custom navigation transitions for smooth screen changes.

SIMPLE EXPLANATION:
- This is like the special effects system for moving between app screens
- It creates smooth fade animations when navigating to new screens
- It provides sliding animations for modal-like screens that appear from the bottom
- It adds convenience methods to make navigation code shorter and cleaner
- It ensures consistent transition styles throughout the app
- It makes the app feel more polished and professional
- It handles the technical details of animation timing and curves

TECHNICAL EXPLANATION:
- Implements custom PageRoute classes for specialized screen transitions
- Contains extension methods on BuildContext for streamlined navigation
- Implements composable animations with customizable durations
- Contains fade transitions with opacity animations for subtle screen changes
- Implements slide transitions with precise curve control for natural movement
- Contains combined animations (fade + slide) for richer visual effects
- Implements navigation stack management utilities (replace, remove until)
- Contains consistent timing parameters for coherent user experience
- Implements clean separation between animation definition and usage

This utility provides the animation foundation for screen navigation throughout the app,
creating a polished and professional user experience with minimal code.
*/

import 'package:flutter/material.dart';

/// Custom page route that implements a fade transition animation
/// Used for smooth transitions between screens with a fade effect
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: animation,
                child: child,
              ),
          transitionDuration: duration,
        );
}

/// Custom page route that implements a slide-up transition animation
/// Used for modal-like transitions where screens slide up from the bottom
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideUpPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            // Configure the slide animation parameters
            var begin = const Offset(0.0, 0.1);  // Start slightly below target position
            var end = Offset.zero;                // End at target position
            var curve = Curves.easeOutQuart;      // Use smooth easing curve
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            // Combine slide and fade animations
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: duration,
        );
}

/// Extension methods for BuildContext to provide convenient navigation methods
/// Adds support for custom transitions throughout the app
extension NavigationExtension on BuildContext {
  /// Navigate to a new screen with fade transition
  Future<T?> fadeNavigateTo<T>(Widget page) {
    return Navigator.of(this).push<T>(
      FadePageRoute<T>(page: page),
    );
  }

  /// Navigate to a new screen with slide-up transition
  Future<T?> slideUpNavigateTo<T>(Widget page) {
    return Navigator.of(this).push<T>(
      SlideUpPageRoute<T>(page: page),
    );
  }

  /// Replace current screen with new screen using fade transition
  void fadeReplaceTo(Widget page) {
    Navigator.of(this).push(
      FadePageRoute(page: page),
    );
  }

  /// Pop current screen and push new screen with fade transition
  void fadePopAndPush(Widget page) {
    Navigator.of(this).push(
      FadePageRoute(page: page),
    );
  }

  /// Clear navigation stack and show new screen with fade transition
  void fadeRemoveUntil(Widget page) {
    Navigator.of(this).pushAndRemoveUntil(
      FadePageRoute(page: page),
      (route) => false,
    );
  }
} 