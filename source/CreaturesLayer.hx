package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import openfl.geom.Rectangle;

class CreaturesLayer extends FlxGroup {
	private static var SPAWN_AREA:Rectangle = new Rectangle(6 * 32, -9 * 32, 3 * 32, 9 * 32);
	private static var SPAWN_TIMERS:Array<{score:Int, interval:Float, baseDownSpeed:Float}> = [
		{score: 50000, interval: 0.5, baseDownSpeed: 35},
		{score: 30000, interval: 0.6, baseDownSpeed: 30},
		{score: 20000, interval: 0.7, baseDownSpeed: 25},
		{score: 10000, interval: 0.8, baseDownSpeed: 20},
		{score: 5000, interval: 0.9, baseDownSpeed: 20},
		{score: 0, interval: 1.0, baseDownSpeed: 20}
	];

	public var creatures:FlxTypedGroup<Creature>;

	private var _lightsLayer:LightsLayer;
	private var _spawnTimer:Float = 1.0;

	public function new(lightsLayer:LightsLayer) {
		super();
		creatures = new FlxTypedGroup<Creature>();
		_lightsLayer = lightsLayer;
	}

	private function addCreature():Creature {
		var playState = Std.downcast(FlxG.state, PlayState);
		if (playState == null)
			return null;

		// Try to recycle an existing creature
		var creature:Creature = null;
		for (c in creatures) {
			if (c != null && !c.exists) {
				creature = c;
				creature.creatureSpawn();
				break;
			}
		}

		// Create new creature if none available
		if (creature == null) {
			if (creatures.length >= 70 && playState.gameOver)
				return null;
			creature = new Creature(_lightsLayer);
			creature.creaturesLayer = this;
			creatures.add(creature);
			add(creature);
			add(creature.getExplosion());
		}

		creature.angle = Math.random() * 360;
		creature.x = SPAWN_AREA.x + Math.random() * (SPAWN_AREA.width - creature.width);
		creature.y = SPAWN_AREA.y + Math.random() * (SPAWN_AREA.height - creature.height);
		return creature;
	}

	public function onCreatureHitCreature(creature1:Creature, creature2:Creature):Void {
		var dead:Creature = null;
		var aliveCreature:Creature = null;

		if (creature1.dying) {
			if (creature2.dying)
				return; // both dead, don't do anything
			dead = creature1;
			aliveCreature = creature2;
		} else if (creature2.dying) {
			dead = creature2;
			aliveCreature = creature1;
		} else {
			return; // both alive, don't do anything
		}

		aliveCreature.killCreature();

		// Give player points for the chained kill
		var playState = Std.downcast(FlxG.state, PlayState);
		if (playState != null) {
			playState.onEvent(PlayState.EVENT_KILL_CHAINED, {killed: aliveCreature, killer: dead});
		}
	}

	override public function update(elapsed:Float):Void {
		var playState = Std.downcast(FlxG.state, PlayState);

		_spawnTimer -= elapsed;
		if (_spawnTimer <= 0) {
			// Time to spawn a new creature
			for (timer in SPAWN_TIMERS) {
				if (PlayState.score >= timer.score) {
					_spawnTimer = timer.interval;
					Creature.BASE_DOWN_SPEED = timer.baseDownSpeed;
					break;
				}
			}
			addCreature();
		}

		super.update(elapsed);
	}
}
