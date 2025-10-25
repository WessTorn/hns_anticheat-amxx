#define NMAX 100

#define ADMIN_FLAG ADMIN_BAN

new const g_szPrefix[24] = "[^3CA^1]"

new g_iFlags[MAX_PLAYERS + 1];

new Float:g_flVelocity[MAX_PLAYERS + 1][3];
new Float:g_flPrevVelocity[MAX_PLAYERS + 1][3];

new g_iButtons[MAX_PLAYERS + 1];
new g_iPrevButtons[MAX_PLAYERS + 1];
new g_iOldButtons[MAX_PLAYERS + 1];
new Float:g_flMaxSpeed[MAX_PLAYERS + 1];

new g_bGround[MAX_PLAYERS + 1];
new g_bPrevGround[MAX_PLAYERS + 1];

new bool:g_bInDuck[MAX_PLAYERS + 1];
new bool:g_bPrevInDuck[MAX_PLAYERS + 1];

new g_iFrames[MAX_PLAYERS + 1];

new Float:g_flHorSpeed[MAX_PLAYERS + 1];
new Float:g_flPrevHorSpeed[MAX_PLAYERS + 1];
new Float:g_flStartHorSpeed[MAX_PLAYERS + 1];

new bool:g_iPostPatterns[MAX_PLAYERS + 1][16];
new bool:g_iPrevPatterns[MAX_PLAYERS + 1][16];
new bool:g_iOldPrevPatterns[MAX_PLAYERS + 1][16];

new g_iPostFrames[MAX_PLAYERS + 1];
new g_iPreFrames[MAX_PLAYERS + 1];

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
