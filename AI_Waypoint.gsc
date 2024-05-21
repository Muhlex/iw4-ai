New(index, origin) {
	waypoint = spawnStruct();
	waypoint.index = index;
	waypoint.origin = origin;
	waypoint.children = Map::New();
	return waypoint;
}

addChild(waypoint) {
	self.children Map::set(waypoint.index, waypoint);
}

hasChild(waypoint) {
	return self.children Map::has(waypoint.index);
}
