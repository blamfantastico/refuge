package menu;

import CreatureBitmaps;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class MenuCreature extends FlxSprite {
	private var _baseY:Float;
	private var _offset:Float;
	private var _spawnTime:Float;

	public function new() {
		super(0, 0);

		var creatureScale:Int = Math.random() < 0.7 ? 1 : 2;
		var size:Int = creatureScale * 5;

		// Create creature bitmap
		var bitmapData = new BitmapData(size, size, true, 0x00000000);
		CreatureBitmaps.drawNext(bitmapData, new Matrix(creatureScale, 0, 0, creatureScale));

		// Make it black silhouette
		bitmapData.colorTransform(new Rectangle(0, 0, size, size), new ColorTransform(0, 0, 0));

		loadGraphic(bitmapData);

		if (creatureScale == 1) {
			alpha = 0.3 + Math.random() * 0.7;
		} else {
			alpha = 1.0;
		}

		menuSpawn();
	}

	public function menuSpawn():Void {
		maxVelocity.x = (5 + Math.random() * 10) * alpha;
		acceleration.x = 100;
		acceleration.y = 0;
		x = -width;
		y = _baseY = Math.random() * (FlxG.height - 128);
		_offset = Math.random() * 1000;
		_spawnTime = FlxG.game.ticks / 1000.0;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (x > FlxG.width) {
			x = -width;
		}

		var currentTime = FlxG.game.ticks / 1000.0;
		y = _baseY + Math.sin(currentTime + _offset) * 4 * alpha;
	}
}
