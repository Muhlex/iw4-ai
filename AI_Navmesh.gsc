// GSC function stack size (for a recursive algorithm) is 32...

PLAYER_CAPSULE_HEIGHT = 72;
RESOLUTION = 96;

SQRT_OF_TWO = 1.4143;
MIN_WAYPOINT_DISTANCE = RESOLUTION / 2 * SQRT_OF_TWO;
MAX_CONNECT_DISTANCE = RESOLUTION + MIN_WAYPOINT_DISTANCE;

New() {
	navmesh = spawnStruct();
	navmesh._waypoints = List::New();
	navmesh._chunks = Map::New();
	navmesh.pathfinder = AI_Pathfinder::New(navmesh);
	return navmesh;
}

getWaypoint(index) {
	return self._waypoints List::at(index);
}

generate(startOrigins) {
	startTime = getSystemMilliseconds();
	lib\perf::start("generate");

	resolutionSq = squared(RESOLUTION);
	minWaypointDistSq = squared(MIN_WAYPOINT_DISTANCE);
	maxConnectDistSq = squared(MAX_CONNECT_DISTANCE);
	queue = Queue::New();

	foreach (origin in startOrigins) {
		groundedOrigin = playerPhysicsTrace(origin, origin + (0, 0, -4096));
		queue Queue::enqueue(groundedOrigin);
	}

	iterations = 0;
	previousLength = self._waypoints List::size();

	while (queue Queue::size() > 0) {
		origin = queue Queue::dequeue();
		waypoint = AI_Waypoint::New(self._waypoints List::size(), origin);
		success = self AI_Navmesh::_tryAddWaypoint(waypoint, minWaypointDistSq, maxConnectDistSq);
		if (!success) continue;

		for (angle = 0; angle < 360; angle += 90) {
			movement = anglesToForward((0, angle, 0)) * RESOLUTION;
			movedOrigin = scripts\ai\movement::simulateMovement(origin, movement);

			if (distanceSquared(origin, movedOrigin) < minWaypointDistSq) continue; // optimization

			queue Queue::enqueue(movedOrigin);
		}

		iterations++;
		if (getDvarInt("ai_navmesh_debug") != 0 && iterations % 64 == 0) wait 0.05;
	}

	iPrintLnBold("Generated ", self._waypoints List::size() - previousLength, " nodes.");
	iPrintLn("Navmesh generation took ^3", lib\perf::end("generate"), " ms^7.");
}

size() {
	return self._waypoints List::size();
}

draw(origin, chunkRange) {
	waypoints = self _getChunkWaypoints(origin, chunkRange);
	waypointsText = self _getChunkWaypoints(origin, int(chunkRange / 2));

	foreach (waypoint in waypointsText.array) {
		lib\debug::text3D(waypoint.origin + (0, 0, 2), waypoint.index, (0.2, 0.9, 1), 1, 0.75);
	}

	drawnWaypointIndices = Set::New();
	foreach (waypoint in waypoints.array) {
		foreach (child in waypoint.children.array) {
			if (drawnWaypointIndices Set::has(child.index)) continue;
			lib\debug::line3D(waypoint.origin, child.origin, (0, 0.85, 1));
		}

		drawnWaypointIndices Set::add(waypoint.index);
	}
}

_tryAddWaypoint(newWaypoint, minWaypointDistSq, maxConnectDistSq) {
	waypointsInRange = List::New();
	searchWaypoints = self AI_Navmesh::_getChunkWaypoints(newWaypoint.origin, 1);

	// Check validity:
	foreach (waypoint in searchWaypoints.array) {
		distanceHorizSq = distanceSquared(waypoint.origin, newWaypoint.origin);
		if (distanceHorizSq > maxConnectDistSq) continue;
		if (distanceHorizSq < minWaypointDistSq) return false;
		waypointsInRange List::push(waypoint);
	}

	// Add to navmesh:
	self._waypoints List::push(newWaypoint);
	self AI_Navmesh::_getChunk(newWaypoint.origin) List::push(newWaypoint);

	debug = getDvarInt("ai_navmesh_debug") != 0;
	debug = false;

	// Connect to reachable waypoints:
	foreach (waypoint in waypointsInRange.array) {
		delta = waypoint.origin - newWaypoint.origin;
		connectOrigin = scripts\ai\movement::simulateMovement(newWaypoint.origin, delta);
		if (distanceSquared(waypoint.origin, connectOrigin) > 1.0) {
			if (debug) lib\debug::line3D(newWaypoint.origin, connectOrigin, (1.0, 0.2, 0.2), 2);
			continue;
		};

		newWaypoint AI_Waypoint::addChild(waypoint);
		waypoint AI_Waypoint::addChild(newWaypoint);
		if (debug) lib\debug::line3D(newWaypoint.origin, waypoint.origin, (0.2, 1.0, 0.2), 2);
	}

	return true;
}

_getChunk(origin) {
	hash = _GetChunkHash(_GetChunkCoords(origin));
	if (!self._chunks Map::has(hash)) {
		chunk = List::New();
		self._chunks Map::set(hash, chunk);
		return chunk;
	}
	return self._chunks Map::get(hash);
}

_getChunkWaypoints(origin, forwardChunks) {
	centerCoords = _GetChunkCoords(origin);
	waypoints = List::New();
	for (y = forwardChunks * -1; y <= forwardChunks; y++) {
		for (x = forwardChunks * -1; x <= forwardChunks; x++) {
			coords = (centerCoords[0] + x, centerCoords[1] + y, 0);
			hash = _GetChunkHash(coords);
			chunk = self._chunks Map::get(hash);
			if (!isDefined(chunk)) continue;
			waypoints List::append(chunk);
		}
	}
	return waypoints;
}

_GetChunkCoords(origin) {
	chunkSize = MAX_CONNECT_DISTANCE;
	return (int(origin[0] / chunkSize), int(origin[1] / chunkSize), 0);
}

_GetChunkHash(coords) {
	return coords[0] + " " + coords[1];
}
