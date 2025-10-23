import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_state.dart';

const kHideWidgetAnimationDuration = Duration(milliseconds: 200);

class VisibilityAnimation extends StatefulWidget {
  final Widget child;
  final String? animationId;
  final Duration duration;
  final Curve curve;

  const VisibilityAnimation({
    super.key,
    required this.child,
    this.animationId,
    this.duration = kHideWidgetAnimationDuration,
    this.curve = Curves.easeInOut,
  });

  @override
  State<VisibilityAnimation> createState() => _VisibilityAnimationState();
}

class _VisibilityAnimationState extends State<VisibilityAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: widget.duration);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.curve));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.curve));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation(bool shouldHide) {
    if (shouldHide) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) {
        final previousHidden = previous.isHidden(widget.animationId);
        final currentHidden = current.isHidden(widget.animationId);
        return previousHidden != currentHidden;
      },
      listener: (context, state) {
        _updateAnimation(state.isHidden(widget.animationId));
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
              child: Transform.scale(scale: _scaleAnimation.value, child: child),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
