package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;

class BulletExplosion extends FlxEmitter {
	public function new() {
		super(0, 0, 6);

		var sizes:Array<Int> = [1, 1, 2, 2, 3, 3];
		for (size in sizes) {
			var particle = new FlxParticle();
			particle.makeGraphic(size, size, Bullet.COLOR);
			add(particle);
		}

		// Configure emitter properties
		launchMode = FlxEmitterMode.SQUARE;
		velocity.set(-20, -100, 20, 0);
		angularVelocity.set(-720, 720);
		acceleration.set(0, 400);
		lifespan.set(0.5, 1.0);
	}
}
