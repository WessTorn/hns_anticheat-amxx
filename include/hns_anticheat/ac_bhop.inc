#if defined _ac_bhop_included
  #endinput
#endif

#define _ac_bhop_included


public hns_bhop_move(id, BHOP_TYPE:type, iFog, Float:flPreSpeed, Float:FlPostSpeed) {
	g_iBhopCount[id]++;

	g_sBhopStats[id][g_iBhopCount[id]][BH_TYPE] = type;

	g_sBhopStats[id][g_iBhopCount[id]][BH_FOG] = iFog;
	g_sBhopStats[id][g_iBhopCount[id]][BH_PRE] = flPreSpeed;
	g_sBhopStats[id][g_iBhopCount[id]][BH_POST] = FlPostSpeed;

	return g_iBhopCount[id];
}

public hns_bhop_patterns(id, slot) {
	for (new i = 0; i < PATTERN_TOTAL; i++) {
		g_sBhopStats[id][slot][BH_PATTERNS][i] = g_bPendingPattern[id][i];
	}

	debug_patterns_bhop(id, slot);

	if (g_iBhopCount[id] >= NMAX) {
		reset_stats_bhop(id);
	}
}

stock reset_stats_bhop(id) {
	for (new i = 0; i <= NMAX; i++) {
   		arrayset(g_sBhopStats[id][i], 0, BHOP_DATA);
	}
	g_iBhopCount[id] = 0;
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

public debug_patterns_bhop(id, slot) {
	new szShowMess[64];
	new iLen;
	new iCmds = 0;
	new fog = g_sBhopStats[id][slot][BH_FOG];

	for (new i = 0; i < PATTERN_TOTAL; i++) {
		if (i == PATTERN_PRE - fog) {
			iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "[");
		}

		if (i == PATTERN_PRE) {
			iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "]");
		}

		if (g_sBhopStats[id][slot][BH_PATTERNS][i]) {
			iCmds++;
		}

		iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "%d", g_sBhopStats[id][slot][BH_PATTERNS][i]);
	}

	client_print_color(id, print_team_blue, "%s (%d)", szShowMess, iCmds);
}
