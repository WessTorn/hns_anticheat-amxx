#define VERSION "1.0.4"

#include <client_analyzer/index.inl>

#define NMAX 100

public plugin_init() 
{
	register_plugin("Client Analyzer", "1.0", "WessTorn");

	menu_init();

	RegisterHookChain(RG_PM_Move, "rgPM_Move", true);
}

public rgPM_Move(id) {
	if (is_user_bot(id) || !is_user_alive(id) || is_user_hltv(id))
		return HC_CONTINUE;

	g_iFlags[id] = get_entvar(id, var_flags);
	g_iButtons[id] = get_entvar(id, var_button);
	g_iPrevButtons[id] = get_entvar(id, var_oldbuttons);

	g_flMaxSpeed[id] = get_maxspeed(id);

	get_entvar(id, var_velocity, g_flVelocity[id]);

	g_flHorSpeed[id] = vector_hor_length(g_flVelocity[id]);
	g_flPrevHorSpeed[id] = vector_hor_length(g_flPrevVelocity[id]);

	g_bGround[id] = bool:(g_bOnGround[id]);
	g_bInDuck[id] = bool:(g_iFlags[id] & FL_DUCKING);

	if (g_bGround[id]) {
		g_iFrames[id]++;
		
		if (!g_bPrevGround[id]) {
			if (g_bInDuck[id]) {
				g_iBhopStyle[id] = BH_STANDUP;
				g_iGstrafeStyle[id] = GS_STANDUP;
			}

			g_flStartHorSpeed[id] = g_flHorSpeed[id];
		}
	} else {
		if (g_bPrevGround[id]) {
			new bool:isDuck = !g_bInDuck[id] && !(g_iPrevButtons[id] & IN_JUMP) && g_iOldButtons[id] & IN_DUCK;
			new bool:isJump = !isDuck && g_iPrevButtons[id] & IN_JUMP && !(g_iOldButtons[id] & IN_JUMP);

			if (g_bInDuck[id]) {
				g_iBhopStyle[id] = BH_DUCK;
			}

			if (isJump && g_iFrames[id] <= 5) {
				set_stats_bhop(id);
			}

			if (isDuck && g_iFrames[id] <= 7) {
				set_stats_gstrafe(id);
			}

			g_iGstrafeStyle[id] = GS_REGULAR;
			g_iBhopStyle[id] = BH_REGULAR;
		}

		if (g_iFrames[id]) {
			g_iFrames[id] = 0;
		}
	}

	new bool:isCmds = false;

	if (g_iButtons[id] & IN_JUMP && ~g_iPrevButtons[id] & IN_JUMP) {
		isCmds = true;
	}

	if (g_iButtons[id] & IN_DUCK && ~g_iPrevButtons[id] & IN_DUCK) {
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
				for (new i = 0; i < 15; i++) {
					g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PATTERNS][i] = bPrevPatterns[i];
				}
				set_patterns_gstrafe(id);
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

	g_bPrevGround[id] = g_bGround[id];

	g_iOldButtons[id] = g_iPrevButtons[id];

	g_flPrevVelocity[id] = g_flVelocity[id];
	g_bPrevInDuck[id] = g_bInDuck[id];

	return HC_CONTINUE
}

public client_disconnected(id) {
  reset_player_info(id);
  reset_stats_bhop(id);
  reset_stats_gstrafe(id);
}

public reset_player_info(id) {
	g_iFlags[id] = 0;

	arrayset(g_flVelocity[id], 0.0, 3);
	arrayset(g_flPrevVelocity[id], 0.0, 3);

	g_iButtons[id] = 0;
	g_iPrevButtons[id] = 0;
	g_iOldButtons[id] = 0;
	g_flMaxSpeed[id] = 0.0;

	g_bGround[id] = 0;
	g_bPrevGround[id] = 0;

	g_bInDuck[id] = false;
	g_bPrevInDuck[id] = false;

	g_flHorSpeed[id] = 0.0;
	g_flPrevHorSpeed[id] = 0.0;
	g_flStartHorSpeed[id] = 0.0;

	g_iPostFrames[id] = 0;
	g_iPostFrames[id] = 0;

	g_iFrames[id] = 0;
}

stock Float:get_maxspeed(id) {
	new Float:flMaxSpeed;
	flMaxSpeed = get_entvar(id, var_maxspeed);
	
	return flMaxSpeed * 1.2;
}

stock Float:vector_hor_length(Float:flVel[3]) {
	new Float:flNorma = floatpower(flVel[0], 2.0) + floatpower(flVel[1], 2.0);
	if (flNorma > 0.0)
		return floatsqroot(flNorma);
		
	return 0.0;
}