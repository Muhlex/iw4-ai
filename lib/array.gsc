isMap(array) {
	foreach (key in getArrayKeys(array))
		if (isString(key))
			return true;

	return false;
}

toString(array) {
	isMap = isMap(array);
	str = lib::ternary(isMap, "{", "[");
	foreach (key, value in array) {
		if (isMap)
			str += key + ": " + value + ", ";
		else
			str += value + ", ";
	}
	if (array.size > 0)
		str = getSubStr(str, 0, str.size - 2);
	str += lib::ternary(isMap, "}", "]");

	return str;
}
