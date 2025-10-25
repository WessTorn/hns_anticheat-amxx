enum BHOP_STYLE {
	BH_REGULAR = 0,
	BH_STANDUP = 1,
	BH_DUCK = 2
}

new BHOP_STYLE:g_iBhopStyle[MAX_PLAYERS + 1];

enum _:BHOP_DATA {
	BHOP_STYLE:BH_STYLE,
	BH_FOG,
    Float:BH_PRE,
	Float:BH_POST,
	bool:BH_IDEAL,
	bool:BH_PATTERNS[30]
}

new g_sBhopStats[MAX_PLAYERS + 1][NMAX][BHOP_DATA];
new g_iBhopCount[MAX_PLAYERS + 1];

public set_stats_bhop(id) {
    g_iBhopCount[id]++;
    g_sBhopStats[id][g_iBhopCount[id]][BH_FOG] = g_iFrames[id];
    
    if (g_iFrames[id] == 1) {
        g_flPrevHorSpeed[id] = g_flHorSpeed[id];
    }
    
    g_sBhopStats[id][g_iBhopCount[id]][BH_PRE] = g_flStartHorSpeed[id];
    g_sBhopStats[id][g_iBhopCount[id]][BH_POST] = g_flPrevHorSpeed[id];

    if (g_flPrevHorSpeed[id] <= g_flMaxSpeed[id] && g_iFrames[id] == 1) {
        g_sBhopStats[id][g_iBhopCount[id]][BH_IDEAL] = true;
    } else {
        g_sBhopStats[id][g_iBhopCount[id]][BH_IDEAL] = false;
    }

    g_sBhopStats[id][g_iBhopCount[id]][BH_STYLE] = g_iBhopStyle[id];

    g_bPattern[id] = P_ISPOST;
    g_eActions[id] = ACT_BHOP;
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
        show_stats_bhop(id);
        client_print_color(0, 0, "Print console");
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

new g_sStyleNames[BHOP_STYLE][] = {
    {"Regular"},
    {"Stand-Up"},
    {"Duck"},
}

stock show_stats_bhop(id) {
    client_print(id, print_console, "Bhop stats")
    for (new i = 1; i < 11; i++) {
        new szShowMess[64];
        new iLen;
        new iCmds = 0;
        for (new j = 0; j < 30; j++) {
            if (j == 15 - g_sBhopStats[id][i][BH_FOG]) {
                iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "[");
            }

            if (j == 15) {
                iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "]");
            }
            if (g_sBhopStats[id][i][BH_PATTERNS][j]) {
                iCmds++;
            }
            iLen += format(szShowMess[iLen], sizeof szShowMess - iLen, "%d", g_sBhopStats[id][i][BH_PATTERNS][j]);
        }

        client_print(id, print_console, "| N: %d | Style: %s | FOG: %d | Speed: %.3f / %.3f | Ideal %d | Cmds: %d | Patterns %s |",
        i, g_sStyleNames[g_sBhopStats[id][i][BH_STYLE]], g_sBhopStats[id][i][BH_FOG],
        g_sBhopStats[id][i][BH_PRE], g_sBhopStats[id][i][BH_POST], g_sBhopStats[id][i][BH_IDEAL], iCmds, szShowMess);
    }
}