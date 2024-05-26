New(navmesh) {
	pathfinder = spawnStruct();
	pathfinder._navmesh = navmesh;
	pathfinder._fCosts = Map::New();
	pathfinder._openList = Heap::New(::_OpenListCompare, pathfinder._fCosts);
	return pathfinder;
}

_OpenListCompare(waypointA, waypointB, fCosts) {
	aCost = fCosts Map::get(waypointA.index);
	bCost = fCosts Map::get(waypointB.index);
	return aCost < bCost;
}

_GetHeuristic(waypointA, waypointB, debug) {
	if (debug) lib\debug::line3D(waypointA.origin, waypointB.origin, (1.00, 1.00, 1.00), 0.5);
	return distance(waypointA.origin, waypointB.origin);
}

_GetCost(waypointA, waypointB) {
	return distance(waypointA.origin, waypointB.origin);
}

find(start, goal) {
	debug = getDvarInt("scr_ai_pathfinder_debug");
	lib\perf::start("pathfind");

	openSet = Set::New();
	openSet Set::add(goal.index);

	gCosts = Map::New();
	gCosts Map::set(goal.index, 0);
	self._fCosts Map::clear();
	self._fCosts Map::set(goal.index, _GetHeuristic(goal, start, debug));

	parents = Map::New();

	iterations = 0;
	while (openSet Set::size() > 0) {
		iterations++;
		currentIndex = undefined;
		lowestFScore = undefined;
		foreach (index in openSet.array) {
			fScore = self._fCosts Map::get(index);
			if (isDefined(lowestFScore) && fScore >= lowestFScore) continue;

			currentIndex = index;
			lowestFScore = fScore;
		}
		openSet Set::remove(currentIndex);
		current = self._navmesh AI_Navmesh::getWaypoint(currentIndex);

		if (current == start) {
			path = List::New();
			while (isDefined(current)) {
				path List::push(current);
				current = parents Map::get(current.index);
			}
			iPrintLn("Pathfinding took ^3", lib\perf::end("pathfind"), " ms^7.");
			return path;
		}

		foreach (child in current.children.array) {
			tentativeGCost = gCosts Map::get(current.index) + _GetCost(current, child);
			childGCost = gCosts Map::get(child.index);
			childHasGCost = isDefined(childGCost);
			if (childHasGCost && tentativeGCost >= childGCost) continue;

			if (debug) {
				lib\debug::line3D(current.origin, child.origin, (0.32, 1.00, 0.00), 60);
				wait 0.05;
			}

			childInOpenList = childHasGCost;
			parents Map::set(child.index, current);
			gCosts Map::set(child.index, tentativeGCost);
			self._fCosts Map::set(child.index, tentativeGCost + _GetHeuristic(child, start, debug));

			if (childInOpenList) continue;
			openSet Set::add(child.index);
		}
	}

	iPrintLn("Pathfinding took ^3", lib\perf::end("pathfind"), " ms^7.");
	return undefined;
}
