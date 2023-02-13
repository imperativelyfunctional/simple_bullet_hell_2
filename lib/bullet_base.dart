import 'dart:async';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'bullets.dart';

class BulletBase extends CircleComponent with BulletsMixin {
  final Color color;
  final bool autoRemove;

  BulletBase(this.color,
      {super.radius,
      super.position,
      this.autoRemove = true,
      super.anchor = Anchor.center}) {
    paint = Paint()..color = color;
  }

  @override
  Future<void> onLoad() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      var glowEffect = GlowEffect(
          60,
          EffectController(
              duration: 3, reverseDuration: 1, infinite: !autoRemove),
          style: BlurStyle.solid);
      add(glowEffect);
      timer.cancel();
    });
    return super.onLoad();
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (autoRemove && type == ChildrenChangeType.removed) {
      removeFromParent();
    }
  }
}
