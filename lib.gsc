ternary(condition, truthy, falsy) {
	if (condition)
		return truthy;
	else
		return falsy;
}

coalesce(v1, v2, v3, v4, v5, v6, v7, v8) {
	if (isDefined(v1)) return v1;
	if (isDefined(v2)) return v2;
	if (isDefined(v3)) return v3;
	if (isDefined(v4)) return v4;
	if (isDefined(v5)) return v5;
	if (isDefined(v6)) return v6;
	if (isDefined(v7)) return v7;
	if (isDefined(v8)) return v8;
	return undefined;
}

toString(var) {
	if (!isDefined(var)) return "undefined";
	else if (isString(var)) return "^7\"" + var + "^7\"";
	else if (isArray(var)) return lib\Array::toString(var);
	else return "" + var;
}
