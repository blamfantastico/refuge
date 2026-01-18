package;

import flixel.group.FlxGroup;

class BuildingsLayer extends FlxGroup {
	public var buildings:FlxTypedGroup<Building>;

	public function new() {
		super();
		buildings = new FlxTypedGroup<Building>();

		addBuildings([
			[32, 481, 2],
			[48, 516, 3],
			[64, 516, 2],
			[80, 548, 3],
			[96, 548, 1],
			[112, 548, 2],
			[128, 552, 2],
			[144, 552, 3],
			[160, 532, 3],
			[176, 521, 3],
			[192, 516, 2],
			[208, 516, 2],
			[224, 508, 1],
			[240, 508, 1],
			[256, 508, 1],
			[272, 508, 2],
			[288, 508, 3],
			[304, 516, 3],
			[320, 524, 2],
			[336, 532, 2],
			[352, 532, 1],
			[368, 545, 2],
			[384, 545, 2],
			[400, 540, 3],
			[416, 524, 2],
			[432, 488, 1],
		]);
	}

	private function addBuildings(values:Array<Array<Int>>):Void {
		for (b in values) {
			var heightTiles:Int = b[2];
			var pixelHeight:Int = heightTiles * 16;
			var building = new Building(b[0], b[1] - pixelHeight + 16, 16, pixelHeight);
			buildings.add(building);
			add(building);
		}
	}

	public function buildingsAreAllDead():Bool {
		for (building in buildings) {
			if (building != null && building.alive)
				return false;
		}
		return true;
	}
}
