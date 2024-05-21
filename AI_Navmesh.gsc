#include lib;

// GSC function stack size (for a recursive algorithm) is 32...

PLAYER_CAPSULE_HEIGHT = 72;
RESOLUTION = 96;

SQRT_OF_TWO = 1.4143;
MIN_WAYPOINT_DISTANCE = RESOLUTION / 2 * SQRT_OF_TWO;
MAX_CONNECT_DISTANCE = RESOLUTION + MIN_WAYPOINT_DISTANCE;

New() {
	mesh = spawnStruct();
	mesh._waypoints = List::New();
	mesh._chunks = Map::New();
	mesh.length = 0;
	return mesh;
}

getWaypoint(index) {
	return self._waypoints List::at(index);
}

generate(startOrigins) {
	resolutionSq = squared(RESOLUTION);
	minWaypointDistSq = squared(MIN_WAYPOINT_DISTANCE);
	maxConnectDistSq = squared(MAX_CONNECT_DISTANCE);
	queue = Queue::New();

	foreach (origin in startOrigins) {
		groundedOrigin = playerPhysicsTrace(origin, origin + (0, 0, -4096));
		queue Queue::enqueue(groundedOrigin);
	}

	iterations = 0;
	previousLength = self.length;

	while (queue Queue::size() > 0) {
		origin = queue Queue::dequeue();
		waypoint = AI_Waypoint::New(self.length, origin);
		success = self AI_Navmesh::_tryAddWaypoint(waypoint, minWaypointDistSq, maxConnectDistSq);
		if (!success) continue;

		for (angle = 0; angle < 360; angle += 90) {
			movement = anglesToForward((0, angle, 0)) * RESOLUTION;
			movedOrigin = scripts\ai\movement::simulateMovement(origin, movement);

			if (distanceSquared(origin, movedOrigin) < minWaypointDistSq) continue; // optimization

			queue Queue::enqueue(movedOrigin);
		}

		iterations++;
		if (getDvarInt("ai_navmesh_debug") != 0 && iterations % 16 == 0) wait 0.05;
	}

	iPrintLnBold("Generated ", self.length - previousLength, " nodes.");
}

findPath(start, goal) {
	openSet = Set::New();
	openSet Set::add(start.index);

	gScores = Map::New();
	gScores Map::set(start.index, 0);

	fScores = Map::New();
	fScores Map::set(start.index, distance(start.origin, goal.origin));

	parents = Map::New();

	while (openSet Set::size() > 0) {
		// This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
		// TODO: Different data structure than Set?
		currentIndex = undefined;
		lowestFScore = undefined;
		foreach (index in openSet.array) {
			fScore = fScores Map::get(index);
			if (isDefined(lowestFScore) && fScore >= lowestFScore) continue;

			currentIndex = index;
			lowestFScore = fScore;
		}

		current = self AI_Navmesh::getWaypoint(currentIndex);

		if (current == goal) {
			path = List::New();
			while (isDefined(current)) {
				path List::push(current);
				current = parents Map::get(current.index);
			}
			return path;
		}

		openSet Set::remove(current.index);
		foreach (child in current.children.array) {
			childDist = distance(current.origin, child.origin);
			childGScore = gScores Map::get(child.index);
			tentativeGScore = gScores Map::get(current.index) + childDist;
			if (isDefined(childGScore) && tentativeGScore >= childGScore) continue;

			parents Map::set(child.index, current);
			gScores Map::set(child.index, tentativeGScore);
			fScores Map::set(child.index, tentativeGScore + distance(child.origin, goal.origin));
			openSet Set::add(child.index);
		}
	}

	return undefined;
}

draw(origin, chunkRange) {
	waypoints = self _getChunkWaypoints(origin, chunkRange);
	drawnWaypointIndices = Set::New();

	foreach (waypoint in waypoints.array) {
		if (waypoint.children List::size() == 0)
			lib\debug::line3D(waypoint.origin, waypoint.origin + (0, 0, 8), (1, 1, 1));

		foreach (childIndex in waypoint.children Map::keys().array) {
			if (drawnWaypointIndices Set::has(childIndex)) continue;
			childWaypoint = waypoint.children Map::get(childIndex);
			lib\debug::line3D(waypoint.origin, childWaypoint.origin, (0, 0.85, 1));
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
	self.length++;
	self._waypoints List::push(newWaypoint);
	self AI_Navmesh::_getChunk(newWaypoint.origin) List::push(newWaypoint);

	debug = getDvarInt("ai_navmesh_debug") != 0;

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
	hash = __getChunkHash(__getChunkCoords(origin));
	if (!self._chunks Map::has(hash)) {
		chunk = List::New();
		self._chunks Map::set(hash, chunk);
		return chunk;
	}
	return self._chunks Map::get(hash);
}

_getChunkWaypoints(origin, forwardChunks) {
	centerCoords = __getChunkCoords(origin);
	waypoints = List::New();
	for (y = forwardChunks * -1; y <= forwardChunks; y++) {
		for (x = forwardChunks * -1; x <= forwardChunks; x++) {
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
	chunkSize = MAX_CONNECT_DISTANCE;
	return (int(origin[0] / chunkSize), int(origin[1] / chunkSize), 0);
}

__getChunkHash(coords) {
	return coords[0] + " " + coords[1];
}
