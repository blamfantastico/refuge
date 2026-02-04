package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.system.Clipboard;
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.geom.Matrix;

class UILayer extends FlxGroup {
	private var _instructionsText:FlxText;
	private var _gameOverLight:Light;
	private var _gameOverText:FlxText;
	private var _scoreText:FlxText;
	private var _shareButton:FlxButton;
	private var _tryAgainButton:FlxButton;
	public var toastText:FlxText;

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

		// Toast text (shown when score is copied) - added to PlayState above lights layer
		toastText = new FlxText(0, 40, FlxG.width, "Score copied to clipboard");
		toastText.setFormat(null, 16, FlxColor.WHITE, CENTER);
		toastText.alpha = 0.0;

		// Share button
		_shareButton = new FlxButton(Std.int(FlxG.width / 2 - 72), yPos, "Share", function() {
			Clipboard.text = "Refuge Score: " + PlayState.score + " 👾";
			// Fade in toast, then fade out after 2 seconds
			toastText.alpha = 0.0;
			FlxTween.tween(toastText, {alpha: 0.75}, 0.5, {
				ease: FlxEase.linear,
				onComplete: function(_) {
					FlxTween.tween(toastText, {alpha: 0.0}, 3.0, {startDelay: 1.5, ease: FlxEase.linear});
				}
			});
		});
		_shareButton.makeGraphic(144, 28, 0x99000000);
		_shareButton.label.setFormat(null, 16, FlxColor.WHITE, CENTER);
		_shareButton.alpha = 0.0;
		_shareButton.visible = false;
		_shareButton.onOver.callback = function() {
			_shareButton.makeGraphic(144, 28, 0x99ffffff);
			_shareButton.label.setFormat(null, 16, FlxColor.BLACK, CENTER);
		};
		_shareButton.onOut.callback = function() {
			_shareButton.makeGraphic(144, 28, 0x99000000);
			_shareButton.label.setFormat(null, 16, FlxColor.WHITE, CENTER);
		};
		add(_shareButton);

		yPos += 40;

		// Try again button
		_tryAgainButton = new FlxButton(Std.int(FlxG.width / 2 - 72), yPos, "Try Again", function() {
			FlxG.resetState();
		});
		_tryAgainButton.makeGraphic(144, 28, 0x99000000);
		_tryAgainButton.label.setFormat(null, 16, FlxColor.WHITE, CENTER);
		_tryAgainButton.alpha = 0.0;
		_tryAgainButton.visible = false;
		_tryAgainButton.onOver.callback = function() {
			_tryAgainButton.makeGraphic(144, 28, 0x99ffffff);
			_tryAgainButton.label.setFormat(null, 16, FlxColor.BLACK, CENTER);
		};
		_tryAgainButton.onOut.callback = function() {
			_tryAgainButton.makeGraphic(144, 28, 0x99000000);
			_tryAgainButton.label.setFormat(null, 16, FlxColor.WHITE, CENTER);
		};
		add(_tryAgainButton);

		// Score text at bottom
		_scoreText = new FlxText(0, Std.int(FlxG.height - 32), FlxG.width, "Score: 0");
		_scoreText.setFormat(null, 16, FlxColor.WHITE, CENTER);
		add(_scoreText);
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
				_shareButton.visible = true;
				_tryAgainButton.visible = true;
				FlxTween.tween(_shareButton, {alpha: 1.0}, 2.0, {ease: FlxEase.linear});
				FlxTween.tween(_tryAgainButton, {alpha: 1.0}, 2.0, {ease: FlxEase.linear});
			}
		});

		_scoreText.visible = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		_scoreText.text = "Score: " + PlayState.score;
	}
}
