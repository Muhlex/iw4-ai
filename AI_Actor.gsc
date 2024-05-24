PLAYER_CAPSULE_HALF_HEIGHT = 36;
PLAYER_CAPSULE_RADIUS = 16;

MOVE_SPEED = 3;

ANIM_IDLE = 0;
ANIM_WALK = 1;

Spawn(origin) {
	ai = spawn("script_model", origin);
	ai._headModel = spawn("script_model", origin);
	ai._headModel linkTo(ai);
	ai._animation = -1;
	ai setRandomModel();
	ai _setAnimation(ANIM_IDLE);

	ai.velocity = (0, 0, 0);
	ai._currentTarget = undefined;
	ai._targets = Queue::New();

	ai thread _think();
	return ai;
}

kill() {
	self._headModel delete();
	self delete();
}

addTarget(origin) {
	self._targets Queue::enqueue(origin);
}

clearTargets() {
	self._targets Queue::clear();
}

_think() {
	self endon ("death");

	interval = 0.1; // 0.05 creates janky looking movement
	ticksPerInterval = int(interval / 0.05);
	moveSpeed = MOVE_SPEED * ticksPerInterval;

	for (;;) {
		if (!isDefined(self._currentTarget) && self._targets Queue::size() > 0) {
			self._currentTarget = self._targets Queue::dequeue();
		}

		if (isDefined(self._currentTarget)) {
			delta = self._currentTarget - self.origin;
			length = length(delta);
			movement = undefined;
			if (length < moveSpeed) {
				movement = delta;
				self._currentTarget = undefined;
			} else {
				movement = delta / length * moveSpeed;
			}
			self.velocity += movement;
		}

		if (self.velocity == (0, 0, 0)) {
			self _setAnimation(ANIM_IDLE);
		} else {
			self _setAnimation(ANIM_WALK);
			newOrigin = scripts\ai\movement::simulateMovement(self.origin, self.velocity);
			self moveTo(newOrigin, interval);
			self rotateTo((0, vectorToAngles(self.velocity)[1], 0), 0.2, 0.1, 0.0);
			self.velocity *= 0;
		}

		if (getDvarInt("scr_ai_actor_debug")) {
			lib\debug::text3D(
				self.origin + (0, 0, PLAYER_CAPSULE_HALF_HEIGHT * 2 + 2),
				"| AI Actor",
				(0.5, 1, 0.5),
				1,
				0.25,
				interval
			);
			lib\debug::capsule3D(
				self.origin + (0, 0, PLAYER_CAPSULE_HALF_HEIGHT),
				PLAYER_CAPSULE_HALF_HEIGHT,
				PLAYER_CAPSULE_RADIUS,
				(0.5, 1, 0.5),
				interval
			);
		}

		wait interval;
	}
}

setRandomModel() {
	models = _GetModels();
	types = models Map::keys();
	type = types List::at(randomInt(types List::size()));

	model = models Map::get(type);
	body = model.bodies List::at(randomInt(model.bodies List::size()));
	head = "tag_origin";
	if (model.heads List::size() > 0) {
		head = model.heads List::at(randomInt(model.heads List::size()));
	}

	self setModel(body);
	self._headModel setModel(head);
	self._headModel.origin = self getTagOrigin("j_spine4");
	self._headModel.angles = combineAngles(self.angles, (270, 0, 270));
	self._headModel linkTo(self, "j_spine4");
}

_setAnimation(animation) {
	if (self._animation == animation) return;

	name = _GetAnimations() List::at(animation);
	self scriptModelPlayAnim(name);
	if (isDefined(self._headModel)) self._headModel scriptModelPlayAnim(name);
	self._animation = animation;
}

_GetModels() {
	if (!isDefined(level.AI_Actor)) level.AI_Actor = spawnStruct();
	if (!isDefined(level.AI_Actor.models)) {
		models = Map::New();

		def = spawnStruct();
		def.bodies = List::New();
		def.bodies List::push("body_urban_civ_female_a");
		def.bodies List::push("body_urban_civ_female_b");
		def.heads = List::New();
		def.heads List::push("head_urban_civ_female_a");
		def.heads List::push("head_urban_civ_female_b");
		models Map::set("civ_urban_female", def);

		def = spawnStruct();
		def.bodies = List::New();
		def.bodies List::push("body_city_civ_male_a");
		def.bodies List::push("body_urban_civ_male_aa");
		def.bodies List::push("body_urban_civ_male_ab");
		def.bodies List::push("body_urban_civ_male_ac");
		def.bodies List::push("body_urban_civ_male_ba");
		def.bodies List::push("body_urban_civ_male_bb");
		def.bodies List::push("body_urban_civ_male_bc");
		def.heads = List::New();
		def.heads List::push("head_urban_civ_male_a");
		def.heads List::push("head_urban_civ_male_b");
		def.heads List::push("head_urban_civ_male_c");
		def.heads List::push("head_urban_civ_male_d");
		models Map::set("civ_urban_male", def);

		def = spawnStruct();
		def.bodies = List::New();
		def.bodies List::push("body_complete_civilian_suit_male_1");
		def.heads = List::New();
		models Map::set("civ_suit_male", def);

		def = spawnStruct();
		def.bodies = List::New();
		def.bodies List::push("body_slum_civ_male_aa");
		def.bodies List::push("body_slum_civ_male_ab");
		def.bodies List::push("body_slum_civ_male_ba");
		def.bodies List::push("body_slum_civ_male_bb");
		def.heads = List::New();
		def.heads List::push("head_slum_civ_male_a");
		def.heads List::push("head_slum_civ_male_b");
		def.heads List::push("head_slum_civ_male_c");
		def.heads List::push("head_slum_civ_male_d");
		def.heads List::push("head_slum_civ_male_e");
		def.heads List::push("head_slum_civ_male_f");
		def.heads List::push("head_slum_civ_male_g");
		def.heads List::push("head_slum_civ_male_h");
		models Map::set("civ_slum_male", def);

		level.AI_Actor.models = models;
	}
	return level.AI_Actor.models;
}

_GetAnimations() {
	if (!isDefined(level.AI_Actor)) level.AI_Actor = spawnStruct();
	if (!isDefined(level.AI_Actor.animations)) {
		animations = Map::New();
		animations Map::set(ANIM_IDLE, "civilian_stand_idle");
		animations Map::set(ANIM_WALK, "civilian_walk_cool");
		level.AI_Actor.animations = animations;
	}
	return level.AI_Actor.animations;
}

_Precache() {
	foreach (model in _GetModels().array) {
		foreach (body in model.bodies.array) precacheModel(body);
		foreach (head in model.heads.array) precacheModel(head);
	}

	foreach (animation in _GetAnimations().array) {
		precacheMPAnim(animation);
	}
}
