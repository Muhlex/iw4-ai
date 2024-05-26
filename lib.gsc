ternary(condition, truthy, falsy) {
	if (condition)
		return truthy;
	else
		return falsy;
}

coalesce(a, b, c, d, e, f, g, h) {
	if (isDefined(a)) return a;
	if (isDefined(b)) return b;
	if (isDefined(c)) return c;
	if (isDefined(d)) return d;
	if (isDefined(e)) return e;
	if (isDefined(f)) return f;
	if (isDefined(g)) return g;
	if (isDefined(h)) return h;
	return undefined;
}

toString(var) {
	if (!isDefined(var)) return "undefined";
	else if (isString(var)) return "^7\"" + var + "^7\"";
	else if (isArray(var)) return lib\array::toString(var);
	else return "" + var;
}
