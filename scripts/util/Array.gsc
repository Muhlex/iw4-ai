#include scripts\util;

Array__IsMap(array) {
	foreach (key in getArrayKeys(array))
		if (isString(key))
			return true;

	return false;
}

Array__ToString(array) {
	isMap = Array__IsMap(array);
	str = ternary(isMap, "{", "[");
	foreach (key, value in array) {
		if (isMap)
			str += key + ": " + value + ", ";
		else
			str += value + ", ";
	}
	if (array.size > 0)
		str = getSubStr(str, 0, str.size - 2);
	str += ternary(isMap, "}", "]");

	return str;
}
