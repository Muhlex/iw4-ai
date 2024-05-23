init() {
	level.ais = [];
	level.navmesh = AI_Navmesh::New();
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
				level.ais[level.ais.size] = AI_Actor::Spawn(player.origin);
				break;
			case "kill":
			case "k":
				foreach (ai in level.ais) ai AI_Actor::kill();
				level.ais = [];
				break;
			case "control":
			case "c":
				player notify ("uncontrol");
				player thread OnPlayerControlThink();
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
			case "path":
			case "p":
				if (!isDefined(args[2])) {
					iPrintLnBold("^1No 2 waypoints specified.");
					continue;
				}
				if (level.navmesh AI_Navmesh::size() == 0) {
					iPrintLnBold("^1No waypoints available.");
					continue;
				}
				startIndex = int(args[1]);
				goalIndex = int(args[2]);
				start = level.navmesh AI_Navmesh::getWaypoint(startIndex);
				goal = level.navmesh AI_Navmesh::getWaypoint(goalIndex);
				path = level.navmesh.pathfinder AI_Pathfinder::find(start, goal);
				if (!isDefined(path)) {
					iPrintLnBold("^3No path found.");
					continue;
				}
				iPrintLnBold("^2Path of length ^7", path List::size(), " ^2found.");
				for (i = 1; i < path List::size(); i++) {
					lib\debug::line3D(path List::at(i - 1).origin, path List::at(i).origin, (0.2, 1, 0.1), 20);
				}
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
		self thread OnPlayerControlThink();
		self thread OnPlayerDebug4();
	}
}

OnPlayerControlThink() {
	self endon ("disconnect");
	self endon ("death");
	self endon ("uncontrol");

	for (;;) {
		aiMoveVec = (0, 0, 0);
		normalizedMovement = self getNormalizedMovement();
		if (lengthSquared(normalizedMovement) > 0) {
			moveAngle = combineAngles(vectorToAngles(normalizedMovement * (1, -1, 1)), self.angles);
			aiMoveVec = anglesToForward(moveAngle);
		}
		foreach (ai in level.ais)
			ai AI_Actor::handleMovement(aiMoveVec);

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

OnPlayerDrawNavmesh() {
	self endon ("disconnect");
	self endon ("death");
	self endon ("-debug 4");

	for (;;) {
		level.navmesh AI_Navmesh::draw(self.origin, 4);
		wait 0.05;
	}
}
