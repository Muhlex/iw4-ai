New() {
	map = spawnStruct();
	map._classname = "Map";
	map.array = [];
	return map;
}

has(key) {
	return isDefined(self.array[key]);
}

get(key) {
	return self.array[key];
}

set(key, value) {
	self.array[key] = value;
}

remove(key) {
	self.array[key] = undefined;
}

clear() {
	self.array = [];
}

size() {
	return self.array.size;
}

keys() {
	struct = spawnStruct();
	struct.array = getArrayKeys(self.array);
	return List::New(struct);
}

toArray() {
	return self.array;
}
