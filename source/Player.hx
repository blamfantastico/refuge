package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;

class Player extends FlxSprite {
	private static inline var BULLET_COUNT:Int = 1;
	private static inline var COLOR:FlxColor = 0xff2b2213; // brown
	private static inline var COLOR_LIGHT:FlxColor = 0xffffff99; // yellow
	private static inline var SIZE:Int = 24;

	private var _aim:Float = 0;
	private var _aimX:Float = 0;
	private var _aimY:Float = 0;
	private var _bullets:FlxTypedGroup<Bullet>;
	private var _lights:Array<Light>;
	private var _muzzle:FlxSprite;
	private var _playerLayer:FlxGroup;
	private var _lightsLayer:LightsLayer;
	private var _playerAngle:Float = 270;

	public function new(layer:FlxGroup, lightsLayer:LightsLayer) {
		super(0, 0);
		_playerLayer = layer;
		_lightsLayer = lightsLayer;

		makeGraphic(SIZE, SIZE, COLOR);
		drag.x = 10;
		drag.y = 10;
		maxVelocity.x = 50;
		maxVelocity.y = 100;

		// Give him some bullets
		_bullets = new FlxTypedGroup<Bullet>();
		for (i in 0...BULLET_COUNT) {
			var bullet = new Bullet(lightsLayer);
			_bullets.add(bullet);
			layer.add(bullet);
			layer.add(bullet.getExplosion());
		}

		// Give him some lights
		_lights = [];
		_lights.push(new Light(0, 0, SIZE * 2));
		_lights.push(new Light(0, 0, SIZE * 4, 0.3));
		_lights.push(new Light(0, 0, SIZE * 8, 0.2));
		_lights.push(new Light(0, 0, SIZE * 16, 0.1));
		for (light in _lights) {
			lightsLayer.add(light);
		}

		// The muzzle is the little sprite attached to the end of the player turret
		_muzzle = new FlxSprite(0, 0);
		_muzzle.makeGraphic(Std.int(SIZE / 4), Std.int(SIZE / 4), COLOR_LIGHT);
		layer.add(_muzzle);
	}

	public function getBullets():FlxTypedGroup<Bullet> {
		return _bullets;
	}

	public function onBulletHitCreature(bullet:Bullet, creature:Creature):Void {
		if (!creature.dying) {
			var playState = Std.downcast(FlxG.state, PlayState);
			if (playState != null) {
				playState.onEvent(PlayState.EVENT_KILL, {killed: creature, bullet: bullet});
			}
			creature.killCreature();
			// Original used 1.0, scaled down to compensate for higher bullet speed
			creature.velocity.x += bullet.velocity.x * 0.1;
			creature.velocity.y += bullet.velocity.y * 0.1;
		} else {
			// Original used 0.5
			creature.velocity.x += bullet.velocity.x * 0.05;
			creature.velocity.y += bullet.velocity.y * 0.05;
		}
		bullet.hurtBullet(1);
	}

	private function shootBullet():Bullet {
		var bullet:Bullet = null;
		for (b in _bullets) {
			if (b != null && !b.exists) {
				bullet = b;
				break;
			}
		}
		if (bullet == null)
			return null; // don't shoot anything if all bullets are in flight

		bullet.shoot(_muzzle.x, _muzzle.y, _aimX, _aimY);
		return bullet;
	}

	public function onGameOver():Void {
		var _this = this;
		var oldX:Float = x;

		new FlxTimer().start(0.2, function(_) {
			FlxG.sound.play("sounds/building_explode.mp3", 0.7);
		});
		new FlxTimer().start(1.0, function(_) {
			FlxG.sound.play("sounds/building_explode.mp3", 0.7);
		});
		new FlxTimer().start(2.4, function(_) {
			FlxG.sound.play("sounds/building_explode.mp3", 0.7);
		});

		// Sink into the ground
		FlxTween.tween(_this, {y: y + height * 1.5}, 5.0, {
			ease: FlxEase.quadIn,
			onUpdate: function(tween:FlxTween) {
				var t = tween.percent;
				if (Math.random() < t * t) {
					x = oldX + Math.floor(Math.random() * 3) - 1;
				} else {
					x = oldX;
				}
			}
		});

		// Rotate back to the top
		FlxTween.tween(this, {_playerAngle: 270}, 2.0, {ease: FlxEase.linear});

		// Fade out the lights
		fadeOutLight(_lights[0], 0);
		new FlxTimer().start(1.0, function(_) {
			fadeOutLight(_lights[1], 0);
		});
		new FlxTimer().start(2.0, function(_) {
			fadeOutLight(_lights[2], 0);
		});
	}

