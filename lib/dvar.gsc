initBool(name, value) {
	if (value) value = 1;
	else value = 0;

	setDvarIfUninitialized(name, value);
	exec("dvar_bool " + name + " " + value);
}

initInt(name, value, min, max) {
	value = int(clamp(value, min, max));

	setDvarIfUninitialized(name, value);
	exec("dvar_int " + name + " " + value + " " + min + " " + max);
}
