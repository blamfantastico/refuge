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
	public static inline var SPEED:Float = 400; // Increased for HaxeFlixel's pixel/second velocity
	public static inline var SIZE:Int = 6;

	public var bounces:Int = 0;
	public var lifeTime(get, never):Float;

	private var _explosion:BulletExplosion;
	private var _light:Light;
	private var _spawnTime:Float;
	private var _lastVelocityX:Float = 0;
	private var _lastVelocityY:Float = 0;

	public function new(lightsLayer:LightsLayer) {
		super(0, 0);
		makeGraphic(SIZE, SIZE, COLOR);
		acceleration.y = 8; // Slight gravity
		kill();

		_explosion = new BulletExplosion();
		_light = new Light(0, 0, SIZE * 4);
		_light.kill();
		lightsLayer.add(_light);
	}

	public function getExplosion():BulletExplosion {
		return _explosion;
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

	public function hurtBullet(Damage:Float):Void {
		if (!alive)
			return;
		FlxG.sound.play("sounds/bullet_explode.mp3", 0.7);
		health -= Damage;
		if (health > 0)
			return;
		killBullet();
		velocity.x = 0;
		velocity.y = 0;
		_explosion.x = x + width / 2;
		_explosion.y = y + height / 2;
		_explosion.start(true, 0.5, 6);
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
