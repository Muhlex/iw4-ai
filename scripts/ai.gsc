init() {
	level.ais = [];
	level.navmesh = AI_Navmesh::New();

	level thread OnPlayerConnect();
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

		switch (text) {
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
