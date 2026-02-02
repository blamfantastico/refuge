package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

class PlayState extends FlxState {
	public static inline var EVENT_DEAD:String = "dead";
	public static inline var EVENT_KILL:String = "kill";
	public static inline var EVENT_KILL_CHAINED:String = "kill_chained";
	public static inline var SCORE_CREATURE:Int = 100;
	public static inline var SCORE_MED_SHOT_MULTIPLIER:Int = 2;
	public static inline var SCORE_LONG_SHOT_MULTIPLIER:Int = 4;
	public static inline var SCORE_BOUNCE_MULTIPLIER:Int = 2;

	public static var score:Int = 0;

	public var blocksLayer:BlocksLayer;
	public var buildingsLayer:BuildingsLayer;
	public var creaturesLayer:CreaturesLayer;
	public var gameOver:Bool = false;
	public var lightsLayer:LightsLayer;
	public var player:Player;
	public var playerLayer:FlxGroup;
	public var uiLayer:UILayer;

	private var _scrollY:Float = -640;

	override public function create():Void {
		super.create();

		// Set background color
		FlxG.cameras.bgColor = 0xff111111;

		// Expand world bounds to include spawn area above screen
		FlxG.worldBounds.set(-100, -700, 700, 1400);

		// Reset score when starting new game
		PlayState.score = 0;

		// Start with camera scrolled up (game below), then tween down to show game
		_scrollY = -640;
		FlxTween.tween(this, {_scrollY: 0}, 1.0, {startDelay: 1.0, ease: FlxEase.quadOut});

		lightsLayer = new LightsLayer(1.0 / 3.0, 0.8);
		blocksLayer = new BlocksLayer();
		buildingsLayer = new BuildingsLayer();
		creaturesLayer = new CreaturesLayer(lightsLayer);
		playerLayer = new FlxGroup();
		uiLayer = new UILayer(lightsLayer);

		player = new Player(playerLayer, lightsLayer);
		player.angle = 270;
		player.x = FlxG.width / 2 - player.width / 2;
		player.y = 495;
		playerLayer.add(player);

		add(creaturesLayer);
		add(playerLayer);
		add(buildingsLayer);
		add(blocksLayer);
		add(uiLayer);
		add(lightsLayer);

		// Add a black block above to hide creatures spawning
		add(new Block(0, -1280, 480, 1280, 0xff000000));
	}

	public function onEvent(event:String, args:Dynamic):Void {
		if (gameOver)
			return;

		var multiplier:Int = 0;
		var score:Int = 0;
		var scoreText:String = "";

		switch (event) {
			case EVENT_DEAD:
			// Nothing to do
			case EVENT_KILL:
				score = SCORE_CREATURE;
				multiplier = 1;
				var bullet:Bullet = args.bullet;
				var killed:Creature = args.killed;

				if (bullet.lifeTime > 4) {
					multiplier += SCORE_LONG_SHOT_MULTIPLIER;
					scoreText += " LONG";
				} else if (bullet.lifeTime > 2) {
					multiplier += SCORE_MED_SHOT_MULTIPLIER;
					scoreText += " MED";
				}
				if (bullet.bounces > 0) {
					multiplier += SCORE_BOUNCE_MULTIPLIER * bullet.bounces;
					if (scoreText.length == 0)
						scoreText += " BOUNCE";
				}
				score *= multiplier;
				killed.chain = {
					bounces: bullet.bounces,
					count: 1,
					refCount: 1,
					totalScore: score
				};
				scoreText = Std.string(score) + scoreText;

			case EVENT_KILL_CHAINED:
				var killed:Creature = args.killed;
				var killer:Creature = args.killer;
				var chain:Dynamic = killed.chain = killer.chain;
				chain.count++;
				score = Std.int(SCORE_CREATURE * (Math.min(chain.count, 6) + SCORE_BOUNCE_MULTIPLIER * chain.bounces));
				chain.totalScore += score;
				scoreText = Std.string(score) + " CHAIN";
		}

		if (args.killed != null) {
			var killed:Creature = args.killed;
			killed.setText(scoreText);
		}
		PlayState.score += score;
	}

	public function onGameOver():Void {
		gameOver = true;
		player.onGameOver();
		uiLayer.onGameOver();
		FlxTween.tween(lightsLayer, {layerAlpha: 1.0}, 2.0, {ease: FlxEase.linear});
	}

	override public function update(elapsed:Float):Void {
		// Apply scroll
		FlxG.camera.scroll.y = _scrollY;

		super.update(elapsed);

		// Update bullet collisions
		player.updateBullets(blocksLayer, creaturesLayer);

		// Creature collisions with blocks
		FlxG.collide(creaturesLayer.creatures, blocksLayer.blocks, function(c:FlxObject, block:FlxObject) {
			var creature = cast(c, Creature);
			if (creature.touching.has(FlxDirectionFlags.FLOOR)) {
				creature.hitFloorCreature();
			} else if (creature.touching.has(FlxDirectionFlags.LEFT) || creature.touching.has(FlxDirectionFlags.RIGHT)) {
				creature.hitWallCreature(creature.touching.has(FlxDirectionFlags.RIGHT));
			}
		});

		// Creature-creature collisions
		FlxG.overlap(creaturesLayer.creatures, creaturesLayer.creatures, function(c1:FlxObject, c2:FlxObject) {
			var creature1 = cast(c1, Creature);
			var creature2 = cast(c2, Creature);
			if (creature1 != creature2) {
				creaturesLayer.onCreatureHitCreature(creature1, creature2);
			}
		});

		// Check for game over
		if (!gameOver && buildingsLayer.buildingsAreAllDead()) {
			onGameOver();
		}
	}
}
