package menu;

import flixel.FlxG;
import flixel.group.FlxGroup;

class MenuCreaturesLayer extends FlxGroup {
	public function new() {
		super();

		for (i in 0...500) {
			var creature = new MenuCreature();
			creature.x = Math.floor(Math.random() * FlxG.width);
			add(creature);
		}
	}
}
