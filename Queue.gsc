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

	if (!isDefined(self._first)) self._first = entry;
	else self._last.next = entry;
	self._last = entry;
	self._size++;
}

dequeue() {
	entry = self._first;
	if (!isDefined(entry)) return undefined;

	if (isDefined(entry.next)) self._first = entry.next;
	self._size--;
	return entry.value;
}

size() {
	return self._size;
}
