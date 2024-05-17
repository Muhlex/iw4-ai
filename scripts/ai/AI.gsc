#include scripts\util;
#include scripts\util\Debug;

CAPSULE_HALF_HEIGHT = 36;
CAPSULE_RADIUS = 16;
MOVE_SPEED = 6;
STEP_HEIGHT = 24;
MAX_INCLINE = 0.8;

AI__New(origin) {
	ai = spawn("script_origin", origin);
	// ai setModel("test_sphere_silver");
	ai thread _AI_Think();
	return ai;
}

AI_Kill() {
	self delete();
}

simulateMovement(from, normalizedMovement, speed, stepHeight) {
	to = from;
	for (currentSpeed = speed; currentSpeed > 0.1; currentSpeed -= speed / 4) {
		targetOrigin = getStepOrigin(from, normalizedMovement * currentSpeed, stepHeight);
		if (from[2] - targetOrigin[2] > stepHeight) continue; // no falling
		stepIncline = getIncline(from, targetOrigin);
		if (abs(stepIncline) > MAX_INCLINE) {
			targetIncline = getIncline(
				targetOrigin,
				getStepOrigin(targetOrigin, normalizedMovement * 4.0, 4.0)
			);
			if (abs(targetIncline) > MAX_INCLINE) continue; // no steep ledges
		}
		to = targetOrigin;
		break;
	}
	return to;
}

getStepOrigin(from, velocity, stepHeight) {
	forward = undefined;
	for (currentHeight = stepHeight; currentHeight > 2.0; currentHeight /= 2) {
		up = playerPhysicsTrace(from, from + (0, 0, currentHeight));
		forwardTarget = up + velocity;
		forward = playerPhysicsTrace(up, forwardTarget);
		if (forward == forwardTarget) break;
	}
	ground = playerPhysicsTrace(forward, forward + (0, 0, -4096));
	return ground;
}

getIncline(from, to) {
	return vectorDot(vectorNormalize(to - from), (0, 0, 1));
}

AI_HandleMovement(movementVec) {
	if (lengthSquared(movementVec) == 0) return;

	self.origin = simulateMovement(self.origin, movementVec, MOVE_SPEED, STEP_HEIGHT);
}

_AI_Think() {
	self endon ("death");

	for (;;) {
		Debug__Text3D(
			self.origin + (0, 0, CAPSULE_HALF_HEIGHT * 2),
			"| AI Actor",
			(0.5, 1, 0.5),
			1,
			0.25
		);
		Debug__Capsule3D(
			self.origin + (0, 0, CAPSULE_HALF_HEIGHT),
			CAPSULE_HALF_HEIGHT,
			CAPSULE_RADIUS,
			(0.5, 1, 0.5)
		);

		wait 0.05;
	}
}
