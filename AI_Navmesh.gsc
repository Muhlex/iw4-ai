#include lib;

// GSC function stack size (for a recursive algorithm) is 32...

PLAYER_CAPSULE_HEIGHT = 72;
RESOLUTION = 96;

SQRT_OF_TWO = 1.4143;
MIN_DISTANCE = RESOLUTION / 2 * SQRT_OF_TWO;
MAX_DISTANCE = RESOLUTION * 2 - 1;

New() {
	mesh = spawnStruct();
	mesh._edges = List::New();
	mesh._chunks = Map::New();
	mesh.length = 0;
	return mesh;
}

generate(startOrigins) {
	iPrintLnBold("Generating navmesh... (previous waypoint count: ", self.length, ")");

	resolutionSq = squared(RESOLUTION);
	minDistHorizSq = squared(MIN_DISTANCE);
	maxDistHorizSq = squared(MAX_DISTANCE);
	maxDistVert = PLAYER_CAPSULE_HEIGHT;
	queue = Queue::New();

	printLn("in generate");
	foreach (origin in startOrigins) {
		groundedOrigin = playerPhysicsTrace(origin, origin + (0, 0, -4096));
		queue Queue::enqueue(groundedOrigin);
	}

	while (queue Queue::size() > 0) {
		origin = queue Queue::dequeue();
		waypoint = AI_Waypoint::New(self.length, origin);
		valid = self AI_Navmesh::_addWaypoint(waypoint, minDistHorizSq, maxDistHorizSq, maxDistVert);
		if (!valid) continue;

		for (angle = 0; angle < 360; angle += 90) {
			movement = anglesToForward((0, angle, 0)) * RESOLUTION;
			movedOrigin = scripts\ai\movement::simulateStep(waypoint.origin, movement);

			// if (distanceSquared(waypoint.origin, movedOrigin) < minDistHorizSq) continue; // opt, only do it horiz?

			queue Queue::enqueue(movedOrigin);
		}

		if (getDvarInt("ai_navmesh_debug") != 0) wait 0.05;
	}
}

draw() {
	foreach (edge in self._edges.array) {
		lib\debug::line3D(edge[0].origin, edge[1].origin, (0, 0.85, 1.0));
	}
}

_addWaypoint(newWaypoint, minDistHorizSq, maxDistHorizSq, maxDistVert) {
	waypointsInRange = List::New();
	searchWaypoints = self AI_Navmesh::_getSearchWaypoints(newWaypoint.origin);
	// iPrintLn("Checking ", searchWaypoints List::size(), " waypoints while total is ", self.length, ".");

	// Check validity:
	foreach (waypoint in searchWaypoints.array) {
		distanceVert = abs(waypoint.origin[2] - newWaypoint.origin[2]);
		if (distanceVert > maxDistVert) continue;
		distanceHorizSq = distanceSquared(
			(waypoint.origin[0], waypoint.origin[1], 0),
			(newWaypoint.origin[0], newWaypoint.origin[1], 0)
		);
		if (distanceHorizSq > maxDistHorizSq) continue;
		if (distanceHorizSq < minDistHorizSq) return false;
		waypointsInRange List::push(waypoint);
	}

	// Add to navmesh:
	self.length++;
	self AI_Navmesh::_getChunk(newWaypoint.origin) List::push(newWaypoint);

	debug = getDvarInt("ai_navmesh_debug") != 0;

	// Connect to reachable waypoints:
	foreach (waypoint in waypointsInRange.array) {
		delta = waypoint.origin - newWaypoint.origin;
		connectOrigin = scripts\ai\movement::simulateStep(newWaypoint.origin, delta);
		if (distanceSquared(waypoint.origin, connectOrigin) > 1.0) {
			if (debug) lib\debug::line3D(newWaypoint.origin, connectOrigin, (1.0, 0.2, 0.2), 16);
			continue;
		};

		edge = [];
		edge[0] = waypoint;
		edge[1] = newWaypoint;
		self._edges List::push(edge);

		newWaypoint AI_Waypoint::addChild(waypoint);
		waypoint AI_Waypoint::addChild(newWaypoint);
		if (debug) lib\debug::line3D(newWaypoint.origin, waypoint.origin, (0.2, 1.0, 0.2), 16);
	}

	return true;
}

_getChunk(origin) {
	hash = __getChunkHash(__getChunkCoords(origin));
	if (!self._chunks Map::has(hash)) {
		chunk = List::New();
		self._chunks Map::set(hash, chunk);
		return chunk;
	}
	return self._chunks Map::get(hash);
}

_getSearchWaypoints(origin) {
	centerCoords = __getChunkCoords(origin);
	waypoints = List::New();
	for (y =-1; y <= 1; y++) {
		for (x =-1; x <= 1; x++) {
			coords = (centerCoords[0] + x, centerCoords[1] + y, 0);
			hash = __getChunkHash(coords);
			chunk = self._chunks Map::get(hash);
			if (!isDefined(chunk)) continue;
			waypoints List::append(chunk);
		}
	}
	return waypoints;
}

__getChunkCoords(origin) {
	chunkSize = MAX_DISTANCE;
	return (int(origin[0] / chunkSize), int(origin[1] / chunkSize), 0);
}

__getChunkHash(coords) {
	return coords[0] + " " + coords[1];
}
