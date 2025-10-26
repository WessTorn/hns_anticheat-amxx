#if defined _player_move_included
  #endinput
#endif

#define _player_move_included

#define NMAX 100

new bool:isPrevGround[MAX_PLAYERS + 1];

new iPrevButton[MAX_PLAYERS + 1];
new iOldButton[MAX_PLAYERS + 1];

new iGroundFrames[MAX_PLAYERS + 1]; // Кол-во фреймов на земле

new Float:flPreSpeed[MAX_PLAYERS + 1];
new Float:flPostSpeed[MAX_PLAYERS + 1];

enum BHOP_TYPE {
	BH_REGULAR, // Обычный бхоп
	BH_STANDUP, // сбж
	BH_DUCK // дак бхоп
}
new BHOP_TYPE:eBhopType[MAX_PLAYERS + 1];

enum GS_TYPE {
	GS_REGULAR, // ДДРАН
	GS_STANDUP, // СГС
}
new GS_TYPE:eGstrafeType[MAX_PLAYERS + 1];

enum ACTIONS {
	ACT_NOT,
	ACT_BHOP,
	ACT_GSTRAFE
}

new ACTIONS:g_eActions[MAX_PLAYERS + 1];

enum PATTERN {
	P_ISPRE,
	P_ISPOST
}

new PATTERN:g_bPattern[MAX_PLAYERS + 1];

new bool:g_iPostPatterns[MAX_PLAYERS + 1][16];
new bool:g_iPrevPatterns[MAX_PLAYERS + 1][16];
new bool:g_iOldPrevPatterns[MAX_PLAYERS + 1][16];
new g_iPostFrames[MAX_PLAYERS + 1];
new g_iPreFrames[MAX_PLAYERS + 1];


enum _:BHOP_DATA {
	BHOP_TYPE:BH_TYPE,
	BH_FOG,
    Float:BH_PRE,
	Float:BH_POST,
	bool:BH_PATTERNS[30]
}

new g_sBhopStats[MAX_PLAYERS + 1][NMAX][BHOP_DATA];
new g_iBhopCount[MAX_PLAYERS + 1];

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
				// СГС или ДДРАН
			}

			if (isJump) {
				// БХОП
				//debug_move_bhop(id, eBhopType[id], iGroundFrames[id]);
				g_iBhopCount[id]++;

				g_sBhopStats[id][g_iBhopCount[id]][BH_FOG] = iGroundFrames[id];
				g_sBhopStats[id][g_iBhopCount[id]][BH_PRE] = flPreSpeed[id];
				g_sBhopStats[id][g_iBhopCount[id]][BH_POST] = flPostSpeed[id];
				g_sBhopStats[id][g_iBhopCount[id]][BH_TYPE] = eBhopType[id]

				g_bPattern[id] = P_ISPOST;
				g_eActions[id] = ACT_BHOP;
			}
		}

		iGroundFrames[id] = 0;
		flPreSpeed[id] = 0.0;
		flPostSpeed[id] = 0.0;
	}

	new bool:isCmds = false;

	if (iButton & IN_JUMP && ~iPrevButton[id] & IN_JUMP) {
		isCmds = true;
	}

	if (iButton & IN_DUCK && ~iPrevButton[id] & IN_DUCK) {
		isCmds = true;
	}
	if (g_bPattern[id] == P_ISPOST) {
		g_iPostPatterns[id][g_iPostFrames[id]] = isCmds;

		g_iPostFrames[id]++;

		if (g_iPostFrames[id] >= 15) {
			// Algor end
			new j = 15;
			new bool:bPrevPatterns[16];
			for (new i = 14; i >= 0; i--) {
				if (g_iPreFrames[id] >= 1) {
					bPrevPatterns[i] = g_iPrevPatterns[id][g_iPreFrames[id]];
					g_iPreFrames[id]--;
				} else {
					bPrevPatterns[i] = g_iOldPrevPatterns[id][j];
					j--;
				}
			}

			if (g_eActions[id] == ACT_BHOP) {
				for (new i = 0; i < 15; i++) {
					g_sBhopStats[id][g_iBhopCount[id]][BH_PATTERNS][i] = bPrevPatterns[i];
				}
				set_patterns_bhop(id);
			} else if (g_eActions[id] == ACT_GSTRAFE) {
				// for (new i = 0; i < 15; i++) {
				// 	g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PATTERNS][i] = bPrevPatterns[i];
				// }
				// set_patterns_gstrafe(id);
			}

			g_bPattern[id] = P_ISPRE;
			g_iPostFrames[id] = 0;
			g_iPreFrames[id] = 0;
			for (new i = 0; i < 16; i++) {
				g_iPostPatterns[id][i] = false;
				g_iPrevPatterns[id][i] = false;
				g_iOldPrevPatterns[id][i] = false;
			}
			g_eActions[id] = ACT_NOT;
		}
	} else {
		g_iPreFrames[id]++;
		g_iPrevPatterns[id][g_iPreFrames[id]] = isCmds;

		if (g_iPreFrames[id] >= 15) {
			for (new i = 1; i < 16; i++) {
				g_iOldPrevPatterns[id][i] = g_iPrevPatterns[id][i];
			}
			g_iPreFrames[id] = 0;
		}
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

public set_patterns_bhop(id) {
    new j = 0;
    for (new i = 15; i < 30; i++) {
        g_sBhopStats[id][g_iBhopCount[id]][BH_PATTERNS][i] = g_iPostPatterns[id][j];
        j++;
    }
    
    new szShowMess[64];
    new iLen;
    new iCmds = 0;
    for (new i = 0; i < 30; i++) {
        if (i == 15 - g_sBhopStats[id][g_iBhopCount[id]][BH_FOG]) {
            iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "[");
        }

        if (i == 15) {
            iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "]");
        }
        if (g_sBhopStats[id][g_iBhopCount[id]][BH_PATTERNS][i]) {
            iCmds++;
        }
        iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "%d", g_sBhopStats[id][g_iBhopCount[id]][BH_PATTERNS][i]);
    }

    if (g_iBhopCount[id] >= 10) {
        reset_stats_bhop(id);
    }

    client_print_color(0, 0, "%s (%d)", szShowMess, iCmds);
}


stock reset_stats_bhop(id) {
	for (new i = 0; i < NMAX; i++) {
   		arrayset(g_sBhopStats[id][i], 0, BHOP_DATA);
	}
	g_iBhopCount[id] = 0;
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