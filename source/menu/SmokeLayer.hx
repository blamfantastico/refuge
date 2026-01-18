package menu;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.filters.BlurFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class SmokeLayer extends FlxSprite {
	public function new() {
		super(0, 0);

		var pixels = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
		var point = new Point(0, 0);
		var rect = new Rectangle(0, 0, pixels.width, pixels.height);

		// Draw a green gradient against the background
		var m = new Matrix();
		m.createGradientBox(FlxG.width, FlxG.height, 90 * (Math.PI / 180), 0, 0);
		var gradient = new Shape();
		gradient.graphics.beginGradientFill(GradientType.LINEAR, [0x669933, 0x000000], [0.0, 0.5], [0, 255], m);
		gradient.graphics.drawRect(0, 0, FlxG.width, FlxG.height);
		gradient.graphics.endFill();
		pixels.draw(gradient);

		// Draw some smokey green blobs on top of it
		var circle = new Shape();
		circle.graphics.beginFill(0xff669933);
		circle.graphics.drawCircle(5, 5, 5);
		circle.graphics.endFill();

		m.identity();
		drawRandomCircles(pixels, circle, m, 0, FlxG.height - 128 - 32, 216);
		drawRandomCircles(pixels, circle, m, FlxG.width - 180, FlxG.height - 128 - 32, 200);

		// Blur it all
		pixels.applyFilter(pixels, rect, point, new BlurFilter(30, 30, 3));

		loadGraphic(pixels);
	}

	private function drawRandomCircles(pixels:BitmapData, circle:Shape, m:Matrix, startX:Float, startY:Float, width:Float):Void {
		for (i in 0...100) {
			m.tx = startX + Math.random() * width;
			var r:Float = Math.random();
			var yOffset:Float;
			if (r < 0.7) {
				yOffset = Math.random() * 8;
			} else if (r < 0.9) {
				yOffset = 16 + Math.random() * 8;
			} else {
				yOffset = 32 + Math.random() * 16;
			}
			m.ty = (startY + 32) - yOffset;
			var scale = Math.random();
			m.a = scale;
			m.d = scale;
			pixels.draw(circle, m);
		}
	}
}
