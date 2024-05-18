STEP_HEIGHT = 24;
MAX_INCLINE = 0.8;

simulateStep(from, movement) {
	speed = length(movement);
	normalizedMovement = movement / speed;
	to = from;

	for (currentSpeed = speed; currentSpeed > 0.1; currentSpeed -= speed / 4) {
		targetOrigin = getStepOrigin(from, normalizedMovement * currentSpeed, STEP_HEIGHT);
		if (from[2] - targetOrigin[2] > STEP_HEIGHT) continue; // no falling
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
