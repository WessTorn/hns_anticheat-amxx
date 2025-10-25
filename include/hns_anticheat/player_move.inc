#if defined _player_move_included
  #endinput
#endif

#define _player_move_included

new bool:isPrevGround[MAX_PLAYERS + 1];

new iPrevButton[MAX_PLAYERS + 1];
new iOldButton[MAX_PLAYERS + 1];

new iGroundFrames[MAX_PLAYERS + 1];

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
		}
	} else {
		if (isPrevGround[id] && iGroundFrames[id] <= 10){
			if (inDuck) {
				eBhopType[id] = BH_DUCK;
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
	}


	isPrevGround[id] = isGround;

	iPrevButton[id] = iButton;
	iOldButton[id] = iPrevButton[id];
}

public clear_move(id) {
	isPrevGround[id] = false;

	iPrevButton[id] = 0;
	iOldButton[id] = 0;

	iGroundFrames[id] = 0;
}

stock Float:vector_hor_length(Float:flVel[3]) {
	new Float:flNorma = floatpower(flVel[0], 2.0) + floatpower(flVel[1], 2.0);
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

	client_print_color(id, print_team_blue, "DUCK: T-^3%s^1 FOG-^3%d^1", szType, iFog);
}

stock debug_move_bhop(id, BHOP_TYPE:type, iFog) {
	new szType[16];
	switch (type) {
		case BH_REGULAR: 	formatex(szType, charsmax(szType), "REGULAR");
		case BH_STANDUP: 	formatex(szType, charsmax(szType), "STANDUP");
		case BH_DUCK: 	formatex(szType, charsmax(szType), "DUCK");
	}

	client_print_color(id, print_team_blue, "BHOP: T-^3%s^1 FOG-^3%d^1", szType, iFog);
}