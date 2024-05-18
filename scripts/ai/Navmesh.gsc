#include lib;

// GSC function stack size (for a recursive algorithm) is 32...

RESOLUTION = 128;
MIN_DISTANCE = 48;

vectorToKey(vector) {
	return vector[0] + " " + vector[1] + " " + vector[2];
}

Navmesh_New(startOrigin) {
	directions = [];
	directions[0] = (1, 0, 0);
	directions[1] = (0, 1, 0);
	directions[2] = (-1, 0, 0);
	directions[3] = (0, -1, 0);

	queue = [];
	visited = [];
	queue[queue.size] = startOrigin;
	visited[vectorToKey(startOrigin)] = true;

	while (queue.size > 0) {
		origin = queue[queue.size - 1];
		queue[queue.size - 1] = undefined;

		lib\debug::line3D(origin, origin + (0, 0, 16), (1, 1, 1), 16);

		for (i = 0; i < 4; i++) {
			movement = directions[i] * RESOLUTION;
			moveOrigin = scripts\ai\AI::simulateMovement(origin, movement);
			distSqHoriz = distanceSquared((origin[0], origin[1], 0), (moveOrigin[0], moveOrigin[1], 0));

			if (distSqHoriz < squared(MIN_DISTANCE)) continue;
			lib\debug::line3D(origin, moveOrigin, (randomFloat(1), randomFloat(1), randomFloat(1)), 16);

			if (isDefined(visited[vectorToKey(moveOrigin)])) continue;
			queue[queue.size] = moveOrigin;
			visited[vectorToKey(moveOrigin)] = true;
		}
	}
}
