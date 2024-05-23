#include lib;

PLAYER_CAPSULE_HALF_HEIGHT = 36;
PLAYER_CAPSULE_RADIUS = 16;
MOVE_SPEED = 6;

Spawn(origin) {
	ai = spawn("script_origin", origin);
	ai setModel("test_sphere_silver");
	ai.velocity = (0, 0, 0);
	ai._currentTarget = undefined;
	ai._targets = Queue::New();

	ai thread _think();
	return ai;
}

kill() {
	self delete();
}

addTarget(origin) {
	self._targets Queue::enqueue(origin);
}

clearTargets() {
	self._targets Queue::clear();
}

_think() {
	self endon ("death");

	for (;;) {
		if (!isDefined(self._currentTarget) && self._targets Queue::size() > 0) {
			self._currentTarget = self._targets Queue::dequeue();
		}

		if (isDefined(self._currentTarget)) {
			delta = self._currentTarget - self.origin;
			length = length(delta);
			movement = undefined;
			if (length < MOVE_SPEED) {
				movement = delta;
				self._currentTarget = undefined;
			} else {
				movement = delta / length * MOVE_SPEED;
			}
			self.velocity += movement;
		}

		self.origin = scripts\ai\movement::simulateMovement(self.origin, self.velocity);
		self.velocity *= 0;

		lib\debug::text3D(
			self.origin + (0, 0, PLAYER_CAPSULE_HALF_HEIGHT * 2),
			"| AI Actor",
			(0.5, 1, 0.5),
			1,
			0.25
		);
		lib\debug::capsule3D(
			self.origin + (0, 0, PLAYER_CAPSULE_HALF_HEIGHT),
			PLAYER_CAPSULE_HALF_HEIGHT,
			PLAYER_CAPSULE_RADIUS,
			(0.5, 1, 0.5)
		);

		wait 0.05;
	}
}
