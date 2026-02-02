package;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class BlocksLayer extends FlxGroup {
	private static inline var COLOR:FlxColor = 0xff333333;

	public var blocks:FlxGroup;

	public function new() {
		super();
		blocks = new FlxGroup();

		// boundaries
		addBlocks([
			[0, -640, 192, 672], // roof - extended higher for off-screen collision
			[288, -640, 192, 672],
			[0, 32, 128, 32], // more roof blocks
			[352, 32, 128, 32],
			[0, 64, 96, 32],
			[384, 64, 96, 32],
			[0, 96, 64, 64],
			[416, 96, 64, 64],
			[0, 32, 32, 576], // walls
			[448, 32, 32, 576],
			[0, 608, 480, 32], // floor
		]);

		// ceiling
		addBlocks([
			[398, 91, 26, 33],
			[440, 157, 18, 49],
			[71, 59, 49, 22],
			[51, 94, 27, 29],
			[26, 152, 24, 59],
			[304, 30, 33, 14],
			[366, 53, 24, 18],
			[123, 22, 24, 22],
		]);

		// floor
		addBlocks([
			[32, 496, 16, 112],
			[48, 532, 32, 76],
			[80, 564, 48, 44],
			[128, 576, 32, 32],
			[160, 564, 16, 44],
			[176, 548, 16, 60],
			[192, 532, 32, 76],
			[224, 524, 80, 84],
			[304, 532, 16, 76],
			[320, 540, 16, 68],
			[336, 548, 32, 60],
			[368, 568, 32, 40],
			[400, 556, 32, 52],
			[416, 540, 32, 68],
			[432, 504, 16, 40],
			[176, 544, 16, 8],
			[176, 536, 16, 12],
			[160, 548, 16, 20],
			[128, 568, 32, 12],
			[352, 560, 48, 12],
		]);
	}

	private function addBlocks(values:Array<Array<Int>>):Void {
		for (r in values) {
			var block = new Block(r[0], r[1], r[2], r[3], COLOR);
			blocks.add(block);
			add(block);
		}
	}
}
