New(struct) {
	list = lib::coalesce(struct, spawnStruct());
	list._classname = "List";
	if (!isDefined(list.array)) list.array = [];
	return list;
}

at(index) {
	if (index < 0) {
		return self.array[self.array.size + index];
	} else {
		return self.array[index];
	}
}

set(index, value) {
	self.array[index] = value;
}

push(value) {
	self.array[self.array.size] = value;
}

pop() {
	index = self.array.size - 1;
	if (index < 0) return undefined;
	value = self.array[index];
	self.array[index] = undefined;
	return value;
}

append(list) {
	foreach (value in list.array) {
		self.array[self.array.size] = value;
	}
}

clear() {
	self.array = [];
}

size() {
	return self.array.size;
}

toArray() {
	return self.array;
}
