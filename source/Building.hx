package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class Building extends FlxSprite {
	public static var sndExplode:flixel.sound.FlxSound;

	private var _dying:Bool = false;
	private var _damageFlashTimer:Float = 0;
	private var _originalX:Float;

	public function new(X:Int, Y:Int, W:Int = 16, H:Int = 16) {
		super(X, Y);
		_originalX = X;

		// Create building graphic with windows
		var bitmapData = new BitmapData(W, H, true, 0xff000000);
		for (wy in 0...4) {
			for (wx in 0...4) {
				if (Math.random() < 0.5) {
					var b:Int = 128 + Std.int(Math.random() * 128);
					var color:FlxColor = FlxColor.fromRGB(b, b, b);
					// Draw 2x2 window
					bitmapData.setPixel32(2 + wx * 5 + 0, wy * 4 + 2, color);
					bitmapData.setPixel32(2 + wx * 5 + 1, wy * 4 + 2, color);
					bitmapData.setPixel32(2 + wx * 5 + 0, wy * 4 + 3, color);
					bitmapData.setPixel32(2 + wx * 5 + 1, wy * 4 + 3, color);
				}
			}
		}
		loadGraphic(bitmapData);

		health = 3;
		immovable = true;

		// Load sound if not already loaded
		if (sndExplode == null) {
			sndExplode = FlxG.sound.load("sounds/building_explode.mp3");
		}
	}

	override public function hurt(Damage:Float):Void {
		_damageFlashTimer = 0.3;
		if (!alive || _dying)
			return;
		health -= Damage;
		if (health > 0)
			return;
		kill();
	}

	override public function kill():Void {
		if (!alive || _dying)
			return;
		FlxG.sound.play("sounds/building_explode.mp3", 0.7);
		_dying = true;
		_originalX = x;

		FlxTween.tween(this, {y: y + height}, 3.0, {
			ease: FlxEase.quadIn,
			onComplete: function(_) {
				_killkill();
			},
			onUpdate: function(_) {
				// Shake effect as building sinks
				if (Math.random() < (y - _originalX) / height) {
					x = _originalX + Math.floor(Math.random() * 3) - 1;
				} else {
					x = _originalX;
				}
			}
		});
	}

	private function _killkill():Void {
		super.kill();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// Handle damage flash
		if (_damageFlashTimer > 0) {
			_damageFlashTimer -= elapsed;
			color = FlxColor.fromRGB(255, 255 + 32, 255);
		} else {
			color = FlxColor.WHITE;
		}
	}
}
