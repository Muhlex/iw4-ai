New(id, origin) {
	waypoint = spawnStruct();
	waypoint.id = id;
	waypoint.origin = origin;
	waypoint.children = Map::New();
	return waypoint;
}

addChild(waypoint) {
	self.children Map::set(waypoint.id, waypoint);
}

hasChild(waypoint) {
	return self.children Map::has(waypoint.id);
}
