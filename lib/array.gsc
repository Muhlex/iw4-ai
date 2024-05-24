isDict(array) {
	foreach (key in getArrayKeys(array))
		if (isString(key))
			return true;

	return false;
}

toString(array) {
	isDict = isDict(array);
	str = lib::ternary(isDict, "{", "[");
	foreach (key, value in array) {
		if (isDict)
			str += key + ": " + value + ", ";
		else
			str += value + ", ";
	}
	if (array.size > 0)
		str = getSubStr(str, 0, str.size - 2);
	str += lib::ternary(isDict, "}", "]");

	return str;
}
