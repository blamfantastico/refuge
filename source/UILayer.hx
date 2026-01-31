package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.geom.Matrix;

class UILayer extends FlxGroup {
	private var _instructionsText:FlxText;
	private var _gameOverLight:Light;
	private var _gameOverText:FlxText;
	private var _scoreText:FlxText;
	private var _submitScoreButton:FlxButton;
	private var _tryAgainButton:FlxButton;
	private var _debugText:FlxText;

	public function new(lightsLayer:LightsLayer) {
		super();

		// Create game over light with gradient shape
		var matrix = new Matrix();
		matrix.createGradientBox(300, 300, 0, -150, -150);
		var lightShape = new Shape();
		lightShape.graphics.beginGradientFill(GradientType.RADIAL, [0x000000, 0x0000ff], [1.0, 1.0], [100, 255], matrix);
		lightShape.graphics.drawCircle(0, 0, 200);
		lightShape.graphics.endFill();
		_gameOverLight = new Light(FlxG.width / 2, FlxG.height / 2, 1.0, 1.0, 0, lightShape);
		_gameOverLight.kill();
		lightsLayer.add(_gameOverLight);

		var yPos:Int = Std.int(FlxG.height / 2 - 80);

		// Instructions text
		_instructionsText = new FlxText(0, yPos, FlxG.width, "arrows to aim\nx or c to shoot");
		_instructionsText.setFormat(null, 16, FlxColor.WHITE, CENTER);
		_instructionsText.alpha = 0.2;
		add(_instructionsText);

		FlxTween.tween(_instructionsText, {alpha: 0}, 1.0, {
			startDelay: 5.0,
			ease: FlxEase.linear,
			onComplete: function(_) {
				_instructionsText.visible = false;
			}
		});

		// Game over text
		_gameOverText = new FlxText(0, yPos, FlxG.width, "GAME OVER\nScore: 0");
		_gameOverText.setFormat(null, 32, FlxColor.WHITE, CENTER);
		_gameOverText.alpha = 0.0;
		_gameOverText.visible = false;
		add(_gameOverText);

		yPos += 96;

		// Try again button (removed Mochi leaderboard, using local restart)
		_tryAgainButton = new FlxButton(Std.int(FlxG.width / 2 - 72), yPos, "Try Again", function() {
			FlxG.resetState();
		});
		_tryAgainButton.makeGraphic(144, 28, 0x99000000);
		_tryAgainButton.label.setFormat(null, 16, FlxColor.WHITE, CENTER);
		_tryAgainButton.alpha = 0.0;
		_tryAgainButton.visible = false;
		add(_tryAgainButton);

		// Score text at bottom
		_scoreText = new FlxText(0, Std.int(FlxG.height - 32), FlxG.width, "Score: 0");
		_scoreText.setFormat(null, 16, FlxColor.WHITE, CENTER);
		add(_scoreText);

		// Debug creature count in top right
		_debugText = new FlxText(FlxG.width - 120, 8, 120, "Creatures: 0");
		_debugText.setFormat(null, 12, FlxColor.WHITE, RIGHT);
		_debugText.scrollFactor.set(0, 0);
		add(_debugText);
	}

	public function onGameOver():Void {
		_gameOverLight.spawn();
		_gameOverLight.alpha = 0.0;
		FlxTween.tween(_gameOverLight, {alpha: 1}, 5.0, {ease: FlxEase.linear});

		_gameOverText.visible = true;
		_gameOverText.text = "GAME OVER\nScore: " + PlayState.score;
		FlxTween.tween(_gameOverText, {alpha: 1}, 5.0, {
			ease: FlxEase.linear,
			onComplete: function(_) {
				_tryAgainButton.visible = true;
				FlxTween.tween(_tryAgainButton, {alpha: 1.0}, 2.0, {ease: FlxEase.linear});
			}
		});

		_scoreText.visible = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		_scoreText.text = "Score: " + PlayState.score;

		// Update debug creature count
		var playState = Std.downcast(FlxG.state, PlayState);
		if (playState != null && playState.creaturesLayer != null) {
			var count = 0;
			for (c in playState.creaturesLayer.creatures) {
				if (c != null && c.exists && c.alive)
					count++;
			}
			_debugText.text = "Creatures: " + count;
		}
	}
}
