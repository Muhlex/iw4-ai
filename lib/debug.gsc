text3D(pos, text, color, alpha, scale, duration, sync) {
	color = lib::coalesce(color, (1, 1, 1));
	alpha = lib::coalesce(alpha, 1.0);
	scale = lib::coalesce(scale, 1.0);
	duration = lib::coalesce(duration, 0.05);
	sync = lib::coalesce(sync, false);

	if (sync) {
		for (i = 0; i < duration * 20; i++) {
			print3D(pos, text, color, alpha, scale);
			wait 0.05;
		}
	} else {
		thread text3D(pos, text, color, alpha, scale, duration, true);
	}
}

line3D(start, end, color, duration, sync) {
	color = lib::coalesce(color, (1, 1, 1));
	duration = lib::coalesce(duration, 0.05);
	sync = lib::coalesce(sync, false);

	if (sync) {
		for (i = 0; i < duration * 20; i++) {
			line(start, end, color, false);
			wait 0.05;
		}
	} else {
		thread line3D(start, end, color, duration, true);
	}
}

point3D(pos, color, duration) {
	line3D((pos[0] + 1, pos[1] + 1, pos[2] + 1), (pos[0] - 1, pos[1] - 1, pos[2] - 1), color, duration);
	line3D((pos[0] - 1, pos[1] + 1, pos[2] + 1), (pos[0] + 1, pos[1] - 1, pos[2] - 1), color, duration);
	line3D((pos[0] + 1, pos[1] - 1, pos[2] + 1), (pos[0] - 1, pos[1] + 1, pos[2] - 1), color, duration);
	line3D((pos[0] - 1, pos[1] - 1, pos[2] + 1), (pos[0] + 1, pos[1] + 1, pos[2] - 1), color, duration);
}

box3D(mins, maxs, color, duration) {
	vertices = [];
	vertices[0] = (mins[0], mins[1], mins[2]);
	vertices[1] = (maxs[0], mins[1], mins[2]);
	vertices[2] = (maxs[0], maxs[1], mins[2]);
	vertices[3] = (mins[0], maxs[1], mins[2]);
	vertices[4] = (mins[0], mins[1], maxs[2]);
	vertices[5] = (maxs[0], mins[1], maxs[2]);
	vertices[6] = (maxs[0], maxs[1], maxs[2]);
	vertices[7] = (mins[0], maxs[1], maxs[2]);

	edges = [];

	for (i = 0; i < 4; i++) {
		// connect vertices horizontally
		edges[i][0] = i;
		edges[i][1] = (i + 1) % 4;
		edges[i + 4][0] = i + 4;
		edges[i + 4][1] = (i + 1) % 4 + 4;

		// connect vertices vertically
		edges[i + 8][0] = i;
		edges[i + 8][1] = i + 4;
	}

	for (i = 0; i < edges.size; i++)
		line3D(vertices[edges[i][0]], vertices[edges[i][1]], color, duration);
}

arc3D(pos, radius, startAngle, arcAngle, axis, color, duration) {
	startAngle = lib::coalesce(startAngle, 0);
	arcAngle = lib::coalesce(arcAngle, 360);
	axis = lib::coalesce(axis, "z");
	segments = ceil(arcAngle / clamp(lib\Math::remap(radius, 16, 8192, 22.5, 12), 22.5, 22));

	for (i = 0; i < segments; i++) {
		angle = startAngle + arcAngle * i / segments;
		nextAngle = startAngle + arcAngle * (i + 1) / segments;

		startX = radius * cos(angle);
		startY = radius * sin(angle);
		endX = radius * cos(nextAngle);
		endY = radius * sin(nextAngle);

		startOffset = undefined;
		endOffset = undefined;

		switch (axis) {
			case "x":
				startOffset = (0, startX, startY);
				endOffset = (0, endX, endY);
				break;
			case "y":
				startOffset = (startX, 0, startY);
				endOffset = (endX, 0, endY);
				break;
			case "z":
				startOffset = (startX, startY, 0);
				endOffset = (endX, endY, 0);
				break;
		}

		line3D(pos + startOffset, pos + endOffset, color, duration);
	}
}

capsule3D(pos, halfHeight, radius, color, duration) {
	topCenter = pos + (0, 0, halfHeight - radius);
	bottomCenter = pos - (0, 0, halfHeight - radius);

	line3D(topCenter + (radius, 0, 0), bottomCenter + (radius, 0, 0), color, duration);
	line3D(topCenter + (0, radius, 0), bottomCenter + (0, radius, 0), color, duration);
	line3D(topCenter - (radius, 0, 0), bottomCenter - (radius, 0, 0), color, duration);
	line3D(topCenter - (0, radius, 0), bottomCenter - (0, radius, 0), color, duration);

	arc3D(topCenter, radius, 0, 360, "z", color, duration);
	arc3D(topCenter, radius, 0, 180, "x", color, duration);
	arc3D(topCenter, radius, 0, 180, "y", color, duration);

	arc3D(bottomCenter, radius, 0, 360, "z", color, duration);
	arc3D(bottomCenter, radius, 180, 180, "x", color, duration);
	arc3D(bottomCenter, radius, 180, 180, "y", color, duration);
}