	private function fadeOutLight(light:Light, delay:Float):Void {
		var baseAlpha:Float = light.alpha;
		FlxTween.tween(light, {alpha: 0}, 5.0, {
			ease: FlxEase.quadIn,
			startDelay: delay,
			onComplete: function(_) {
				light.alpha = 0.0;
				light.kill();
			},
			onUpdate: function(tween:FlxTween) {
				var t = tween.percent;
				light.alpha = baseAlpha - (t + Math.random() * 0.3) * baseAlpha;
			}
		});
	}

	override public function update(elapsed:Float):Void {
		var playState = Std.downcast(FlxG.state, PlayState);
		var isGameOver = playState != null && playState.gameOver;

		if (!isGameOver) {
			if (FlxG.keys.pressed.LEFT) {
				_playerAngle = (_playerAngle - elapsed * 120);
				if (_playerAngle < 0)
					_playerAngle += 360;
			}
			if (FlxG.keys.pressed.RIGHT) {
				_playerAngle = (_playerAngle + elapsed * 120) % 360;
			}
		}

		_aimX = Math.cos(_playerAngle * (Math.PI / 180));
		_aimY = Math.sin(_playerAngle * (Math.PI / 180));

		if (!isGameOver && (FlxG.keys.justPressed.X || FlxG.keys.justPressed.C || FlxG.keys.justPressed.SPACE)) {
			shootBullet();
		}

		super.update(elapsed);

		// Move the lights to match the angle
		for (i in 0..._lights.length) {
			var s:Float = _lights[i].scale;
			if (i == 0)
				s /= 2;
			_lights[i].xy(x + width / 2 + _aimX * s, y + _aimY * s);
		}

		// Rotate player and muzzle to match aim angle
		angle = _playerAngle;
		_muzzle.angle = _playerAngle;
		_muzzle.x = (x + (width * 0.5)) - (_muzzle.width * 0.5);
		_muzzle.y = (y + (height * 0.5)) - (_muzzle.height * 0.5);
		_muzzle.x += SIZE / 2 * _aimX;
		_muzzle.y += SIZE / 2 * _aimY;
	}

	public function updateBullets(blocksLayer:BlocksLayer, creaturesLayer:CreaturesLayer):Void {
		// Handle bullet collisions with walls/floors
		for (bullet in _bullets) {
			if (bullet != null && bullet.exists && bullet.alive) {
				// Check collision with blocks
				FlxG.collide(bullet, blocksLayer.blocks, function(b:FlxObject, block:FlxObject) {
					var bul = cast(b, Bullet);
					// Determine which side was hit
					if (bul.touching.has(FlxDirectionFlags.FLOOR)) {
						bul.onHitFloor();
					} else if (bul.touching.has(FlxDirectionFlags.CEILING)) {
						bul.onHitCeiling();
					} else if (bul.touching.has(FlxDirectionFlags.LEFT) || bul.touching.has(FlxDirectionFlags.RIGHT)) {
						bul.onHitWall();
					}
				});

				// Check overlap with creatures
				FlxG.overlap(bullet, creaturesLayer.creatures, function(b:FlxObject, c:FlxObject) {
					var bul = cast(b, Bullet);
					var creature = cast(c, Creature);
					if (creature.exists && creature.alive) {
						onBulletHitCreature(bul, creature);
					}
				});
			}
		}
	}
}
