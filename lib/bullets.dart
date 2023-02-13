import 'dart:async' as async;
import 'dart:math';

import 'package:bullet_hell/main.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

mixin BulletsMixin on PositionComponent {
  moveAlongLine(Vector2 source, Vector2 target, double speed) {
    var v = target.y - source.y;
    var h = target.x - source.x;
    var distance = sqrt(pow(v, 2) + pow(h, 2));
    position.add(Vector2(h / distance, v / distance) * speed);
  }

  async.Timer moveAround(
      Vector2 target, double radius, double angularSpeed, int milliseconds) {
    int i = 0;
    var initialAngle = angleTo(target);
    return async.Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      i++;
      position = target +
          Vector2(cos(initialAngle + i * angularSpeed),
                  sin(initialAngle + i * angularSpeed)) *
              radius;
    });
  }

  moveWithAngle(num radians, double speed) {
    position.add(Vector2(cos(radians), sin(radians)) * speed);
  }

  bool offScreen(FlameGame game) {
    var position = game.camera.position;

    return absolutePosition.x < position.x ||
        absolutePosition.x > position.x + viewPortSize.x ||
        absolutePosition.y < 0 ||
        absolutePosition.y > viewPortSize.y;
  }
}
