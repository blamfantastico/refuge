package;

import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

class Light extends FlxBasic {
	private static var _colorTransform:ColorTransform;
	private static var _defaultShape:Shape;

	public var alpha:Float = 1.0;
	public var lightX:Float = 0;
	public var lightY:Float = 0;
	public var shape:Shape;

	private var _angle:Float = 0;
	private var _matrix:Matrix;
	private var _radians:Float = 0;
	private var _scale:Float = 1;

	public function new(x:Float = 0, y:Float = 0, scale:Float = 1, alpha:Float = 1, angle:Float = 0, shape:Shape = null) {
		super();

		if (_colorTransform == null) {
			_colorTransform = new ColorTransform();
			_defaultShape = new Shape();
			// Use larger base circle (radius 64) to avoid HTML5 canvas scaling issues
			// Black removes blue channel = creates transparency in final overlay
			_defaultShape.graphics.beginFill(0x000000, 1.0);
			_defaultShape.graphics.drawCircle(0, 0, 64);
			_defaultShape.graphics.endFill();
		}

		_matrix = new Matrix();
		this.alpha = alpha;
		this.angle = angle;
		this.scale = scale;
		this.shape = shape != null ? shape : _defaultShape;
		this.xy(x, y);
	}

	private static inline var BASE_RADIUS:Float = 64;

	public function renderInto(alphaPixels:BitmapData, matrix:Matrix):Void {
		// Only adjust scale for default shape (which has radius 64 instead of 1)
		var adjustedScale = (shape == _defaultShape) ? _scale / BASE_RADIUS : _scale;
		_matrix.identity();
		_matrix.scale(adjustedScale, adjustedScale);
		_matrix.rotate(_radians);
		_matrix.translate(lightX, lightY);
		if (matrix != null)
			_matrix.concat(matrix);

		if (alpha != 1.0) {
			_colorTransform.alphaMultiplier = alpha;
			alphaPixels.draw(shape, _matrix, _colorTransform);
		} else {
			alphaPixels.draw(shape, _matrix);
		}
	}

	public function spawn():Void {
		FlxTween.cancelTweensOf(this);
		exists = true;
		alive = true;
		alpha = 1.0;
	}

	public var angle(get, set):Float;

	private function get_angle():Float {
		return _angle;
	}

	private function set_angle(value:Float):Float {
		_angle = value;
		_radians = _angle * (Math.PI / 180);
		return _angle;
	}

	public var radians(get, set):Float;

	private function get_radians():Float {
		return _radians;
	}

	private function set_radians(value:Float):Float {
		_radians = value;
		_angle = _radians * (180 / Math.PI);
		return _radians;
	}

	public var scale(get, set):Float;

	private function get_scale():Float {
		return _scale;
	}

	private function set_scale(value:Float):Float {
		_scale = value;
		return _scale;
	}

	public function xy(x:Float, y:Float):Void {
		this.lightX = x;
		this.lightY = y;
	}
}
