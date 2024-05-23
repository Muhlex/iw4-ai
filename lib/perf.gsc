_getData() {
	if (!isDefined(level.lib)) level.lib = spawnStruct();
	if (!isDefined(level.lib.perf)) {
		level.lib.perf = spawnStruct();
		level.lib.perf.timestamps = Map::New();
	}
	return level.lib.perf;
}

_getTimestamp() {
	timeMs = int64Op(getSystemTime(), "*", 1000);
	return int64Op(timeMs, "+", getSystemMilliseconds());
}

start(id) {
	timestamps = _getData().timestamps;
	timestamps Map::set(id, _getTimestamp());
}

end(id) {
	timestamps = _getData().timestamps;
	timestamp = timestamps Map::get(id);
	if (!isDefined(timestamp)) return undefined;

	return int64ToInt(int64Op(_getTimestamp(), "-", timestamp));
}
