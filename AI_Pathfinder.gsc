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

_Heuristic(waypointA, waypointB) {
	return distance(waypointA.origin, waypointB.origin);
}

_Distance(waypointA, waypointB) {
	return distance(waypointA.origin, waypointB.origin);
}

find(start, goal) {
	openList = self._openList;
	openList Heap::clear();
	openList Heap::add(start);

	gCosts = Map::New();
	gCosts Map::set(start.index, 0);
	self._fCosts Map::clear();
	self._fCosts Map::set(start.index, _Heuristic(start, goal));

	parents = Map::New();

	iterations = 0;
	while (openList Heap::size() > 0) {
		iterations++;
		current = openList Heap::pop();

		if (current == goal) {
			path = List::New();
			while (isDefined(current)) {
				path List::push(current);
				current = parents Map::get(current.index);
			}
			return path;
		}

		foreach (child in current.children.array) {
			tentativeGCost = gCosts Map::get(current.index) + _Distance(current, child);
			childGCost = gCosts Map::get(child.index);
			childHasGCost = isDefined(childGCost);
			if (childHasGCost && tentativeGCost >= childGCost) continue;

			childInOpenList = childHasGCost;
			parents Map::set(child.index, current);
			gCosts Map::set(child.index, tentativeGCost);
			self._fCosts Map::set(child.index, tentativeGCost + _Heuristic(child, goal));

			if (childInOpenList) continue;
			openList Heap::add(child);
		}
	}

	return undefined;
}
