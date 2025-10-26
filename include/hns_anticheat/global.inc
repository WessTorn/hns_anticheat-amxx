#if defined _global_included
  #endinput
#endif

#define _global_included

#define NMAX 10

#define PATTERN_PRE 15
#define PATTERN_POST 15
#define PATTERN_TOTAL (PATTERN_PRE + PATTERN_POST)
#define CMD_HISTORY (PATTERN_PRE + 1)

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
};

new BHOP_TYPE:eBhopType[MAX_PLAYERS + 1];

enum _:BHOP_DATA {
	BHOP_TYPE:BH_TYPE,
	BH_FOG,
    Float:BH_PRE,
	Float:BH_POST,
	bool:BH_PATTERNS[30]
};

new g_sBhopStats[MAX_PLAYERS + 1][12][BHOP_DATA];
new g_iBhopCount[MAX_PLAYERS + 1];

enum GSSTRAFE_TYPE {
	GS_REGULAR, // ДДРАН
	GS_STANDUP // СГС
};

new GSSTRAFE_TYPE:eGstrafeType[MAX_PLAYERS + 1];

enum _:GS_DATA {
	GSSTRAFE_TYPE:GS_TYPE,
	GS_FOG,
    Float:GS_PRE,
	Float:GS_POST,
	bool:GS_PATTERNS[30]
};

new g_sGstrafeStats[MAX_PLAYERS + 1][NMAX][GS_DATA];
new g_iGstrafeCount[MAX_PLAYERS + 1];

enum ACTIONS {
	ACT_NOT,
	ACT_BHOP,
	ACT_GSTRAFE
}

new ACTIONS:g_eActions[MAX_PLAYERS + 1];

new bool:g_bCmdHistory[MAX_PLAYERS + 1][CMD_HISTORY];
new g_iCmdHistoryCursor[MAX_PLAYERS + 1];
new g_iCmdSamples[MAX_PLAYERS + 1];
new iPrevCmdButtons[MAX_PLAYERS + 1];

new bool:g_bPatternPending[MAX_PLAYERS + 1];
new bool:g_bPendingPattern[MAX_PLAYERS + 1][PATTERN_TOTAL];
new g_iPendingPostFrames[MAX_PLAYERS + 1];
new g_iPatternOwnerSlot[MAX_PLAYERS + 1];