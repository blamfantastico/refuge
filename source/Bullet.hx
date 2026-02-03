package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Bullet extends FlxSprite {
	public static inline var COLOR:FlxColor = 0xffffff00;
	public static inline var ELASTICITY:Float = 0.4;
	// Original was 25, tuned to 400 (16x) for equivalent feel in HaxeFlixel
	public static inline var SPEED:Float = 400;
	public static inline var SIZE:Int = 6;

	public static inline var EXPLOSION_COUNT:Int = 3;

	public var bounces:Int = 0;
	public var lifeTime(get, never):Float;

	private var _explosions:Array<BulletExplosion>;
	private var _explosionIndex:Int = 0;
	private var _light:Light;
	private var _spawnTime:Float;
	private var _lastVelocityX:Float = 0;
	private var _lastVelocityY:Float = 0;

	public function new(lightsLayer:LightsLayer) {
		super(0, 0);
		makeGraphic(SIZE, SIZE, COLOR);
		acceleration.y = 100; // Original 0.5, tuned for arc feel
		kill();

		_explosions = [];
		for (i in 0...EXPLOSION_COUNT) {
			_explosions.push(new BulletExplosion());
		}
		_light = new Light(0, 0, SIZE * 4);
		_light.kill();
		lightsLayer.add(_light);
	}

	public function getExplosions():Array<BulletExplosion> {
		return _explosions;
	}

	public function getLight():Light {
		return _light;
	}

	public function onHitWall():Void {
		++bounces;
		hurtBullet(1);
		if (alive) {
			velocity.x = -_lastVelocityX * ELASTICITY;
		}
	}

	public function onHitFloor():Void {
		hurtBullet(1);
		if (alive) {
			velocity.y = -_lastVelocityY * ELASTICITY;
		}
	}

	public function onHitCeiling():Void {
		hurtBullet(1);
		if (alive) {
			velocity.y = -_lastVelocityY * ELASTICITY;
		}
	}

	public function hurtBullet(Damage:Float, ?hitTarget:FlxSprite):Void {
		if (!alive)
			return;
		FlxG.sound.play("sounds/bullet_explode.mp3", 0.7);
		health -= Damage;
		if (health > 0)
			return;

		// Use stored velocity from before collision (velocity may be zeroed by collision system)
		var bulletVelX = _lastVelocityX;
		var bulletVelY = _lastVelocityY;

		killBullet();
		velocity.x = 0;
		velocity.y = 0;
		// Cycle through explosion emitters to allow multiple simultaneous explosions
		var explosion = _explosions[_explosionIndex];
		_explosionIndex = (_explosionIndex + 1) % EXPLOSION_COUNT;

		// Calculate velocity-based bias (normalized to -1 to 1)
		var velocityBiasX = bulletVelX / SPEED;
		var velocityBiasY = bulletVelY / SPEED;

		// Apply directional bias and position emitter
		if (hitTarget != null) {
			// Position emitter halfway between bullet and creature center (collision shapes are generous)
			var bulletCenterX = x + width / 2;
			var bulletCenterY = y + height / 2;
			var targetCenterX = hitTarget.x + hitTarget.width / 2;
			var targetCenterY = hitTarget.y + hitTarget.height / 2;
			explosion.x = (bulletCenterX + targetCenterX) / 2 - explosion.width / 2;
			explosion.y = (bulletCenterY + targetCenterY) / 2 - explosion.height / 2;

			// Weighted blend: hit position (0.6) + bullet velocity (0.4)
			var offsetX = bulletCenterX - targetCenterX;
			var hitBiasX = offsetX / (hitTarget.width / 2);
			hitBiasX = Math.max(-1, Math.min(1, hitBiasX));

			var finalBiasX = hitBiasX * 0.4 + velocityBiasX * 0.6;
			finalBiasX = Math.max(-1, Math.min(1, finalBiasX));

			// Direct hits (hitBiasX near 0) reduce Y momentum, glancing hits preserve it
			var yDamping = Math.abs(hitBiasX);
			var finalBiasY = velocityBiasY * yDamping;

			explosion.setDirectionalBias(finalBiasX, finalBiasY);
		} else {
			// Wall/floor hits: position at bullet center
			explosion.x = x + width / 2 - explosion.width / 2;
			explosion.y = y + height / 2 - explosion.height / 2;
			// Direction toward screen center, magnitude from velocity
			var screenCenterX = FlxG.width / 2;
			var bulletCenterX = x + width / 2;
			var directionToCenter = (bulletCenterX < screenCenterX) ? 1 : -1;
			var magnitude = Math.abs(velocityBiasX*0.6);
			explosion.setDirectionalBias(directionToCenter * magnitude, 0);
		}

		var particleCount = FlxG.random.int(BulletExplosion.MIN_PARTICLES, BulletExplosion.MAX_PARTICLES);
		// Halve particles when hitting a dead creature
		var creature = Std.downcast(hitTarget, Creature);
		if (creature != null && creature.dying) {
			particleCount = Std.int(particleCount / 2);
		}
		explosion.start(true, 1.5, particleCount);
	}

	public function killBullet():Void {
		super.kill();
		FlxTween.tween(_light, {scale: 1}, 1.0, {
			ease: FlxEase.linear,
			onComplete: function(_) {
				_light.kill();
			},
			onUpdate: function(_) {
				_light.alpha = Math.random();
			}
		});
	}

	private function get_lifeTime():Float {
		return FlxG.game.ticks / 1000.0 - _spawnTime;
	}

	public function shoot(X:Float, Y:Float, DirX:Float, DirY:Float):Void {
		FlxG.sound.play("sounds/bullet_shoot.mp3", 0.2);
		reset(X, Y);
		bounces = 0;
		health = 2;
		velocity.x = DirX * SPEED;
		velocity.y = DirY * SPEED;
		_light.scale = SIZE * 4;
		_light.xy(x, y);
		_light.spawn();
		_spawnTime = FlxG.game.ticks / 1000.0;
	}

	override public function update(elapsed:Float):Void {
		_light.xy(x + width / 2, y + height / 2);
		if (!alive || !exists)
			return;
		if (!isOnScreen()) {
			kill();
			return;
		}
		// Store velocity before collision callbacks (HaxeFlixel zeros velocity before callbacks)
		_lastVelocityX = velocity.x;
		_lastVelocityY = velocity.y;
		super.update(elapsed);
	}
}
