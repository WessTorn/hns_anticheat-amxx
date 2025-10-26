#if defined _ac_gstrafe_included
  #endinput
#endif

#define _ac_gstrafe_included

public hns_gstrafe_move(id, GSSTRAFE_TYPE:type, iFog, Float:flPreSpeed, Float:FlPostSpeed) {
	g_iGstrafeCount[id]++;

	g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_TYPE] = type;

	g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_FOG] = iFog;
	g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PRE] = flPreSpeed;
	g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_POST] = FlPostSpeed;

	return g_iGstrafeCount[id];
}

public hns_gstrafe_patterns(id, slot) {
	for (new i = 0; i < PATTERN_TOTAL; i++) {
		g_sGstrafeStats[id][slot][GS_PATTERNS][i] = g_bPendingPattern[id][i];
	}

	debug_patterns_gstrafe(id, slot);
	
	if (g_iGstrafeCount[id] >= NMAX) {
		//TODO: Если NMAX то отправляем статистику
		reset_stats_gstrafe(id);
	}
}

stock reset_stats_gstrafe(id) {
	for (new i = 0; i <= NMAX; i++) {
   		arrayset(g_sGstrafeStats[id][i], 0, GS_DATA);
	}
	g_iGstrafeCount[id] = 0;
}

stock debug_move_duck(id, GSSTRAFE_TYPE:type, iFog) {
	new szType[16];
	switch (type) {
		case GS_REGULAR: 	formatex(szType, charsmax(szType), "REGULAR");
		case GS_STANDUP: 	formatex(szType, charsmax(szType), "STANDUP");
	}

	client_print_color(id, print_team_blue, "DUCK: T-^3%s^1 FOG-^3%d^1 PRE-^3%0.2f^1 POST-^3%0.2f^1", szType, iFog, flPreSpeed[id], flPostSpeed[id]);
}

public debug_patterns_gstrafe(id, slot) {
	new szShowMess[64];
	new iLen;
	new iCmds = 0;
	new fog = g_sGstrafeStats[id][slot][GS_FOG];

	for (new i = 0; i < PATTERN_TOTAL; i++) {
		if (i == PATTERN_PRE - fog) {
			iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "[");
		}

		if (i == PATTERN_PRE) {
			iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "]");
		}

		if (g_sGstrafeStats[id][slot][GS_PATTERNS][i]) {
			iCmds++;
		}

		iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "%d", g_sGstrafeStats[id][slot][GS_PATTERNS][i]);
	}

	client_print(id, print_console, "%s (%d)", szShowMess, iCmds);
}
