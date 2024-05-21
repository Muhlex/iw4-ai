// Note: Currently only works with values that can be used to index an array (int, string).

New() {
	set = spawnStruct();
	set._classname = "Set";
	set.array = [];
	return set;
}

has(value) {
	return isDefined(self.array[value]);
}

add(value) {
	self.array[value] = value;
}

remove(value) {
	self.array[value] = undefined;
}

size() {
	return self.array.size;
}

toArray() {
	return getArrayKeys(self.array);
}
