Math__Remap(value, low, high, targetLow, targetHigh) {
	return targetLow + (value - low) * (targetHigh - targetLow) / (high - low);
}
