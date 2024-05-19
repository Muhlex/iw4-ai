// Note: Currently only works with values that can be used to index an array (int, string).

New() {
	set = spawnStruct();
	set._classname = "Set";
	set._array = [];
	return set;
}

has(value) {
	return isDefined(self._array[value]);
}

add(value) {
	self._array[value] = true;
}

remove(value) {
	self._array[value] = undefined;
}

size() {
	return self._array.size;
}

toArray() {
	return getArrayKeys(self._array);
}
