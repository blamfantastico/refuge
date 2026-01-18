package;

import openfl.display.BitmapData;
import openfl.geom.Matrix;

class CreatureBitmaps {
	private static var _bits:Array<Array<Array<Int>>> = [
		[[1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 2, 1, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 0]],
		[[0, 0, 1, 0, 0], [1, 1, 2, 1, 1], [0, 1, 1, 1, 0], [0, 1, 0, 1, 0], [1, 0, 0, 0, 1]],
		[[0, 0, 1, 0, 0], [1, 1, 2, 1, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 0], [0, 0, 0, 0, 0]],
		[[1, 1, 1, 1, 1], [1, 2, 1, 2, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 0], [0, 1, 0, 1, 0]],
		[[0, 0, 1, 0, 0], [0, 1, 1, 1, 0], [1, 2, 1, 2, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 0]],
		[[0, 1, 1, 1, 0], [0, 1, 2, 1, 0], [0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [1, 0, 1, 0, 1]],
	];

	private static var _bitsIndex:Int = 0;
	private static var _bitmaps:Array<BitmapData> = [];

	public static function drawNext(pixels:BitmapData, matrix:Matrix):Void {
		var i:Int = _bitsIndex % _bits.length;
		_bitsIndex++;

		if (_bitmaps.length <= i || _bitmaps[i] == null) {
			// Ensure array is large enough
			while (_bitmaps.length <= i) {
				_bitmaps.push(null);
			}

			_bitmaps[i] = new BitmapData(5, 5, true, 0x00000000);
			for (y in 0...5) {
				for (x in 0...5) {
					var color:Int = _bits[i][y][x];
					if (color == 1) {
						_bitmaps[i].setPixel32(x, y, 0xffffffff);
					}
				}
			}
		}
		pixels.draw(_bitmaps[i], matrix);
	}
}
