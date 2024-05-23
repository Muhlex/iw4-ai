init() {
	level.ais = List::New();
	level.navmesh = AI_Navmesh::New();
	level.path = List::New();
	level.heap = Heap::New(::compare);

	level thread OnPlayerConnect();
}

compare(a, b, args) {
	return a < b;
}

OnPlayerConnect() {
	for (;;) {
		level waittill ("connected", player);

		player thread OnPlayerSaid();
		player thread OnPlayerSpawned();
	}
}

OnPlayerSaid() {
	for (;;) {
		level waittill ("say", text, player);

		args = strTok(text, " ");

		switch (args[0]) {
			case "spawn":
			case "s":
				ai = AI_Actor::Spawn(player.origin);
				level.ais List::push(ai);
				break;
			case "kill":
			case "k":
				foreach (ai in level.ais.array) ai AI_Actor::kill();
				level.ais List::clear();
				break;
			case "control":
			case "c":
				player thread OnPlayerAIControlThink();
				break;
			case "uncontrol":
			case "uc":
				player notify ("uncontrol");
				break;
			case "freeze":
			case "f":
				player setMoveSpeedScale(0);
				break;
			case "unfreeze":
			case "uf":
				player maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");
				break;
			case "target":
			case "t":
				foreach (ai in level.ais.array) ai AI_Actor::addTarget(player.origin);
				break;
			case "targetpath":
			case "tp":
				foreach (ai in level.ais.array) {
					foreach (waypoint in level.path.array) {
						ai AI_Actor::addTarget(waypoint.origin);
					}
				}
				break;
			case "cleartargets":
			case "ct":
				foreach (ai in level.ais.array) ai AI_Actor::clearTargets();
				break;
			case "generate":
			case "g":
				origins = [];
				origins[0] = player.origin;
				level.navmesh thread AI_Navmesh::generate(origins);
				break;
			case "generatespawns":
			case "gs":
				spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_dm_spawn");
				origins = [];
				foreach (spawnPoint in spawnPoints) origins[origins.size] = spawnPoint.origin;
				level.navmesh thread AI_Navmesh::generate(origins);
				break;
			case "jump":
			case "j":
				if (!isDefined(args[1])) {
					iPrintLnBold("^1No waypoint specified.");
					continue;
				}
				index = int(args[1]);
				player setOrigin(level.navmesh AI_Navmesh::getWaypoint(index).origin);
				break;
			case "path":
			case "p":
				if (!isDefined(args[2])) {
					iPrintLnBold("^1Didn't specify 2 waypoints.");
					continue;
				}
				startIndex = int(args[1]);
				goalIndex = int(args[2]);
				start = level.navmesh AI_Navmesh::getWaypoint(startIndex);
				goal = level.navmesh AI_Navmesh::getWaypoint(goalIndex);
				if (!isDefined(start) || !isDefined(goal)) {
					iPrintLnBold("^1Invalid waypoints specified.");
					continue;
				}
				path = level.navmesh.pathfinder AI_Pathfinder::find(start, goal);
				if (!isDefined(path)) {
					iPrintLnBold("^3No path found.");
					continue;
				}
				level.path = path;
				iPrintLnBold("^2Path of length ^7", path List::size(), " ^2found.");
				break;
			case "heapadd":
			case "ha":
				value = int(args[1]);
				level.heap Heap::add(value);
				iPrintLnBold("Added ", value);
				iPrintLn("Heap Array: ", lib::toString(level.heap.array));
				break;
			case "heappop":
			case "hp":
				value = level.heap Heap::pop();
				if (!isDefined(value)) iPrintLnBold("-- Heap empty --");
				else iPrintLnBold(value);
				iPrintLn("Heap Array: ", lib::toString(level.heap.array));
				break;
		}
	}
}

OnPlayerSpawned() {
	self endon ("disconnect");

	for (;;) {
		self waittill ("spawned_player");
		self thread OnPlayerDebug4();
		self thread OnPlayerDebug2();
	}
}

OnPlayerAIControlThink() {
	self notify ("uncontrol");

	self endon ("disconnect");
	self endon ("death");
	self endon ("uncontrol");

	speed = 8;

	for (;;) {
		velocity = (0, 0, 0);
		normalizedMovement = self getNormalizedMovement();
		if (lengthSquared(normalizedMovement) > 0) {
			moveAngle = combineAngles(vectorToAngles(normalizedMovement * (1, -1, 1)), self.angles);
			velocity = anglesToForward(moveAngle) * speed;
		}
		foreach (ai in level.ais.array)
			ai.velocity += velocity;

		wait 0.05;
	}
}

OnPlayerDebug4() {
	self endon ("disconnect");
	self endon ("death");

	self notifyOnPlayerCommand("+debug 4", "+actionslot 4");
	self notifyOnPlayerCommand("-debug 4", "-actionslot 4");

	for (;;) {
		self waittill ("+debug 4");
		self OnPlayerDrawNavmesh();
	}
}

OnPlayerDebug2() {
	self endon ("disconnect");
	self endon ("death");

	self notifyOnPlayerCommand("+debug 2", "+actionslot 2");
	self notifyOnPlayerCommand("-debug 2", "-actionslot 2");

	for (;;) {
		self waittill ("+debug 2", arg);
		self OnPlayerDrawPath();
	}
}

OnPlayerDrawNavmesh() {
	self endon ("disconnect");
	self endon ("death");
	self endon ("-debug 4");

	for (;;) {
		level.navmesh AI_Navmesh::draw(self.origin, 4);
		wait 0.05;
	}
}

OnPlayerDrawPath() {
	self endon ("disconnect");
	self endon ("death");
	self endon ("-debug 2");

	for (;;) {
		path = level.path;
		size = path List::size();
		if (size > 0) {
			start = path List::at(0);
			goal = path List::at(-1);
			lib\debug::text3D(start.origin + (0, 0, 2), "| START", (1.0, 0.2, 0.2), 1, 2.0);
			lib\debug::text3D(goal.origin + (0, 0, 2), "| GOAL", (0.2, 1.0, 0.2), 1, 2.0);
			for (i = 1; i < path List::size(); i++) {
				lib\debug::line3D(
					path List::at(i - 1).origin + (0, 0, 1),
					path List::at(i).origin + (0, 0, 1),
					(1.0 - 0.6 * i / size, 0.4 + 0.6 * i / size, 0.4)
				);
			}
		}
		wait 0.05;
	}
}
