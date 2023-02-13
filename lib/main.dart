import 'dart:async' as async;
import 'dart:math';

import 'package:bullet_hell/bullet_base.dart';
import 'package:bullet_hell/game_wall.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'bullet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  var bulletHell = BulletHell();
  runApp(GameWidget(game: bulletHell));
}

late Vector2 viewPortSize;

class BulletHell extends FlameGame with HasCollisionDetection {
  late EventHandler eventHandler;
  late GameWall gameWall;
  final List<Color> colors = [
    Colors.amber,
    Colors.tealAccent,
    Colors.green,
    Colors.lightGreenAccent,
    Colors.red,
    Colors.lime,
    Colors.indigo,
    Colors.white70,
    Colors.white10,
  ];

  @override
  Future<void> onLoad() async {
    super.onLoad();
    viewPortSize = size;
    camera.viewport = FixedResolutionViewport(size);

    await addParallaxBackground();
    var boss = await addBoss();
    eventHandler = EventHandler(this, boss);
  }

  Future<SpriteAnimationComponent> addBoss() async {
    var imageSize = Vector2(101, 64);
    final running = await loadSpriteAnimation(
      'boss.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: imageSize,
        stepTime: 0.5,
      ),
    );

    var boss = SpriteAnimationComponent(
        priority: 1,
        animation: running,
        anchor: Anchor.center,
        size: imageSize,
        angle: pi,
        position: Vector2(size.x / 2.0, -10),
        scale: Vector2(0.5, 0.5));
    boss.add(SequenceEffect(
      [
        MoveEffect.to(
            Vector2(size.x / 2.0, 700),
            EffectController(
                duration: 1, infinite: false, curve: Curves.bounceIn)),
        MoveEffect.to(
            Vector2(size.x / 2.0, 500),
            EffectController(
                duration: 1, infinite: false, curve: Curves.easeInExpo))
      ],
    ));
    gameWall = GameWall();
    add(gameWall);
    add(boss);
    hellFour(boss);
    return boss;
  }

  void hellFour(SpriteAnimationComponent boss) {
    gameWall.autoRemove = true;
    async.Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      List<BulletBase> bases = [];
      var numberOfBases = 10;
      var angle = 2 * pi / numberOfBases;
      var radius = 100.0;
      for (int i = 0; i < numberOfBases; i++) {
        var innerBases = BulletBase(Colors.white,
            radius: 20,
            position: boss.position +
                Vector2(cos(i * angle), sin(i * angle)) * radius,
            autoRemove: false)
          ..moveAround(boss.position, 200, pi / 72, 10);
        bases.add(innerBases);
        add(innerBases);
      }
      timer.cancel();
      int counter = 0;
      async.Timer.periodic(const Duration(milliseconds: 100), (timer) {
        counter++;
        if (counter > 100) {
          var lastTimer =
              async.Timer.periodic(const Duration(milliseconds: 50), (timer) {
            for (var base in bases) {
              var position = base.position;
              add(Bullet(boss, pi / 2)
                ..speed = (Random().nextDouble() * 200).clamp(75, 200)
                ..position = position
                ..scale = boss.scale
                ..anchor = Anchor.center);
            }
          });
          boss.add(SequenceEffect([
            MoveToEffect(
                Vector2(size.x / 3, boss.y), SineEffectController(period: 2)),
            MoveToEffect(Vector2(size.x * 2 / 3, boss.y),
                SineEffectController(period: 4)),
          ], onComplete: () {
            for (var element in bases) {
              element.removeFromParent();
            }
            lastTimer.cancel();
            eventHandler.handleEvent("one");
          }));
          timer.cancel();
        }
        for (var base in bases) {
          var position = base.position;
          add(Bullet(boss, pi / 2)
            ..speed = 200
            ..position = position
            ..scale = boss.scale
            ..anchor = Anchor.center);
        }
      });
    });
  }

  void hellThree(SpriteAnimationComponent boss) {
    gameWall.autoRemove = false;
    List<BulletBase> bases = [];
    List<bool> effectStates = [];
    async.Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      var width = size.x;
      double margin = 40;
      var spaceBetween = (width - margin * 2) / 4;
      var numberOfBases = 5;
      for (int i = 0; i < numberOfBases; i++) {
        var moveToEffect = MoveToEffect(Vector2(margin + i * spaceBetween, 30),
            EffectController(duration: 2),
            onComplete: () => {effectStates[i] = true});
        effectStates.add(false);
        List<Effect> effects = [moveToEffect];
        if (i == 0) {
          effects.add(SequenceEffect([
            MoveToEffect(
                Vector2(width - margin, 30), EffectController(duration: 2)),
            MoveToEffect(Vector2(margin, 30), EffectController(duration: 2))
          ], infinite: true));
        } else if (i == 1) {
          effects.add(SequenceEffect([
            MoveToEffect(Vector2(margin + 3 * spaceBetween, 30),
                EffectController(duration: 1)),
            MoveToEffect(Vector2(margin + spaceBetween, 30),
                EffectController(duration: 1)),
          ], infinite: true));
        } else if (i == 3) {
          effects.add(SequenceEffect([
            MoveToEffect(Vector2(margin + spaceBetween, 30),
                EffectController(duration: 1)),
            MoveToEffect(Vector2(margin + 3 * spaceBetween, 30),
                EffectController(duration: 1)),
          ], infinite: true));
        } else if (i == 4) {
          effects.add(SequenceEffect([
            MoveToEffect(Vector2(margin, 30), EffectController(duration: 2)),
            MoveToEffect(
                Vector2(width - margin, 30), EffectController(duration: 2)),
          ], infinite: true));
        }
        var bulletBase = BulletBase(Colors.amber,
            radius: 8, position: boss.position, autoRemove: false)
          ..anchor = Anchor.center
          ..add(SequenceEffect(effects));
        add(bulletBase);
        bases.add(bulletBase);
      }
      var dateTime = DateTime.now();
      async.Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if (effectStates.where((element) => !element).isEmpty) {
          for (var value in bases) {
            var position = value.position;
            add(Bullet(boss, pi / 2)
              ..position = position
              ..scale = boss.scale
              ..anchor = Anchor.center);
          }
        }
        if (DateTime.now().difference(dateTime).inSeconds > 8) {
          for (var element in bases) {
            element.removeFromParent();
          }
          eventHandler.handleEvent("four");
          timer.cancel();
        }
      });
      timer.cancel();
    });
  }

  void hellTwo(SpriteAnimationComponent boss) {
    gameWall.autoRemove = false;
    int step = 0;
    async.Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      step++;
      double radians = 0;
      bool oddStep = step % 2 == 1;
      for (int i = 0; i < 8; i++) {
        radians += 2 * pi / 8;
        var other = 37;
        var i = 0;
        i = (i + 1) % other;
        var bullets = <Bullet>[];
        for (int i = 0; i < other; i++) {
          var radius = (oddStep ? 100 : 200);
          var position = Vector2(boss.position.x + cos(radians) * radius,
              boss.position.y + sin(radians) * radius);
          add(BulletBase(colors[step], radius: 10, position: position));
          var bullet = Bullet(boss, (pi / other - pi) * i,
              speed: 100, randomizeStepTime: true)
            ..position = position
            ..scale = boss.scale
            ..anchor = Anchor.center;
          if (step > 4) {
            bullet.add(MoveAlongPathEffect(
                Path()..lineTo(cos(radians) * 100, sin(radians) * 100),
                SineEffectController(period: 2)));
          }
          bullets.add(bullet);
        }
        addAll(bullets);
      }
      if (step == 8) {
        eventHandler.handleEvent("three");
        timer.cancel();
      }
    });
  }

  void hellOne(SpriteAnimationComponent boss) {
    gameWall.autoRemove = false;
    int step = 0;
    async.Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      step++;
      double radians = 0;
      bool oddStep = step % 2 == 1;
      for (int i = 0; i < 8; i++) {
        radians += 2 * pi / 8;
        var other = 37;
        var i = 0;
        i = (i + 1) % other;
        var bullets = <Bullet>[];
        for (int i = 0; i < other; i++) {
          var radius = (oddStep ? 100 : 200);
          var bullet = Bullet(boss, (pi / other - pi) * i,
              speed: 100, randomizeStepTime: true)
            ..position = Vector2(boss.position.x + cos(radians) * radius,
                boss.position.y + sin(radians) * radius)
            ..scale = boss.scale
            ..anchor = Anchor.center;
          if (step > 4) {
            bullet.add(MoveAlongPathEffect(
                Path()..lineTo(cos(radians) * 100, sin(radians) * 100),
                SineEffectController(period: 2)));
          }
          bullets.add(bullet);
        }
        addAll(bullets);
      }
      if (step == 8) {
        eventHandler.handleEvent("two");
        timer.cancel();
      }
    });
  }

  Future<void> addParallaxBackground() async {
    final layerInfo = {
      'background_1.png': 6.0,
      'background_2.png': 8.5,
      'background_3.png': 12.0,
      'background_4.png': 20.5,
    };

    final parallax = ParallaxComponent(
      parallax: Parallax(
        await Future.wait(layerInfo.entries.map(
          (entry) => loadParallaxLayer(
            ParallaxImageData(entry.key),
            fill: LayerFill.width,
            repeat: ImageRepeat.repeat,
            velocityMultiplier: Vector2(entry.value, entry.value),
          ),
        )),
        baseVelocity: Vector2(10, 10),
      ),
    );

    Random().nextBool() ? ImageRepeat.repeatX : ImageRepeat.repeatY;
    async.Timer.periodic(const Duration(seconds: 5), (timer) {
      parallax.parallax?.baseVelocity = Vector2(
        Random().nextBool()
            ? Random().nextInt(20).toDouble()
            : -Random().nextInt(20).toDouble(),
        Random().nextBool()
            ? Random().nextInt(20).toDouble()
            : -Random().nextInt(20).toDouble(),
      );
    });
    add(parallax);
  }
}

class EventHandler {
  final BulletHell bulletHell;
  final SpriteAnimationComponent boss;

  EventHandler(this.bulletHell, this.boss);

  void handleEvent(String event) {
    switch (event) {
      case "one":
        {
          bulletHell.hellOne(boss);
          break;
        }
      case "two":
        {
          bulletHell.hellTwo(boss);
          break;
        }
      case "three":
        {
          bulletHell.hellThree(boss);
          break;
        }
      case "four":
        {
          bulletHell.hellFour(boss);
          break;
        }
    }
  }
}
