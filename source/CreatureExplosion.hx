package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;

class CreatureExplosion extends FlxEmitter {
	public static inline var COLOR:FlxColor = 0xff669933;

	public var explosionDelay:Float = 0.2;

	public function new(brightness:Float) {
		super(0, 0, 8);

		var b:Int = Std.int(255 * brightness);
		var argb:FlxColor = FlxColor.fromRGB(b, b, b);

		// Green particles
		for (i in 0...4) {
			var size:Int = (i < 2) ? 3 : ((i < 3) ? 4 : 6);
			var particle = new FlxParticle();
			particle.makeGraphic(size, size, COLOR);
			add(particle);
		}

		// Gray particles based on brightness
		for (i in 0...4) {
			var size:Int = (i < 1) ? 3 : ((i < 3) ? 4 : 6);
			var particle = new FlxParticle();
			particle.makeGraphic(size, size, argb);
			add(particle);
		}

		// Configure emitter properties
		launchMode = FlxEmitterMode.SQUARE;
		velocity.set(-10, 0, 10, 50);
		angularVelocity.set(-720, 720);
		acceleration.set(0, 20);
		lifespan.set(0.5, 1.0);
	}
}
