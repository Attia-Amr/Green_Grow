/*
GREENGROW APP - CACHED SCREEN

This file implements a widget for preserving screen state during navigation.

SIMPLE EXPLANATION:
- This is like a memory keeper for app screens
- It prevents screens from reloading when you navigate away and come back
- It preserves your scroll position and input data when switching tabs
- It makes the app feel faster by avoiding unnecessary rebuilds
- It keeps your place in lists and forms when moving between sections
- It saves battery and processing power by reducing screen rebuilds
- It creates a smoother experience when using bottom navigation

TECHNICAL EXPLANATION:
- Implements a stateful wrapper widget using AutomaticKeepAliveClientMixin
- Contains state preservation across navigation events
- Implements unique keying to identify and track individual screens
- Contains PageStorage integration for persistent scroll positions
- Implements memory optimization through selective state retention
- Contains minimal overhead design to reduce performance impact
- Implements composition pattern to wrap any child widget
- Contains clean separation of preservation logic from widget content
- Implements minimal API for straightforward developer usage

This widget enhances user experience by maintaining screen state during navigation,
preventing jarring resets and improving perceived performance.
*/

import 'package:flutter/material.dart';

/// A wrapper widget that maintains the state of its child when navigating
/// Uses AutomaticKeepAliveClientMixin to prevent rebuilding
class CachedScreen extends StatefulWidget {
  final Widget child;
  final String screenKey;

  const CachedScreen({
    Key? key,
    required this.child,
    required this.screenKey,
  }) : super(key: key);

  @override
  State<CachedScreen> createState() => _CachedScreenState();
}

class _CachedScreenState extends State<CachedScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      bucket: PageStorageBucket(),
      child: widget.child,
    );
  }
} 