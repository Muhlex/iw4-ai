#include lib;

PLAYER_CAPSULE_HALF_HEIGHT = 36;
PLAYER_CAPSULE_RADIUS = 16;
MOVE_SPEED = 6;

Spawn(origin) {
	ai = spawn("script_origin", origin);
	// ai setModel("test_sphere_silver");
	ai thread _think();
	return ai;
}

kill() {
	self delete();
}

handleMovement(movementVec) {
	if (lengthSquared(movementVec) == 0) return;

	self.origin = scripts\ai\movement::simulateStep(self.origin, movementVec * MOVE_SPEED);
}

_think() {
	self endon ("death");

	for (;;) {
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
