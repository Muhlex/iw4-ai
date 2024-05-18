#include lib;

// GSC function stack size (for a recursive algorithm) is 32...

PLAYER_CAPSULE_HEIGHT = 72;
RESOLUTION = 128;
MIN_DISTANCE = 80;

// _vectorToKey(vector) { // hashVector for quicker search?
// 	return vector[0] + " " + vector[1] + " " + vector[2];
// }

Generate(startOrigin) {
	iPrintLnBold("Generating Navmesh...");

	resolutionSq = squared(RESOLUTION);
	minDistanceSq = squared(MIN_DISTANCE);
	connectDistanceHorizSq = squared(int(RESOLUTION * sqrt(2)) + 1);

	groundedStartOrigin = playerPhysicsTrace(startOrigin, startOrigin + (0, 0, -4096));
	startWaypoint = scripts\ai\Waypoint::New(0, groundedStartOrigin);
	mesh = spawnStruct();
	mesh.waypoints = [];
	mesh.waypoints[0] = startWaypoint;
	queue = [];
	queue[0] = startWaypoint;

	while (queue.size > 0) {
		queuedWaypoint = queue[queue.size - 1];
		queue[queue.size - 1] = undefined;

		lib\debug::line3D(queuedWaypoint.origin, queuedWaypoint.origin + (0, 0, 16), (1, 1, 1), 16);

		for (angle = 0; angle < 360; angle += 90) {
			movement = anglesToForward((0, angle, 0)) * RESOLUTION;
			movedOrigin = scripts\ai\movement::simulateStep(queuedWaypoint.origin, movement);

			if (distanceSquared(queuedWaypoint.origin, movedOrigin) < minDistanceSq) continue; // opt

			newWaypoint = scripts\ai\Waypoint::New(mesh.waypoints.size, movedOrigin);
			invalidStep = false;
			connectableWaypoints = [];

			foreach (waypoint in mesh.waypoints) {
				distanceVert = abs(waypoint.origin[2] - newWaypoint.origin[2]);
				if (distanceVert > PLAYER_CAPSULE_HEIGHT) continue;
				distanceHorizSq = distanceSquared(
					(waypoint.origin[0], waypoint.origin[1], 0),
					(newWaypoint.origin[0], newWaypoint.origin[1], 0)
				);
				if (distanceHorizSq > connectDistanceHorizSq) continue;
				if (distanceHorizSq < minDistanceSq) {
					invalidStep = true;
					break;
				}
				connectableWaypoints[connectableWaypoints.size] = waypoint;
			}
			if (invalidStep) continue;

			mesh.waypoints[mesh.waypoints.size] = newWaypoint;

			foreach (waypoint in connectableWaypoints) {
				delta = waypoint.origin - newWaypoint.origin;
				connectOrigin = scripts\ai\movement::simulateStep(newWaypoint.origin, delta);
				if (distanceSquared(waypoint.origin, connectOrigin) > 1.0) {
					lib\debug::line3D(newWaypoint.origin, connectOrigin, (1, 0.2, 0.2), 16);
					continue;
				};

				newWaypoint scripts\ai\Waypoint::addChild(waypoint);
				waypoint scripts\ai\Waypoint::addChild(newWaypoint);
				lib\debug::line3D(newWaypoint.origin, waypoint.origin, (1, 0.8, 0.2), 16);
			}

			queue[queue.size] = newWaypoint;
		}
	}

	return mesh;
}
