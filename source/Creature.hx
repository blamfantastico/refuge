package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class Creature extends FlxSprite {
	public static var BASE_DOWN_SPEED:Float = 20;

	private static inline var SCALE:Int = 4;
	private static inline var STATE_SPAWNING:Int = 0;
	private static inline var STATE_DESCENDING:Int = 1;
	private static inline var STATE_ATTACKING:Int = 2;
	private static inline var STATE_WANDERING:Int = 3;

	public var chain:Dynamic;
	public var dying:Bool = false;
	public var creaturesLayer:CreaturesLayer;

	private var _attacking:Building;
	private var _attackTime:Float = 0;
	private var _downMultiplier:Float;
	private var _downSpeed:Float;
	private var _explosion:CreatureExplosion;
	private var _light:Light;
	private var _lightBeam:Light;
	private var _nextAttackTime:Float = 0;
	private var _pixelsAlive:BitmapData;
	private var _pixelsDead:BitmapData;
	private var _spawnTime:Float;
	private var _state:Int;
	private var _text:FlxText;
	private var _brightness:Float;
	private var _beamShape:Shape;

	public function new(lightsLayer:LightsLayer) {
		super(0, 0);

		_brightness = 0.3 + (0.7 * Math.random());

		// Create creature bitmap
		_pixelsAlive = new BitmapData(SCALE * 5, SCALE * 5, true, 0x00000000);
		var scaledMatrix = new Matrix(SCALE, 0, 0, SCALE);
		CreatureBitmaps.drawNext(_pixelsAlive, scaledMatrix);

		// Apply brightness
		var brightnessTransform = new ColorTransform(_brightness, _brightness, _brightness);
		_pixelsAlive.colorTransform(new Rectangle(0, 0, SCALE * 5, SCALE * 5), brightnessTransform);

		// Create dead pixels version
		_pixelsDead = _pixelsAlive.clone();
		var deadTransform = new ColorTransform(0.4, 0.6, 0.2, 1.0, 50, 50, 50);
		_pixelsDead.colorTransform(new Rectangle(0, 0, SCALE * 5, SCALE * 5), deadTransform);

		loadGraphic(_pixelsAlive);

		_explosion = new CreatureExplosion(_brightness);
		_light = new Light();
		_light.kill();
		lightsLayer.add(_light);
		_lightBeam = new Light();
		_lightBeam.kill();
		lightsLayer.add(_lightBeam);

		_beamShape = new Shape();

		creatureSpawn();
	}

	public function getExplosion():CreatureExplosion {
		return _explosion;
	}

	public function hitFloorCreature():Bool {
		if (dying) {
			FlxG.sound.play("sounds/creature_explode.mp3", 0.3);
			super.kill();
			explode(-1.5);
			flash(60);
		}
		return true;
	}

	public function hitWallCreature(movingRight:Bool):Bool {
		velocity.x *= -1;
		return true;
	}

	public function killCreature():Void {
		if (!alive || dying)
			return;
		FlxG.sound.play("sounds/creature_hit.mp3");
		maxVelocity.y = 80;
		dying = true;
		explode(0.6);
		flash(40);
		loadGraphic(_pixelsDead);
	}

	override public function draw():Void {
		// Draw attack beam before the creature
		if (!dying && alive && _attacking != null) {
			_beamShape.graphics.clear();
			_beamShape.graphics.lineStyle(3, 0xff006600, 0.5, true, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			_beamShape.graphics.moveTo(x + width / 2, y + height / 2);
			_beamShape.graphics.lineTo(_attacking.x + _attacking.width / 2, _attacking.y + _attacking.height / 2);
			FlxG.camera.buffer.draw(_beamShape);
		}
		super.draw();
	}

	public function setText(text:String):Void {
		var lines = text.split('\n').length;
		var ty:Float = y - lines * 10;
		if (_text == null) {
			_text = new FlxText(Std.int(x), Std.int(ty), 300, text);
			_text.setFormat(null, 6, 0xff999999);
			FlxG.state.add(_text);
		} else {
			_text.text = text;
			_text.x = x;
			_text.y = ty;
		}
		_text.alpha = 1.0;
		_text.visible = true;

		FlxTween.cancelTweensOf(_text);
		FlxTween.tween(_text, {y: _text.y - 10}, 1.0, {
			ease: FlxEase.linear,
			onComplete: function(_) {
				FlxTween.tween(_text, {alpha: 0}, 0.3, {
					ease: FlxEase.linear,
					onComplete: function(_) {
						_text.visible = false;
					}
				});
			}
		});
	}

	public function creatureSpawn():Void {
		reset(x, y);
		loadGraphic(_pixelsAlive);
		alpha = 1.0;
		acceleration.y = 80;
		chain = null;
		dying = false;
		maxVelocity.y = 5;
		velocity.x = Math.random() * 60 - 30;
		_attacking = null;
		_attackTime = 0;
		_downMultiplier = Math.random();
		_explosion.kill();
		_light.kill();
		_lightBeam.kill();
		_nextAttackTime = 0;
		_spawnTime = FlxG.game.ticks / 1000.0;
		_state = STATE_SPAWNING;
		FlxTween.cancelTweensOf(_light);
	}

	override public function update(elapsed:Float):Void {
		var currentTime = FlxG.game.ticks / 1000.0;
		_downSpeed = 5 + _downMultiplier * BASE_DOWN_SPEED;
		_explosion.x = x;
		_explosion.y = y;

		if (dying) {
			maxVelocity.y = 80;
		} else if (_state == STATE_SPAWNING) {
			maxVelocity.y = _downSpeed + Math.min(((64 - y) / 64) * (80 - _downSpeed), (80 - _downSpeed));
		} else if (_state == STATE_DESCENDING) {
			maxVelocity.y = _downSpeed;
		} else if (_state == STATE_WANDERING) {
			maxVelocity.y = _downSpeed;
		} else if (_state == STATE_ATTACKING) {
			maxVelocity.y = 0;
		}

		super.update(elapsed);

		if (!dying) {
			switch (_state) {
				case STATE_SPAWNING:
					if (y > 64)
						_state = STATE_DESCENDING;
				case STATE_DESCENDING:
					if (y > 460)
						_state = STATE_ATTACKING;
				case STATE_ATTACKING:
					var playState = Std.downcast(FlxG.state, PlayState);
					if (playState != null && playState.gameOver) {
						_state = STATE_WANDERING;
						_attacking = null;
						_attackTime = 0;
						_nextAttackTime = 0;
					} else {
						y = y + Math.sin(currentTime - _spawnTime) * 0.1;
						if (_attacking != null) {
							if (currentTime > _attackTime)
								beamAttackFinish();
						} else if (currentTime > _nextAttackTime) {
							beamAttackStart();
						}
					}
				case STATE_WANDERING:
					if (y >= 460 && _downMultiplier > 0) {
						_downMultiplier *= -1;
					} else if (y <= 80 && _downMultiplier < 0) {
						_downMultiplier *= -1;
					}
			}
		}

		if (_light.exists && (_light.lightX != x || _light.lightY != y)) {
			_light.xy(x + width / 2, y + height / 2);
		}
	}

	private function beamAttackStart():Void {
		var playState = Std.downcast(FlxG.state, PlayState);
		if (playState == null)
			return;

		var buildings = playState.buildingsLayer.buildings;
		var target:Building = null;
		var targetDelta:Float = 0;

		for (building in buildings) {
			if (building == null || !building.alive)
				continue;
			var deltaX = (x + width / 2) - (building.x + building.width / 2);
			var deltaY = (y + height / 2) - (building.y + building.height / 2);
			var delta = deltaX * deltaX + deltaY * deltaY;
			if (delta < 100 * 100 && (target == null || delta < targetDelta)) {
				target = building;
				targetDelta = delta;
			}
		}

		if (target != null) {
			FlxG.sound.play("sounds/creature_shoot.mp3", 0.2);
			_attacking = target;
			_attackTime = FlxG.game.ticks / 1000.0 + 1;
		}
	}

	private function beamAttackFinish():Void {
		flash(20, _attacking.x + _attacking.width * 0.5, _attacking.y + _attacking.height * 0.5, _lightBeam);
		_attacking.hurt(1);
		_attacking = null;
		_attackTime = 0;
		_nextAttackTime = FlxG.game.ticks / 1000.0 + 2;
	}

	private function explode(delay:Float = 0.2):Void {
		_explosion.explosionDelay = delay;
		_explosion.x = x + width / 2;
		_explosion.y = y + height / 2;
		_explosion.start(true, 0.5, 8);
	}

	private function flash(radius:Float, X:Float = 0, Y:Float = 0, ?light:Light):Void {
		if (light == null)
			light = _light;
		light.spawn();
		light.xy(X != 0 ? X : x, Y != 0 ? Y : y);
		light.scale = radius;
		FlxTween.tween(light, {scale: 0}, 0.05, {
			ease: FlxEase.linear,
			onComplete: function(_) {
				light.kill();
			}
		});
	}
}
