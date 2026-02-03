package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;

class CreatureExplosion extends FlxEmitter {
	public static inline var COLOR:FlxColor = 0xff669933;

	public function new(brightness:Float) {
		super(0, 0, 8);

		// Use interval emission mode (emit one particle every 0.2s) like original
		frequency = 0.2;

		var b:Int = Std.int(255 * brightness);
		var argb:FlxColor = FlxColor.fromRGB(b, b, b);

		// Green particles: [3, 3, 4, 6]
		var greenSizes:Array<Int> = [3, 3, 4, 6];
		for (size in greenSizes) {
			var particle = new FlxParticle();
			particle.makeGraphic(size, size, COLOR);
			add(particle);
		}

		// Gray particles based on brightness: [3, 4, 4, 6]
		var graySizes:Array<Int> = [3, 4, 4, 6];
		for (size in graySizes) {
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
		alpha.set(1.0, 1.0); // No fade - original doesn't fade particles
	}
}
