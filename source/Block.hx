package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Point;

class Block extends FlxSprite {
	public var blockColor:FlxColor;

	public function new(X:Float, Y:Float, Width:Float, Height:Float, Color:FlxColor, Alpha:Bool = false) {
		super(X, Y);
		blockColor = Color;
		makeGraphic(Std.int(Width), Std.int(Height), Color);
		immovable = true;
	}
}
