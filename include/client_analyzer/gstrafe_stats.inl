enum GSSTYLE {
	GS_REGULAR = 0,
	GS_STANDUP = 1,
}

new GSSTYLE:g_iGstrafeStyle[MAX_PLAYERS + 1];

enum _:GS_DATA {
	GSSTYLE:GS_STYLE,
	GS_FOG,
	Float:GS_PRE,
	bool:GS_IDEAL,
	bool:GS_PATTERNS[30]
}

new g_sGstrafeStats[MAX_PLAYERS + 1][NMAX][GS_DATA];
new g_iGstrafeCount[MAX_PLAYERS + 1];

public set_stats_gstrafe(id) {
    g_iGstrafeCount[id]++;
    g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_FOG] = g_iFrames[id];
    g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PRE] = g_flPrevHorSpeed[id];
    if (g_iGstrafeStyle[id] == GS_STANDUP) {
        g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_IDEAL] = (g_iFrames[id] == 3) ? true : false;
    } else {
        g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_IDEAL] = (g_iFrames[id] == 2) ? true : false;
    }
    g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_STYLE] = g_iGstrafeStyle[id];

    if (g_iGstrafeCount[id] >= 99) {

        reset_stats_gstrafe(id);
    }

    g_bPattern[id] = P_ISPOST;
    g_eActions[id] = ACT_GSTRAFE;
}

public set_patterns_gstrafe(id) {
    new j = 0;
    for (new i = 15; i < 30; i++) {
        g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PATTERNS][i] = g_iPostPatterns[id][j];
        j++;
    }

    new szShowMess[64];
    new iLen;
    new iCmds = 0;
    for (new i = 0; i < 30; i++) {
        if (i == 15 - g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_FOG]) {
            iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "[");
        }

        if (i == 15) {
            iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "]");
        }
        if (g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PATTERNS][i]) {
            iCmds++;
        }
        iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "%d", g_sGstrafeStats[id][g_iGstrafeCount[id]][GS_PATTERNS][i]);
    }
    client_print_color(0, 0, "%s (%d)", szShowMess, iCmds);
}

stock reset_stats_gstrafe(id) {
	for (new i = 0; i < NMAX; i++) {
   		arrayset(g_sGstrafeStats[id][i], 0, GS_DATA);
	}
	g_iGstrafeCount[id] = 0;
}