package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;

class BulletExplosion extends FlxEmitter {
	public static inline var MIN_PARTICLES:Int = 4;
	public static inline var MAX_PARTICLES:Int = 8;

	public function new() {
		super(0, 0, MAX_PARTICLES);

		// Emission area
		width = 8;
		height = 8;

		// Create particle pool with varying sizes (1x1, 2x2, 3x3)
		for (i in 0...MAX_PARTICLES) {
			var size = (i % 3) + 1;
			var particle = new FlxParticle();
			particle.makeGraphic(size, size, Bullet.COLOR);
			add(particle);
		}

		// Configure emitter properties
		launchMode = FlxEmitterMode.SQUARE;
		velocity.set(-20, -100, 20, 0);
		angularVelocity.set(-720, 720);
		acceleration.set(0, 400);
		lifespan.set(1.5, 1.5); // Original delay=-1.5 means particles live 1.5s
		alpha.set(1.0, 1.0); // No fade - original doesn't fade particles
	}

	/**
	 * Set directional bias for velocity based on hit position and bullet direction.
	 * @param biasX Range -1 (spray left) to +1 (spray right)
	 * @param biasY Range -1 (spray up) to +1 (spray down)
	 */
	public function setDirectionalBias(biasX:Float, biasY:Float):Void {
		var shiftX = biasX * 50;
		var shiftY = biasY * 25; // Y shift is smaller since base range is -100 to 0
		// Base: minX=-20, maxX=20, minY=-100, maxY=0
		velocity.set(-20 + shiftX, -100 + shiftY, 20 + shiftX, 0 + shiftY);
	}

	public function resetVelocity():Void {
		velocity.set(-20, -100, 20, 0);
	}
}
