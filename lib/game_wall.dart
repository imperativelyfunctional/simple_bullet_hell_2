import 'package:bullet_hell/bullet.dart';
import 'package:flame/components.dart';

class GameWall extends ScreenHitbox {
  bool autoRemove = true;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (autoRemove && other is Bullet) {
      other.removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
