New(compareFunc, compareFuncArgs) {
	heap = spawnStruct();
	heap._classname = "Heap";
	heap._compareFunc = compareFunc;
	heap._compareFuncArgs = compareFuncArgs;
	heap._size = 0;
	heap.array = [];
	return heap;
}

add(value) {
	currentIndex = self._size;
	self.array[currentIndex] = value;

	while (currentIndex > 0) {
		parentIndex = int((currentIndex - 1) / 2);

		if ([[self._compareFunc]](self.array[parentIndex], value, self._compareFuncArgs)) break;

		self.array[currentIndex] = self.array[parentIndex];
		self.array[parentIndex] = value;

		currentIndex = parentIndex;
	}

	self._size++;
}

pop() {
	if (self._size == 0) return undefined;

	result = self.array[0];
	self._size--;
	self.array[0] = self.array[self._size];
	currentIndex = 0;

	while (true) {
		childIndexL = currentIndex * 2 + 1;
		hasChildL = childIndexL < self._size;

		if (!hasChildL) break;

		childIndexR = childIndexL + 1;
		hasChildR = childIndexR < self._size;

		childIndex = childIndexL;
		if (hasChildR && [[self._compareFunc]](self.array[childIndexR], self.array[childIndexL], self._compareFuncArgs)) {
			childIndex = childIndexR;
		}

		value = self.array[currentIndex];
		if ([[self._compareFunc]](value, self.array[childIndex], self._compareFuncArgs)) break;

		self.array[currentIndex] = self.array[childIndex];
		self.array[childIndex] = value;

		currentIndex = childIndex;
	}

	return result;
}

clear() {
	self._size = 0;
}

size() {
	return self._size;
}
