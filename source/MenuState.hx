package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import menu.MenuCreaturesLayer;
import menu.SmokeLayer;
import openfl.geom.Rectangle;

class MenuState extends FlxState {
	private var _blocks:FlxGroup;
	private var _smokeLayer:SmokeLayer;
	private var _creaturesLayer:MenuCreaturesLayer;
	private var _scrollY:Float = 0;

	override public function create():Void {
		super.create();

		// Black background
		var bg = new FlxSprite(0, 0);
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		_smokeLayer = new SmokeLayer();
		add(_smokeLayer);

		_creaturesLayer = new MenuCreaturesLayer();
		add(_creaturesLayer);

		// Buildings (cityscape images)
		var cityscapeLeft = new FlxSprite(0, FlxG.height - 256);
		cityscapeLeft.loadGraphic("images/cityscape_left.png");
		add(cityscapeLeft);

		var cityscapeRight = new FlxSprite(FlxG.width - 200, FlxG.height - 256);
		cityscapeRight.loadGraphic("images/cityscape_right.png");
		add(cityscapeRight);

		// Caverns (black blocks)
		_blocks = new FlxGroup();
		_blocks.add(createBlock(0, FlxG.height - 128, 216, 384));
		_blocks.add(createBlock(216, FlxG.height - 96, 8, 384));
		_blocks.add(createBlock(FlxG.width - 200 - 16, FlxG.height - 64, 8, 384));
		_blocks.add(createBlock(FlxG.width - 200 - 8, FlxG.height - 120, 200, 384));
		_blocks.add(createBlock(FlxG.width - 200, FlxG.height - 128, 200, 384));
		add(_blocks);

		// Title
		var titleText = new FlxText(0, 64, FlxG.width, "REFUGE");
		titleText.setFormat(null, 96, FlxColor.BLACK, CENTER);
		add(titleText);

		// Start button
		var startButton = new FlxButton(Std.int(FlxG.width / 2 - 72), Std.int(FlxG.height - 256), "Click to Play", function() {
			FlxTween.tween(this, {_scrollY: -640}, 1.0, {
				ease: FlxEase.quadIn,
				onComplete: function(_) {
					FlxG.switchState(PlayState.new);
				}
			});
		});
		startButton.makeGraphic(144, 32, FlxColor.BLACK);
		startButton.label.setFormat(null, 16, 0x15190f, CENTER);
		startButton.alpha = 0.0;
		add(startButton);

		FlxTween.tween(startButton, {alpha: 1}, 0.2, {startDelay: 1.0, ease: FlxEase.linear});
	}

	private function createBlock(x:Float, y:Float, w:Float, h:Float):FlxSprite {
		var block = new FlxSprite(x, y);
		block.makeGraphic(Std.int(w), Std.int(h), FlxColor.BLACK);
		return block;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.camera.scroll.y = _scrollY;
	}
}
