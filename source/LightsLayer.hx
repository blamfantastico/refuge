package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.BlendMode;
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.filters.BlurFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class LightsLayer extends FlxGroup {
	public static inline var SCALE:Float = 1 / 3;

	public var layerAlpha:Float;
	public var lightSprite:FlxSprite;

	private var _filter:BlurFilter;
	private var _matrix:Matrix;
	private var _inverseMatrix:Matrix;
	private var _point:Point;
	private var _rect:Rectangle;
	private var _pixels:BitmapData;
	private var _alphaPixels:BitmapData;
	private var _gradient:Shape;
	private var _gradientMatrix:Matrix;
	private var _scaledWidth:Int;
	private var _scaledHeight:Int;
	private var _finalPixels:BitmapData;

	public function new(scale:Float = 0.333, alpha:Float = 0.8, blurX:Float = 8, blurY:Float = 8) {
		super();

		layerAlpha = alpha;
		_filter = new BlurFilter(blurX, blurY, 2);

		_scaledWidth = Std.int(FlxG.width * scale);
		_scaledHeight = Std.int(FlxG.height * scale) + 1;

		_matrix = new Matrix();
		_matrix.scale(Math.floor(1 / scale), Math.floor(1 / scale));
		_inverseMatrix = new Matrix();
		_inverseMatrix.scale(scale, scale);
		_point = new Point(0, 0);
		_rect = new Rectangle(0, 0, _scaledWidth, _scaledHeight);
		_pixels = new BitmapData(_scaledWidth, _scaledHeight, true);
		_alphaPixels = new BitmapData(_scaledWidth, _scaledHeight);
		_finalPixels = new BitmapData(FlxG.width, FlxG.height, true);

		// vignette gradient overlay
		_gradientMatrix = new Matrix();
		_gradientMatrix.createGradientBox(_scaledHeight * 2, _scaledHeight * 2, 270 * (Math.PI / 180), (_scaledHeight * 2 - _scaledWidth) * -0.5, 0);
		_gradient = new Shape();
		_gradient.graphics.beginGradientFill(GradientType.RADIAL, [Std.int(0x000000 + Math.floor(0xff * alpha)), 0x0000ff], [1.0, 1.0], [240, 255],
			_gradientMatrix);
		_gradient.graphics.drawRect(0, 0, _scaledWidth, _scaledHeight);
		_gradient.graphics.endFill();

		// Create a sprite to display the lighting
		// scrollFactor defaults to (1,1) so it scrolls with the intro transition
		lightSprite = new FlxSprite(0, 0);
		lightSprite.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
	}

	override public function draw():Void {
		// Get reference to play state to check game over
		var playState = Std.downcast(FlxG.state, PlayState);
		var gameOver = playState != null && playState.gameOver;

		// Fill with base darkness (blue channel = darkness level)
		// High blue = high alpha later = more darkness
		_alphaPixels.fillRect(_alphaPixels.rect, Std.int(Math.floor(0xff * layerAlpha)) | 0xff000000);

		// Draw vignette gradient (adds blue at edges for subtle light)
		if (!gameOver) {
			_alphaPixels.draw(_gradient);
		}

		// Draw lights (black circles remove blue = create transparency)
		for (basic in members) {
			var light = Std.downcast(basic, Light);
			if (light != null && light.exists) {
				light.renderInto(_alphaPixels, _inverseMatrix);
			}
		}

		// Blur
		_alphaPixels.applyFilter(_alphaPixels, _alphaPixels.rect, _point, _filter);

		// Copy blue channel to alpha channel of black bitmap
		_pixels.fillRect(_pixels.rect, 0xff000000);
		_pixels.copyChannel(_alphaPixels, _alphaPixels.rect, _point, BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);

		// Scale up to final size
		_finalPixels.fillRect(_finalPixels.rect, 0x00000000);
		_finalPixels.draw(_pixels, _matrix);

		// Update sprite pixels directly
		var spritePixels = lightSprite.pixels;
		spritePixels.fillRect(spritePixels.rect, 0x00000000);
		spritePixels.copyPixels(_finalPixels, _finalPixels.rect, _point);
		lightSprite.dirty = true;
		lightSprite.draw();
	}
}
