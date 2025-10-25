#if defined _player_move_included
  #endinput
#endif

#define _player_move_included

new bool:isPrevGround[MAX_PLAYERS + 1];

new iPrevButton[MAX_PLAYERS + 1];
new iOldButton[MAX_PLAYERS + 1];

new iGroundFrames[MAX_PLAYERS + 1];

new Float:flPreSpeed[MAX_PLAYERS + 1];
new Float:flPostSpeed[MAX_PLAYERS + 1];

enum BHOP_TYPE {
	BH_REGULAR,
	BH_STANDUP,
	BH_DUCK
}
new BHOP_TYPE:eBhopType[MAX_PLAYERS + 1];

enum GS_TYPE {
	GS_REGULAR,
	GS_STANDUP,
}
new GS_TYPE:eGstrafeType[MAX_PLAYERS + 1];

public player_move(id) {
	new bool:isGround = bool:(get_entvar(id, var_flags) & FL_ONGROUND);

	new iButton = get_entvar(id, var_button);
	iPrevButton[id] = get_entvar(id, var_oldbuttons);

	new bool:inDuck = bool:(get_entvar(id, var_flags) & FL_DUCKING);

	if (isGround) {
		iGroundFrames[id]++;

		if (!isPrevGround[id]) {
			if (inDuck) {
				eBhopType[id] = BH_STANDUP;
				eGstrafeType[id] = GS_STANDUP;
			} else {
				eBhopType[id] = BH_REGULAR;
				eGstrafeType[id] = GS_REGULAR;
			}

			flPreSpeed[id] = get_vector_hor_length(id);
		}

		flPostSpeed[id] = get_vector_hor_length(id);
	} else {
		if (isPrevGround[id] && iGroundFrames[id] <= 10){
			if (inDuck) {
				eBhopType[id] = BH_DUCK;
			}

			if (iGroundFrames[id] == 1) {
				flPostSpeed[id] = get_vector_hor_length(id);
			}

			new bool:isDuck = !inDuck && !(iPrevButton[id] & IN_JUMP) && iOldButton[id] & IN_DUCK;
			
			new bool:isJump = !isDuck && iPrevButton[id] & IN_JUMP && !(iOldButton[id] & IN_JUMP);

			if (isDuck) {
				debug_move_bhop(id, eBhopType[id], iGroundFrames[id]);
			}

			if (isJump) {
				debug_move_bhop(id, eBhopType[id], iGroundFrames[id]);
			}
		}

		iGroundFrames[id] = 0;
		flPreSpeed[id] = 0.0;
		flPostSpeed[id] = 0.0;
	}


	isPrevGround[id] = isGround;

	iOldButton[id] = iPrevButton[id];
}

public clear_move(id) {
	isPrevGround[id] = false;

	iPrevButton[id] = 0;
	iOldButton[id] = 0;

	iGroundFrames[id] = 0;
}

stock Float:get_vector_hor_length(id) {
	new Float:flVelocity[3]
	get_entvar(id, var_velocity, flVelocity);

	new Float:flNorma = floatpower(flVelocity[0], 2.0) + floatpower(flVelocity[1], 2.0);
	if (flNorma > 0.0)
		return floatsqroot(flNorma);
		
	return 0.0;
}

stock debug_move_duck(id, GS_TYPE:type, iFog) {
	new szType[16];
	switch (type) {
		case GS_REGULAR: 	formatex(szType, charsmax(szType), "REGULAR");
		case GS_STANDUP: 	formatex(szType, charsmax(szType), "STANDUP");
	}

	client_print_color(id, print_team_blue, "DUCK: T-^3%s^1 FOG-^3%d^1 PRE-^3%0.2f^1 POST-^3%0.2f^1", szType, iFog, flPreSpeed[id], flPostSpeed[id]);
}

stock debug_move_bhop(id, BHOP_TYPE:type, iFog) {
	new szType[16];
	switch (type) {
		case BH_REGULAR: 	formatex(szType, charsmax(szType), "REGULAR");
		case BH_STANDUP: 	formatex(szType, charsmax(szType), "STANDUP");
		case BH_DUCK: 	formatex(szType, charsmax(szType), "DUCK");
	}

	client_print_color(id, print_team_blue, "BHOP: T-^3%s^1 FOG-^3%d^1 PRE-^3%0.2f^1 POST-^3%0.2f^1", szType, iFog, flPreSpeed[id], flPostSpeed[id]);
}