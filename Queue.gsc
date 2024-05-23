New() {
	queue = spawnStruct();
	queue._classname = "Queue";
	queue._first = undefined;
	queue._last = undefined;
	queue._size = 0;
	return queue;
}

enqueue(value) {
	entry = spawnStruct();
	entry.value = value;
	entry.next = undefined;

	if (self._size == 0) self._first = entry;
	else self._last.next = entry;
	self._last = entry;
	self._size++;
}

dequeue() {
	if (self._size == 0) return undefined;

	entry = self._first;
	if (isDefined(entry.next)) self._first = entry.next;
	self._size--;
	return entry.value;
}

clear() {
	self._size = 0;
}

size() {
	return self._size;
}
