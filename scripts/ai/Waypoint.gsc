New(index, origin) {
	waypoint = spawnStruct();
	waypoint.index = index;
	waypoint.origin = origin;
	waypoint.children = [];
	return waypoint;
}

addChild(waypoint) {
	self.children[waypoint.index] = waypoint;
}

hasChild(waypoint) {
	return isDefined(self.children[waypoint.index]);
}
