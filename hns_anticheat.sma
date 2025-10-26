#define VERSION "1.0.4"

#include <hns_anticheat/index.inc>


public plugin_init() {
	register_plugin("Client Analyzer", "dev", "WessTorn");

	RegisterHookChain(RG_PM_Move, "rgPM_Move", false);
	register_forward(FM_CmdStart, "fmCmdStart_Post", true);
}

public rgPM_Move(id) {
	if (is_user_bot(id) || !is_user_alive(id) || is_user_hltv(id))
		return HC_CONTINUE;

	new bool:isGround = bool:(get_entvar(id, var_flags) & FL_ONGROUND);

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
				hns_bhop_move(id, eBhopType[id], iGroundFrames[id], flPreSpeed[id], flPostSpeed[id]);

				begin_pattern_capture(id, ACT_BHOP, g_iBhopCount[id]);
			}
		}

		iGroundFrames[id] = 0;
		flPreSpeed[id] = 0.0;
		flPostSpeed[id] = 0.0;
	}
	isPrevGround[id] = isGround;

	iOldButton[id] = iPrevButton[id];

	return HC_CONTINUE;
}

stock Float:get_vector_hor_length(id) {
	new Float:flVelocity[3]
	get_entvar(id, var_velocity, flVelocity);

	new Float:flNorma = floatpower(flVelocity[0], 2.0) + floatpower(flVelocity[1], 2.0);
	if (flNorma > 0.0)
		return floatsqroot(flNorma);
		
	return 0.0;
}

public fmCmdStart_Post(id, uc_handle, seed) {
	if (!is_user_connected(id))
		return FMRES_IGNORED;

	new buttons = get_ucmd(uc_handle, ucmd_buttons);
	new bool:isScrollFrame = false;

	if ((buttons & IN_JUMP) && !(iPrevCmdButtons[id] & IN_JUMP)) {
		isScrollFrame = true;
	}

	if ((buttons & IN_DUCK) && !(iPrevCmdButtons[id] & IN_DUCK)) {
		isScrollFrame = true;
	}

	iPrevCmdButtons[id] = buttons;

	g_iCmdHistoryCursor[id] = (g_iCmdHistoryCursor[id] + 1) % CMD_HISTORY;
	g_bCmdHistory[id][g_iCmdHistoryCursor[id]] = isScrollFrame;

	if (g_iCmdSamples[id] < CMD_HISTORY) {
		g_iCmdSamples[id]++;
	}

	if (g_bPatternPending[id]) {
		new idx = PATTERN_PRE + g_iPendingPostFrames[id];
		if (idx < PATTERN_TOTAL) {
			g_bPendingPattern[id][idx] = isScrollFrame;
		}

		g_iPendingPostFrames[id]++;

		if (g_iPendingPostFrames[id] >= PATTERN_POST) {
			finalize_pattern_capture(id);
		}
	}

	return FMRES_IGNORED;
}

stock begin_pattern_capture(id, ACTIONS:action, slot) {
	if (slot <= 0)
		return;

	if (g_bPatternPending[id]) {
		finalize_pattern_capture(id, true);
	}

	new cursor = g_iCmdHistoryCursor[id];
	new samples = g_iCmdSamples[id];

	if (samples > 0) {
		cursor--;
		if (cursor < 0) {
			cursor = CMD_HISTORY - 1;
		}
		samples--;
	}

	for (new i = PATTERN_PRE - 1; i >= 0; i--) {
		if (samples > 0) {
			g_bPendingPattern[id][i] = g_bCmdHistory[id][cursor];
			cursor--;
			if (cursor < 0) {
				cursor = CMD_HISTORY - 1;
			}
			samples--;
		} else {
			g_bPendingPattern[id][i] = false;
		}
	}

	g_bPatternPending[id] = true;
	g_iPendingPostFrames[id] = 0;
	g_eActions[id] = action;
	g_iPatternOwnerSlot[id] = slot;
}

stock finalize_pattern_capture(id, bool:bForce = false) {
	if (!g_bPatternPending[id])
		return;

	if (!bForce && g_iPendingPostFrames[id] < PATTERN_POST)
		return;

	for (new i = g_iPendingPostFrames[id]; i < PATTERN_POST; i++) {
		g_bPendingPattern[id][PATTERN_PRE + i] = false;
	}

	switch (g_eActions[id]) {
		case ACT_BHOP: {
			hns_bhop_patterns(id, g_iPatternOwnerSlot[id]);
		}

		case ACT_GSTRAFE: {
			// TODO: handle GS stats
		}
	}

	reset_pattern_buffers(id);
}

public client_disconnected(id) {
  clear_move(id);
}

public clear_move(id) {
	isPrevGround[id] = false;

	iPrevButton[id] = 0;
	iOldButton[id] = 0;

	iGroundFrames[id] = 0;

	iPrevCmdButtons[id] = 0;
	g_iCmdHistoryCursor[id] = 0;
	g_iCmdSamples[id] = 0;

	for (new i = 0; i < CMD_HISTORY; i++) {
		g_bCmdHistory[id][i] = false;
	}

	reset_pattern_buffers(id);
	reset_stats_bhop(id);
}

stock reset_pattern_buffers(id) {
	g_bPatternPending[id] = false;
	g_iPendingPostFrames[id] = 0;
	g_iPatternOwnerSlot[id] = 0;
	g_eActions[id] = ACT_NOT;

	for (new i = 0; i < PATTERN_TOTAL; i++) {
		g_bPendingPattern[id][i] = false;
	}
}


stock debug_move_duck(id, GS_TYPE:type, iFog) {
	new szType[16];
	switch (type) {
		case GS_REGULAR: 	formatex(szType, charsmax(szType), "REGULAR");
		case GS_STANDUP: 	formatex(szType, charsmax(szType), "STANDUP");
	}

	client_print_color(id, print_team_blue, "DUCK: T-^3%s^1 FOG-^3%d^1 PRE-^3%0.2f^1 POST-^3%0.2f^1", szType, iFog, flPreSpeed[id], flPostSpeed[id]);
}
