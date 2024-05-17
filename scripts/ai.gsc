init() {
	level.ais = [];

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
				level.ais[level.ais.size] = scripts\ai\AI::AI_Spawn(player.origin);
				break;
			case "kill":
			case "k":
				foreach (ai in level.ais) ai scripts\ai\AI::Kill();
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
				thread scripts\ai\Navmesh::Navmesh_New(player.origin);
		}
	}
}

OnPlayerSpawned() {
	self endon ("disconnect");

	for (;;) {
		self waittill ("spawned_player");
		self thread OnPlayerControlThink();
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
			ai scripts\ai\AI::HandleMovement(aiMoveVec);

		wait 0.05;
	}
}
