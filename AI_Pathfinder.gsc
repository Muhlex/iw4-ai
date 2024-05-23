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

_GetHeuristic(waypointA, waypointB) {
	return distance(waypointA.origin, waypointB.origin);
}

_GetCost(waypointA, waypointB) {
	return distance(waypointA.origin, waypointB.origin);
}

find(start, goal) {
	lib\perf::start("pathfind");

	openList = self._openList;
	openList Heap::clear();
	openList Heap::add(goal); // Search backwards so reversing the path is not necessary.

	gCosts = Map::New();
	gCosts Map::set(goal.index, 0);
	self._fCosts Map::clear();
	self._fCosts Map::set(goal.index, _GetHeuristic(goal, start));

	parents = Map::New();

	iterations = 0;
	while (openList Heap::size() > 0) {
		iterations++;
		current = openList Heap::pop();

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

			childInOpenList = childHasGCost;
			parents Map::set(child.index, current);
			gCosts Map::set(child.index, tentativeGCost);
			self._fCosts Map::set(child.index, tentativeGCost + _GetHeuristic(child, start));

			if (childInOpenList) continue;
			openList Heap::add(child);
		}
	}

	iPrintLn("Pathfinding took ^3", lib\perf::end("pathfind"), " ms^7.");
	return undefined;
}
