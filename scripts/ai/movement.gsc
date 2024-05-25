STEP_LENGTH = 16;
STEP_HEIGHT = 19;
MAX_INCLINE = 0.6;

simulateMovement(origin, movement) {
	speed = length(movement);
	normalizedMovement = movement / speed;
	fullSteps = int((speed + 0.0001) / STEP_LENGTH);

	for (i = 0; i < fullSteps; i++) {
		stepOrigin = simulateStep(origin, normalizedMovement, STEP_LENGTH);
		if (stepOrigin == origin) return origin;
		origin = stepOrigin;
	}
	return simulateStep(origin, normalizedMovement, speed - fullSteps * STEP_LENGTH);
}

simulateStep(origin, normalizedMovement, length) {
	targetOrigin = getStepOrigin(origin, normalizedMovement * length, STEP_HEIGHT, 2.0);
	if (origin[2] - targetOrigin[2] > STEP_HEIGHT) return origin; // no falling
	if (abs(getIncline(targetOrigin)) > MAX_INCLINE) return origin; // no steep ledges
	return targetOrigin;
}

getStepOrigin(from, velocity, stepHeight, minStepHeight) {
	// lib\debug::capsule3D((0, 0, 36) + from, 36, 16, (1, 1, 1), 8);
	forward = undefined;
	for (currentHeight = stepHeight; currentHeight >= minStepHeight; currentHeight /= 2) {
		up = playerPhysicsTrace(from, from + (0, 0, currentHeight));
		// lib\debug::capsule3D((0, 0, 36) + up, 36, 16, (0, 0, 1), 8);
		forwardTarget = up + velocity;
		forward = playerPhysicsTrace(up, forwardTarget);
		// lib\debug::capsule3D((0, 0, 36) + forward, 36, 16, (1, 0, 0), 8);
		if (forward == forwardTarget) break;
	}
	ground = playerPhysicsTrace(forward, forward + (0, 0, -4096));
	// lib\debug::capsule3D((0, 0, 36) + ground, 36, 16, (0, 1, 0), 8);
	return ground;
}

getIncline(at) {
	trace = bulletTrace(at, at + (0, 0, -4096), false, undefined);
	if (trace["surfacetype"] == "water") {
		pos = trace["position"];
		trace = bulletTrace(pos + (0, 0, -0.0001), pos + (0, 0, -4096), false, undefined);
	}
	if (trace["fraction"] * 4096 > 64.0) return 0.0;
	return 1.0 - vectorDot(trace["normal"], (0, 0, 1));
}
