#include amxmodx
#include fun
//#include curl
#include engine
#include nvault
#include amxmisc
#include fakemeta
#include hamsandwich
#include fakemeta_util

/*
new MaxClients
new String:NULL_STRING[4]
new Float:NULL_VECTOR[3]
*/

new sz_plugin_string_main_ban[64],
	sz_plugin_string_other_ban[64],
	sz_plugin_block_modules[16],
	sz_plugin_debug_mode[16],
	sz_plugin_demo_name[64],
	sz_plugin_punish_modules[16],
	sz_plugin_hud_info[8],
	sz_plugin_modules_working[16],
	sz_plugin_custom_prefix[16],
	sz_plugin_modules[16],
	sz_plugin_reason_of_punish[64]

new plugin_just_admin_in_bytes,
	plugin_main_admin_in_bytes,
	plugin_automatically_punish,
	plugin_using_delay_punish,
	plugin_recording_demo_auto,
	plugin_recording_demo_counts,
	plugin_recording_demo_use_nvault,
	plugin_recording_demo_status,
	plugin_using_tasks,
	plugin_using_graph,
	plugin_print_warns_for_admins,
	plugin_punish_disconnected,
	plugin_emit_sounds,
	plugin_bhop_stats

new const taskid_check_build 		= 61135
new const taskid_check_settings 	= 61167
new const taskid_check_cvars 		= 61231
new const taskid_ban_client 		= 61391
new const taskid_check_demoplayer 	= 61295
new const taskid_check_protector 	= 61327
new const taskid_force_cmdrate 		= 61455
new const taskid_record_demo 		= 61199
new const taskid_check_proxy 		= 61487
new const taskid_check_cmd_result 	= 61263
new const taskid_maximal 			= 61519

new const PLUGIN[64] = "Client Analyzer";
new const VERSION[24] = "2.8.1 [full-restore]";
new const AUTHOR[20] = "FAME";

new const VERSION_NUM = 281;
new const PUNISH_SOUND[80] = "plats/elevbell1.wav";
new const CURL_HOST[80] = "https://ca.nobkz.de";

new bool:g_bInitialized;
new bool:g_bTasksRegistered[33];
new bool:g_bPunished[33][11];
new g_eServer[3];

new g_szDataDir[64];
new g_eConfig[374];
new AddToFullPack;
new g_szErrorLogsPath[64];
new g_iBuild[33];
new g_hProxyVault;
new g_eClientCVar[33][10];

new const g_szBadSteamIdList[3][] = {
    "STEAM_ID_LAN",
	"VALVE_ID_LAN",
	"HLTV"
};
new const g_szClientCVars[10][] = {
	"fps_max", "fps_override", "cl_forwardspeed", "cl_backspeed", "cl_sidespeed",
	"cl_movespeedkey", "sensitivity", "m_filter", "m_rawinput", "m_customaccel"
};
new const PunishmentReason[17][] = {
	"Illegal number of jumpbugs in a row",
	"Illegal number of 1 FOG bhops in a row",
	"Illegal number of 2 FOG bhops in a row",
	"Illegal number of ideal bhops in a row",
	"Illegal number of jump commands in a row",
	"Illegal number of jump commands with IN_ALT1 button",
	"Illegal percent of jumpbugs",
	"Illegal percent of 1 FOG bhops",
	"Illegal percent of 2 FOG bhops",
	"Illegal percent of ideal bhops",
	"Illegal percent of ideally distributed bhops",
	"Illegal number of 3 FOG bhops #1",
	"Illegal number of 3 FOG bhops #2",
	"Illegal number of 3 FOG bhops #3",
	"Illegal number of pre jump commands",
	"Illegal number of unique jump patterns",
	"Illegal number of 3 FOG bhops #4"
};
new const PS_HackHack[5][] =
{
	"2101",
	"20101",
	"201101",
	"210101",
	"20101101"
};
new const PS_XTREMEHACK_v1[5][] =
{
	"200101",
	"2010101",
	"20101001",
	"20101011",
	"20110101"
};
new const PS_XTREMEHACK_v2a[45][] =
{
	"2",
	"20101",
	"21101",
	"200101",
	"201001",
	"210101",
	"211001",
	"2001001",
	"2010001",
	"2010101",
	"2101001",
	"2110001",
	"2110101",
	"20010011",
	"20010101",
	"20100011",
	"20100101",
	"20101001",
	"20101011",
	"21010011",
	"21010101",
	"21100011",
	"21100101",
	"21101001",
	"21101011",
	"201001001",
	"201001011",
	"201010001",
	"201010011",
	"211001001",
	"211001011",
	"211010001",
	"211010011",
	"2010001001",
	"2010001101",
	"2010010001",
	"2010010101",
	"2110001001",
	"2110001101",
	"2110010001",
	"2110010101",
	"201001001001",
	"201001011001",
	"211001001001",
	"211001011001"
};
new const PS_XTREMEHACK_v2b[22][] =
{
	"201",
	"20101",
	"200101",
	"201001",
	"2001001",
	"2010001",
	"20010011",
	"20010101",
	"20100001",
	"20100011",
	"20100101",
	"20101001",
	"201001001",
	"201001011",
	"201010001",
	"201010011",
	"2010001001",
	"2010001101",
	"2010010001",
	"2010010101",
	"201001001001",
	"201001011001"
};
new const PS_XTREMEHACK_v3[12][] =
{
	"201",
	"2001",
	"2101",
	"200101",
	"210101",
	"2001001",
	"2010101",
	"2100101",
	"20010101",
	"20100101",
	"20101001",
	"201001001"
};
new const PS_XTREMEHACK_v4[12][] =
{
	"2101",
	"200101",
	"210101",
	"2001001",
	"2010001",
	"2010101",
	"2100101",
	"2101001",
	"20010101",
	"20100101",
	"20101001",
	"201001001"
};
new const PS_FuriousHack_v3[12][] =
{
	"2",
	"2100001",
	"201001001",
	"2010010001",
	"200000000101",
	"200010010011",
	"200100100101",
	"201001000001",
	"201010100001",
	"210101010001",
	"211001001001",
	"211110101001"
};
new const PS_FlatCheat[5][] =
{
	"2010101",
	"201010101",
	"20101010101",
	"2010101010101",
	"201010101010101"
};

new const g_szCVarsOld[6][] =
{
	"juice_strafe_helper",
	"kzh_bhop",
	"mar1k_bhop",
	"rhack^bhop",
	"scroll_count",
	"xhack_bhop"
};
new const g_szCVarsNew[43][] =
{
	"!kzh^bunnyhop_toggle",
	"!pvp_bh_key",
	"#bopn_multiplier",
	"#sv_bh_helper",
	"101xd_bhop",
	"^^bb_j",
	"__fixedyaw",
	"__loopx",
	"bhop",
	"cg_blur_steps",
	"csx__multiplier",
	"cyka_stairwalk_distance",
	"demo_cvar",
	"dusadusa_emulator",
	"enzo_bhop_toggle",
	"fc^fps_max",
	"fsh_hud_style",
	"fsh_showkeys",
	"hpp_fps_max",
	"inj_emulator",
	"juice_emulator",
	"mr_angle_diff",
	"msl",
	"msl_forceto",
	"p_msl",
	"papacam",
	"qweasdr_hud_style",
	"r_blur",
	"rn^bhop",
	"rw_bhop",
	"rw_helper",
	"Steamid",
	"xj_autostrafe",
	"xj_backwards",
	"xj_bhop_distance",
	"xj_fps_highest",
	"xj_fps_lowest",
	"xj_hud_style",
	"xj_multiplier",
	"xj_rear",
	"xj_showkeys",
	"z0redd*_multiplier",
	"~_multiplier"
};
new const g_szCommandsOld[6][] =
{
	"qE2ZQVc2SSNB1wun",
	"+mar1k_scroll",
	"+mar1k_strafe",
	"juice_showyaw",
	"mr_testcmd",
	"xhack_in"
};
new const g_szCommandsNew[32][] =
{
	"fe6KqH3HuT48zXOW",
	"!*demo_rec_playback",
	"#sv_print_stats",
	"+#bopn_strafe",
	"+csx__strafe",
	"+cyka",
	"+fsh_strafe",
	"+inj_gs",
	"+juice_auto",
	"+juice_gs",
	"+juice_jb",
	"+juice_sgs",
	"+papastrafe",
	"+rn*strafehack",
	"+rw_bh",
	"+rw_str",
	"+xj_duckroll",
	"+xj_strafe",
	"+z0redd*_strafe",
	"+~_strafe",
	"101xd_loopx",
	"cl_dump_messages",
	"cl_user_messages",
	"cmd_new",
	"fc*force_alive",
	"hpp*menu",
	"hpp_speed",
	"mr_goto",
	"swa_bhop_scroll_emulation",
	"xj_fps_test",
	"xj_fullbright",
	"xj_invis"
};
new const g_szDemoPlayerCmds[6][] =
{
	"dem_save",
	"dem_start",
	"dem_speed",
	"dem_pause",
	"dem_forcehltv",
	"dem_jump"
};
new const g_szReplaceCharList[] = "`~!@#$%&*()=+[]{};:|,.<>/\? "; // ^ 

//==========================


		/*
		[before]
		player_flags[id][1] = player_flags[id][0];
		g_ePlayer[id][14] = g_ePlayer[id][13];
		g_ePlayer[id][24] = g_ePlayer[id][23];
		g_ePlayer[id][26] = g_ePlayer[id][25];
		g_ePlayer[id][32] = g_ePlayer[id][31];
		
		[after]
		g_ePlayer[id][ePlayerFlagsOld] = g_ePlayer[id][e_PlayerFlags];
		g_ePlayer[id][oldButtons] = g_ePlayer[id][ucButtons];
		g_ePlayer[id][AirFrames_old] = g_ePlayer[id][AirFrames_current];
		g_ePlayer[id][WithoutJumpCmdFrames_old] = g_ePlayer[id][WithoutJumpCmdFrames_current];
		g_ePlayer[id][MaxSpeed_old] = g_ePlayer[id][MaxSpeed_current];
		*/
		
enum _:PLAYER_DATA
{
	/*[0]*/test1,
	/*[1]*/e_jumped,
	/*[2]*/e_ducked,
	test4,
	test5,
	test6,
	test7,
	test8,
	test9,
	test10,
	/*[10]*/e_PlayerFlags,
	test12,
	test13,
	/*[13]*/ucButtons,
	/*[14]*/old_buttons,
	test16,
	test17,
	test18,
	test19,
	test20,
	test21,
	test22,
	/*[22]*/FOG_current,
	/*[23]*/AirFrames_current,
	/*[24]*/AirFrames_old,
	/*[25]*/WithoutJumpCmdFrames_current,
	/*[26]*/WithoutJumpCmdFrames_old,
	test28,
	test29,
	/*[29]*/FOG_old,
	test31,
	/*[31]*/MaxSpeed_current,
	/*[32]*/MaxSpeed_old,
	test34,
	test35,
	test36,
	test37,
	test38,
	test39,
	test40,
	/*[40]*/e_fuser2,
	test42,
	test43,
	test44,
	test45,
	test46,
	test47,
	test48,
	test49,
	test50,
	test51,
	test52,
	/*[52]*/e_colormap,
	test54,
	test55,
	test56,
	test57,
	test58,
	test59,
	test60,
	test61,
	test62,
	test63,
	test64,
	test65,
	test66,
	test67,
	test68,
	test69,
	test70,
	test71,
	test72,
	test73,
	test74,
	test75,
	test76,
	test77,
	test78,
	test79,
	test80,
	test81,
	test82,
	test83,
	e_flags,
	test85,
	test86,
	test87,
	test88,
	test89,
	test90,
	test91,
	test92,
	e_steamid,
	test94,
	test95,
	test96,
	test97,
	test98,
	test99,
	test100,
	test101,
	test102,
	test103,
	test104,
	test105,
	test106,
	test107,
	test108,
	test109,
	test110,
	test111,
	test112,
	test113,
	test114,
	test115,
	test116,
	test117,
	test118,
	test119,
	test120,
	test121,
	test122,
	test123,
	test124,
	test125,
	test126,
	test127,
	test128,
	test129
}
new g_ePlayer[33][PLAYER_DATA];

const BHOP_PATTERN_BUFFER = 21;
const BHOP_PATTERN_MAX_LEN = BHOP_PATTERN_BUFFER - 1;
const BHOP_DEBUG_LABEL_LEN = 9;

enum _:eBhopChecker
{
	bhcStartDuckState = 0,    // cached FL_DUCKING state for the current hop
	bhcIdealCandidate,        // prestrafe requirements met
	bhcReadyForPerfectChain,  // enough frames passed to count another perfect hop
	bhcWaitingForGap,         // waiting for the ground gap before perfect hop tracking resumes
	bhcDistributionReady,     // allows counting ideally distributed hops once per attempt
	bhcFailedChainWindow,     // tracks frames for failed-bhop streak detection
	bhcFastScrollGuard,       // single-hop guard to detect held scroll / +jump
	bhcCollectPattern,        // whether we are still building the current pattern string
	bhcStatsUploaded,         // prevents spamming stats upload/logging
	bhcDebugPrintPending,     // toggle for debug HUD spam
	bhcPreviousFog,           // last recorded FOG tier
	bhcPreviousButtons,       // cached button states (old usercmd)
	bhcPatternBuffer = 12,    // 20-char rolling buffer with localized pattern markers
	bhcPhase = 33,            // punish phase accumulator
	bhcPunishmentReason,      // last triggered punishment id
	bhcDebugMoveLabel = 35,   // small buffer storing the last printed move name
	bhcJumpToggleCounter = 49,// counts consecutive jump button flips
	bhcLastGroundSpeed,       // cached speed before jump (for debug)
	bhcLastMaxSpeed,          // cached maxspeed (for debug)
	bhcCheckerFieldCount
};

new g_eBhopChecker[MAX_PLAYERS+1][eBhopChecker];
enum _:g_eBhopStats_data
{
	e_bh_stats0,
	e_bh_stats1,
	e_bh_stats2,
	BHOPS, // 3
	e_bh_stats4,
	e_bh_stats5,
	e_bh_stats6,
	BHOP_FOG3, // 7
	BHOP_FOG4, // 8
	BHOP_FOG5,
	e_bh_stats10,
	e_bh_stats11,
	e_bh_stats12,
	e_bh_stats13,
	e_bh_stats14,
	e_bh_stats15,
	BHOP_IDEAL, // 16
	e_bh_stats17,
	e_bh_stats18,
	e_bh_stats19,
	BHOP_IDEAL_IAR,
	e_bh_stats21,
	BHOP_NOT_IDEAL_IAR,
	IAR1N2,
	WHIO3FOG,
	e_bh_stats25,
	e_bh_stats26,
	e_bh_stats27,
	e_bh_stats28,
	e_bh_stats29,
	e_bh_stats30,
	e_bh_stats31,
	e_bh_stats32,
	e_bh_stats33,
	e_bh_stats34,
	e_bh_stats35,
	e_bh_stats36,
	e_bh_stats37,
	e_bh_stats38,
	BHOP_SKILL, // 39
	e_bh_stats40,
	e_bh_stats41,
	e_bh_stats42,
	FOG0_P,
	FOG1_P,
	FOG2_P,
	FOG3_P,
	FOG4_P,
	FOG5_P, //48
	BHOP_IDEAL_P,
	e_bh_stats50,
	e_bh_stats51,
	e_bh_stats52,
	e_bh_stats53,
	e_bh_stats54,
	e_bh_stats55,
	e_bh_stats56,
	e_bh_stats57,
	e_bh_stats58,
	e_bh_stats59,
	FAST_SCROLLED_P, // 60
	e_bh_stats61,
	e_bh_stats62,
	e_bh_stats63,
	e_bh_stats64,
	e_bh_stats65,
	e_bh_stats66,
	e_bh_stats67,
	e_bh_stats68,
	e_bh_stats69
}
new g_eBhopStats[MAX_PLAYERS+1][2][g_eBhopStats_data];
new g_eGstrafe[MAX_PLAYERS+1][24];
new g_eGstrafeTotal[MAX_PLAYERS+1][24];
new g_eJumpbug[MAX_PLAYERS+1][40];

const MOVE_WEAPON_NAME_LEN = 32;
const Float:MOVE_WALK_RATIO = 0.52;

enum _:g_eMoves_data
{
	mvConfigSentFlag,          // 0  - we forced client settings this tick
	mvConfigAckFlag,           // 1  - player acknowledged our config command
	mvAnglesClamped,           // 2  - angles were temporarily clamped
	mvSamples,                 // 3  - total samples processed for the current session
	mvInvalidTicks,            // 4  - suspicious movement commands collected
	mvPhase,                   // 5  - current cheat detection phase
	mvPhasePeak,               // 6  - highest phase reached in this session
	mvForwardMismatchCount,    // 7  - total forward diff violations
	mvForwardMismatchStreak,   // 8  - current forward diff streak
	mvForwardMismatchPeak,     // 9  - longest forward diff streak
	mvSideMismatchCount,       // 10 - total side diff violations
	mvSideMismatchStreak,      // 11 - current side diff streak
	mvSideMismatchPeak,        // 12 - longest side diff streak
	mvGroundTicks,             // 13 - number of frames player stayed on ground while flagged
	mvPeakFps,                 // 14 - highest FPS observed during violation
	mvLastWeaponId,            // 15 - weapon recorded for debug output
	mvConfigSentPhase,         // 16 - phase when we sent config enforcement
	mvConfigAckPhase,          // 17 - phase when client replied to enforcement
	Float:mvExpectedMove,      // 18 - theoretical move command magnitude
	Float:mvExpectedForward,   // 19 - theoretical forwardmove component
	Float:mvExpectedSide,      // 20 - theoretical sidemove component
	Float:mvExpectedScale,     // 21 - scale applied when exceeding maxspeed
	Float:mvExpectedWalkForward,//22 - expected forwardmove while walking
	Float:mvExpectedWalkSide,  // 23 - expected sidemove while walking
	Float:mvForwardDelta,      // 24 - delta between sent and expected forwardmove
	Float:mvForwardWalkDelta,  // 25 - delta vs walk forwardmove
	Float:mvSideDelta,         // 26 - delta between sent and expected sidemove
	Float:mvSideWalkDelta,     // 27 - delta vs walk sidemove
	Float:mvLastMaxSpeedChange,// 28 - last time maxspeed changed
	Float:mvMinMove,           // 29 - min observed move magnitude
	Float:mvMinForward,        // 30 - min observed forwardmove
	Float:mvMinSide,           // 31 - min observed sidemove
	Float:mvMaxMove,           // 32 - max observed move magnitude
	Float:mvMaxForward,        // 33 - max observed forwardmove
	Float:mvMaxSide,           // 34 - max observed sidemove
	Float:mvPeakSpeed,         // 35 - max player speed seen during violation
	Float:mvSpeedDelta,        // 36 - amount of overspeed (speed - maxspeed)
	Float:mvSavedAngles[3],    // 37 - cached view angles used when clamping
	mvWeaponName[MOVE_WEAPON_NAME_LEN] // 40 - human readable weapon/carry reason
}
new g_eMoves[MAX_PLAYERS+1][g_eMoves_data];
new g_eAngles[MAX_PLAYERS+1][15];
new g_eFPS[MAX_PLAYERS+1][22];
new g_eGstrafeNSD[MAX_PLAYERS+1][2];
new g_eCommands[MAX_PLAYERS+1][128];
new bool:g_bLoggedDetailed[MAX_PLAYERS+1];
new g_eProtector[MAX_PLAYERS+1][4];
new g_hVault;
new g_eDemo[33][87];
new bool:g_bWaitingBan[33];
new g_iNotifyQueque;
new Float:g_flLastNotification;
new g_szLogsDir[64];
new g_szMap[64];
new g_eGraph[33][5002];
new g_szApiKey[33];
new g_szServerIP[22];
new g_szUserAgent[48];
new g_szTempDir[64];
new g_szPluginsDir[64];
new g_szTempVersion[96];
new g_szTempConfig[96];
new g_szTempUpdate[96];
new g_eUpdate[14];
new curl_slist:g_hHeaders;
new bool:g_bLookingForCmd[33];
new g_szCmdName[33][64];
new Float:g_flNextCheckAllowedSince[33];
new g_hHudInfoVault;
new g_eHUD[33][8];

/*
is_running(mod[])
{
	new mod_name[32];
	get_modname(mod_name, 31);
	return equal(mod_name, mod);
}

public __fatal_ham_error(Ham:id, HamError:err, reason[])
{
	new func = get_func_id("HamFilter", -1);
	new bool:fail = 1;
	new var1;
	if (func != -1 && callfunc_begin_i(func, -1) == 1)
	{
		callfunc_push_int(id);
		callfunc_push_int(err);
		callfunc_push_str(reason, MaxClients);
		if (callfunc_end() == 1)
		{
			fail = false;
		}
	}
	if (fail)
	{
		set_fail_state(reason);
	}
	return 0;
}
*/
LogError(iType, szText[])
{
	static szFormattedText[2048];
	vformat(szFormattedText, 2047, szText, 3);
	new hFile = fopen(g_szErrorLogsPath, "at");
	if (hFile)
	{
		static szDate[22];
		get_time("%d.%m.%Y - %H:%M:%S", szDate, 21);
		fprintf(hFile, "%s %s\n", szDate, szFormattedText);
		fclose(hFile);
	}
	switch (iType)
	{
		case 1:
		{
			server_print("[CA] %s", szFormattedText);
		}
		/*
		case 2:
		{
			set_fail_state(szFormattedText);
		}
		*/
		default:
		{
		}
	}
	return 0;
}

public taskCheckProxy(id)
{
	if (!g_hProxyVault)
	{
		return 0;
	}
	id -= taskid_check_proxy;
	static timestamp;
	static data[4];
	new userid = get_user_userid(id);
	if (nvault_lookup(g_hProxyVault, g_ePlayer[id][114], data, 3, timestamp))
	{
		if (data[0] == 49)
		{
			server_cmd("amx_kick #%i ^"Proxy detected^"", userid);
		}
	}
	else
	{
		API_CheckProxy(g_ePlayer[id][114], userid);
	}
	return 0;
}

public taskCheckBuild(id)
{
	query_client_cvar(id - taskid_check_build, "gl_ztrick_old", "taskCheckBuild_Result");
	return 0;
}

public taskCheckBuild_Result(id, szCVar[], szValue[])
{
	g_iBuild[id] = (equal(szValue, "Bad CVAR request")) ? 4554 : 7960;
	set_task(0.1, "taskCheckSettings", id + taskid_check_settings);
	set_task(5.0, "taskCheckSettings", id + taskid_check_settings);
	CheckCVars(id);
	CheckCommands(id);
	return 0;
}

public taskForceCmdRate(id)
{
	client_cmd(id - taskid_force_cmdrate, "cl_cmdrate 128");
	return 0;
}

public taskCheckSettings(id)
{
	query_client_cvar(id, "cl_forwardspeed", "cl_movespeed");
	query_client_cvar(id, "cl_backspeed", "cl_movespeed");
	query_client_cvar(id, "cl_sidespeed", "cl_movespeed");
	query_client_cvar(id, "cl_cmdbackup", "cl_cmdbackup");
	query_client_cvar(id, "fps_max", "fps_max");
	
	if (4554 < g_iBuild[id])
	{
		query_client_cvar(id, "fps_override", "fps_override");
		query_client_cvar(id, "gl_vsync", "gl_vsync");
	}
	else
	{
		query_client_cvar(id, "fps_modem", "fps_modem");
		query_client_cvar(id, "developer", "developer");
	}
	
	return 0;
}

public cl_movespeed(id, szCVar[], szValue[])
{
	if (!equal(szValue, "400"))
	{
		client_cmd(id, "%s 400", szCVar);
	}
	return 0;
}

public cl_cmdbackup(id, szCVar[], szValue[])
{
	if (!equal(szValue, "4"))
	{
		client_cmd(id, "%s 4", szCVar);
	}
	return 0;
}

public fps_max(id, szCVar[], szValue[])
{
	static szCorrectFPS[6];
	/*
	new var1;
	if (g_iBuild[id] > 4554)
	{
		var1 = 31796;
	}
	else
	{
		var1 = 31816;
	}
	*/
	if (!equal(szValue, szCorrectFPS))
	{
		client_cmd(id, "%s %s", szCVar, szCorrectFPS);
	}
	return 0;
}

public fps_override(id, szCVar[], szValue[])
{
	if (!equal(szValue, "0"))
	{
		client_cmd(id, "%s 0", szCVar);
	}
	return 0;
}

public gl_vsync(id, szCVar[], szValue[])
{
	if (!equal(szValue, "0"))
	{
		client_cmd(id, "%s 0", szCVar);
	}
	return 0;
}

public fps_modem(id, szCVar[], szValue[])
{
	if (!equal(szValue, "0.0"))
	{
		client_cmd(id, "%s 0.0", szCVar);
	}
	return 0;
}

public developer(id, szCVar[], szValue[])
{
	if (!equal(szValue, "0"))
	{
		client_cmd(id, "%s 0", szCVar);
	}
	return 0;
}

bool:SteamIdIsValid(id)
{
	for (new i; i < 3; i++)
	{
		if (containi(g_szBadSteamIdList[i], g_ePlayer[id][e_steamid]) != -1)
			return false;
	}
	
	return true;
}

ExplodeStr1ng(output[][], max, size, input[], delimiter)
{
	new index;
	new l = strlen(input);
	new length;
	while (length < l && index < max)
	{
	}
	return index;
}

InArrayStr(szString[], szArray[][], iArraySize)
{
	new i;
	while (i < iArraySize)
	{
		if (equali(szString, szArray[i], MaxClients))
		{
			return i;
		}
		i++;
	}
	return -1;
}

GetSessionTime(id, szOutput[], iSize)
{
	static iSeconds, iMinutes, iTime;
	iTime = get_user_time(id, 1);
	if (iTime >= 60)
	{
		iMinutes = iTime / 60;
	}
	else
	{
		iMinutes = 0;
	}
	iSeconds = iTime % 60;
	formatex(szOutput, iSize, "%02i:%02i", iMinutes, iSeconds);
	return 0;
}

GetGameTime(szOutput[], iSize, bWithMiliseconds)
{
	static Float:flSeconds;
	static iMinutes;
	static Float:flTime;
	flTime = get_gametime();
	if (flTime >= 0.000000000000000000000000000000000000000000084 /*8.4E-44*/)
	{
		iMinutes = floatround(flTime / 60);
	}
	else
	{
		iMinutes = 0;
	}
	flSeconds = flTime - iMinutes * 60;
	if (bWithMiliseconds)
	{
		formatex(szOutput, iSize, "%02i:%s%.3f", iMinutes, (flSeconds <= 0.000000000000000000000000000000000000000000014/* 1.4E-44 */) ? 32240 : 32248, flSeconds);
	}
	else
	{
		formatex(szOutput, iSize, "%02i:%02.f", iMinutes, flSeconds);
	}
	return 0;
}

PrintToAdmins(color, bool:super, message[])
{
	static buffer[192];
	vformat(buffer, 191, message, 0);
	new players[32];
	new num;
	new player;
	get_players(players, num, "ch");
	new i;
	while (i < num)
	{
		player = players[i];
		new bool:admin;
		admin = (super) ? g_ePlayer[player][7] : g_ePlayer[player][6];
		if (admin)
		{
			client_print_color(player, color, buffer);
		}
		i++;
	}
	return 0;
}

GetRandomString(output[], size)
{
	new i;
	while (i < size)
	{
		switch (random_num(0, 2))
		{
			case 0:
			{
				output[i] = random_num(48, 57);
			}
			case 1:
			{
				output[i] = random_num(65, 90);
			}
			case 2:
			{
				output[i] = random_num(97, 122);
			}
			default:
			{
			}
		}
		i++;
	}
	return 0;
}

QCC(id, iCVar)
{
	static iData[1];
	iData[0] = iCVar;
	query_client_cvar(id, g_szClientCVars[iCVar], "QCC_Result", 1, iData);
	return 0;
}

public QCC_Result(id, szCVar[], szValue[], iData[])
{
	if (!equal(szValue, "Bad CVAR request"))
	{
		g_eClientCVar[id][iData[0]] = str_to_float(szValue);
	}
	return 0;
}

ResetClientCVars(id)
{
	arrayset(g_eClientCVar[id], 0, 10);
	return 0;
}

CheckBhop(id)
{
	new FOG = g_ePlayer[id][FOG_current];
	if (FOG == 1)
	{
		g_eBhopChecker[id][bhcStartDuckState] = g_ePlayer[id][e_PlayerFlags] & 16384;
	}
	new var5;
	if (g_ePlayer[id][4] || (g_ePlayer[id][e_jumped] && ((FOG == 1 && g_ePlayer[id][AirFrames_old] >= 3) || (FOG > 1 && FOG <= 5))))
	{
		if (containi(sz_plugin_block_modules, "b") != -1)
		{
			client_cmd(id, "-jump;BC_BLOCK");
		}
		
		g_eBhopStats[id][0][BHOPS]++;
		g_eBhopStats[id][1][BHOPS]++;
		if (!g_ePlayer[id][4])
		{
			new var6;
			if (!g_eBhopChecker[id][bhcStartDuckState] && ~g_ePlayer[id][ucButtons] & IN_DUCK)
			{
				g_eBhopStats[id][0]++;
				g_eBhopStats[id][1]++;
			}
			new var7;
			if (g_eBhopChecker[id][bhcStartDuckState] && ~g_ePlayer[id][ucButtons] & IN_DUCK)
			{
				g_eBhopStats[id][0][1]++;
				g_eBhopStats[id][1][1]++;
			}
			new var8;
			if (g_eBhopChecker[id][bhcStartDuckState] && g_ePlayer[id][ucButtons] & IN_DUCK)
			{
				g_eBhopStats[id][0][2]++;
				g_eBhopStats[id][1][2]++;
			}
		}
		g_eBhopStats[id][0][4][FOG]++;
		g_eBhopStats[id][1][4][FOG]++;
		if (FOG <= 2)
		{
			g_eBhopStats[id][0][10][FOG]++;
			g_eBhopStats[id][1][10][FOG]++;
			if (g_eBhopStats[id][0][10][FOG] > g_eBhopStats[id][0][13][FOG])
			{
				g_eBhopStats[id][0][13][FOG] = g_eBhopStats[id][0][10][FOG];
			}
			if (g_eBhopStats[id][1][10][FOG] > g_eBhopStats[id][1][13][FOG])
			{
				g_eBhopStats[id][1][13][FOG] = g_eBhopStats[id][1][10][FOG];
			}
			g_eBhopStats[id][0][IAR1N2]++;
			g_eBhopStats[id][1][IAR1N2]++;
			if (g_eBhopStats[id][0][IAR1N2] > g_eBhopStats[id][0][WHIO3FOG])
			{
				g_eBhopStats[id][0][WHIO3FOG] = g_eBhopStats[id][0][IAR1N2];
			}
			if (g_eBhopStats[id][1][IAR1N2] > g_eBhopStats[id][1][WHIO3FOG])
			{
				g_eBhopStats[id][1][WHIO3FOG] = g_eBhopStats[id][1][IAR1N2];
			}
		}
		else
		{
			g_eBhopStats[id][0][IAR1N2] = 0;
			g_eBhopStats[id][1][IAR1N2] = 0;
		}
		new PrevFOG = g_eBhopChecker[id][bhcPreviousFog];
		new var10;
		if (PrevFOG <= 2 && (FOG >= 3 || PrevFOG == FOG))
		{
			g_eBhopStats[id][0][10][PrevFOG] = 0;
			g_eBhopStats[id][1][10][PrevFOG] = 0;
		}
		g_eBhopChecker[id][bhcPreviousFog] = FOG;
		if (!g_ePlayer[id][4])
		{
			if (g_eBhopChecker[id][bhcIdealCandidate])
			{
				g_eBhopStats[id][0][BHOP_IDEAL]++;
				g_eBhopStats[id][1][BHOP_IDEAL]++;
				if (FOG <= 2)
				{
					g_eBhopStats[id][0][BHOP_IDEAL]++;
					g_eBhopStats[id][1][BHOP_IDEAL]++;
				}
				g_eBhopStats[id][0][19]++;
				g_eBhopStats[id][1][19]++;
				g_eBhopStats[id][0][21] = 0;
				g_eBhopStats[id][1][21] = 0;
				if (g_eBhopStats[id][0][19] > g_eBhopStats[id][0][BHOP_IDEAL_IAR])
				{
					g_eBhopStats[id][0][BHOP_IDEAL_IAR] = g_eBhopStats[id][0][19];
				}
				if (g_eBhopStats[id][1][19] > g_eBhopStats[id][1][BHOP_IDEAL_IAR])
				{
					g_eBhopStats[id][1][BHOP_IDEAL_IAR] = g_eBhopStats[id][1][19];
				}
			}
			g_eBhopStats[id][0][19] = 0;
			g_eBhopStats[id][1][19] = 0;
			g_eBhopStats[id][0][21]++;
			g_eBhopStats[id][1][21]++;
			if (g_eBhopStats[id][0][21] > g_eBhopStats[id][0][BHOP_NOT_IDEAL_IAR])
			{
				g_eBhopStats[id][0][BHOP_NOT_IDEAL_IAR] = g_eBhopStats[id][0][21];
			}
			if (g_eBhopStats[id][1][21] > g_eBhopStats[id][1][BHOP_NOT_IDEAL_IAR])
			{
				g_eBhopStats[id][1][BHOP_NOT_IDEAL_IAR] = g_eBhopStats[id][1][21];
			}
		}
		if (FOG == 3)
		{
			if (10 <= g_ePlayer[id][WithoutJumpCmdFrames_old])
			{
				g_eBhopStats[id][0][25]++;
				g_eBhopStats[id][1][25]++;
			}
			if (~g_eBhopChecker[id][bhcPreviousButtons] & 2)
			{
				g_eBhopStats[id][0][26]++;
				g_eBhopStats[id][1][26]++;
			}
			if (g_eBhopChecker[id][bhcPreviousButtons] & 2)
			{
				g_eBhopStats[id][0][27]++;
				g_eBhopStats[id][1][27]++;
			}
		}
		g_eBhopChecker[id][bhcReadyForPerfectChain] = 0;
		g_eBhopChecker[id][bhcWaitingForGap] = 1;
		g_eBhopChecker[id][bhcDistributionReady] = 1;
		g_eBhopChecker[id][bhcFailedChainWindow] = 1;
		g_eBhopChecker[id][bhcFastScrollGuard] = 1;
		g_eBhopChecker[id][bhcCollectPattern] = 1;
		g_eBhopChecker[id][bhcDebugPrintPending] = 1;
		g_eBhopChecker[id][bhcLastGroundSpeed] = g_ePlayer[id][37];
		g_eBhopChecker[id][bhcLastMaxSpeed] = g_ePlayer[id][38];
		arrayset(g_eBhopChecker[id][bhcPatternBuffer], 0, BHOP_PATTERN_BUFFER);
	}
	new var12;
	if (g_ePlayer[id][e_jumped] || (g_ePlayer[id][ucButtons] & IN_JUMP && g_ePlayer[id][27] < 2))
	{
		g_eBhopStats[id][0][28]++;
		g_eBhopStats[id][1][28]++;
		if (g_eBhopStats[id][0][28] > g_eBhopStats[id][0][29])
		{
			g_eBhopStats[id][0][29] = g_eBhopStats[id][0][28];
		}
		if (g_eBhopStats[id][1][28] > g_eBhopStats[id][1][29])
		{
			g_eBhopStats[id][1][29] = g_eBhopStats[id][1][28];
		}
	}
	else
	{
		if (5 <= g_ePlayer[id][WithoutJumpCmdFrames_current])
		{
			g_eBhopStats[id][0][28] = 0;
			g_eBhopStats[id][1][28] = 0;
		}
	}
	new var14;
	if ((g_ePlayer[id][5] || (g_ePlayer[id][FOG_old] <= 5 && g_ePlayer[id][3])) && (g_ePlayer[id][e_jumped] || (g_ePlayer[id][ucButtons] & IN_JUMP && g_ePlayer[id][27] < 5)))
	{
		g_eBhopStats[id][0][32]++;
		g_eBhopStats[id][1][32]++;
		if (g_eBhopChecker[id][bhcReadyForPerfectChain])
		{
			g_eBhopStats[id][0][30]++;
			g_eBhopStats[id][1][30]++;
		}
		if (g_eBhopChecker[id][bhcWaitingForGap])
		{
			g_eBhopStats[id][0][31]++;
			g_eBhopStats[id][1][31]++;
		}
	}
	new var18;
	if (g_eBhopChecker[id][bhcWaitingForGap] && g_ePlayer[id][WithoutJumpCmdFrames_current] >= 10)
	{
		g_eBhopChecker[id][bhcReadyForPerfectChain] = 1;
		g_eBhopChecker[id][bhcWaitingForGap] = 0;
	}
	new var19;
	if ((g_ePlayer[id][ucButtons] & IN_JUMP && ~g_ePlayer[id][oldButtons] & IN_JUMP) || (~g_ePlayer[id][ucButtons] & IN_JUMP && g_ePlayer[id][oldButtons] & IN_JUMP))
	{
		g_eBhopChecker[id][bhcJumpToggleCounter]++;
		new var24;
		if (g_eBhopChecker[id][bhcDistributionReady] && g_eBhopChecker[id][bhcJumpToggleCounter] >= 8 && (g_ePlayer[id][5] || (g_ePlayer[id][FOG_old] <= 5 && g_ePlayer[id][3])))
		{
			g_eBhopStats[id][0][33]++;
			g_eBhopStats[id][1][33]++;
			g_eBhopChecker[id][bhcDistributionReady] = 0;
			g_eBhopChecker[id][bhcJumpToggleCounter] = 0;
		}
	}
	else
	{
		g_eBhopChecker[id][bhcJumpToggleCounter] = 0;
	}
	if (g_eBhopChecker[id][bhcFailedChainWindow])
	{
		g_eBhopStats[id][0][34]++;
		g_eBhopStats[id][1][34]++;
		new var26;
		if (g_ePlayer[id][e_jumped] || (g_ePlayer[id][ucButtons] & IN_JUMP && g_ePlayer[id][27] < 5))
		{
			g_eBhopStats[id][0][35]++;
			g_eBhopStats[id][1][35]++;
		}
		if (10 <= g_ePlayer[id][WithoutJumpCmdFrames_current])
		{
			g_eBhopStats[id][0][34] -= 9;
			g_eBhopStats[id][1][34] -= 9;
			g_eBhopChecker[id][bhcFailedChainWindow] = 0;
		}
	}
	new var27;
	if (g_eBhopChecker[id][bhcFastScrollGuard] && g_ePlayer[id][ucButtons] & IN_JUMP && g_ePlayer[id][oldButtons] & IN_JUMP)
	{
		g_eBhopStats[id][0][FAST_SCROLLED]++;
		g_eBhopStats[id][1][FAST_SCROLLED]++;
		g_eBhopChecker[id][bhcFastScrollGuard] = 0;
	}
	new var28;
	if (containi(sz_plugin_modules_working, "p") == -1
	&& ~g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND
	&& g_ePlayer[id][e_jumped]
	&& g_ePlayer[id][ucButtons] & 16384
	&& ~g_ePlayer[id][oldButtons] & 16384)
	{
		g_eBhopStats[id][0][38]++;
		g_eBhopStats[id][1][38]++;
		client_cmd(id, "-alt1;BC_IN_ALT1");
	}
	if (g_eBhopChecker[id][bhcCollectPattern])
	{
		if (g_ePlayer[id][4])
		{
			add(g_eBhopChecker[id][bhcPatternBuffer], "%L", 69272, MaxClients);
		}
		if (strlen(g_eBhopChecker[id][bhcPatternBuffer]) < BHOP_PATTERN_MAX_LEN)
		{
			if (g_ePlayer[id][ucButtons] & IN_JUMP)
			{
				new var29;
				if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
				{
					var29 = 69280;
				}
				else
				{
					var29 = 69288;
				}
				add(g_eBhopChecker[id][bhcPatternBuffer], "%L", var29, MaxClients);
			}
			add(g_eBhopChecker[id][bhcPatternBuffer], "%L", 69296, MaxClients);
		}
		new var30;
		if (strlen(g_eBhopChecker[id][bhcPatternBuffer]) >= BHOP_PATTERN_MAX_LEN || g_ePlayer[id][WithoutJumpCmdFrames_current] >= 10)
		{
			new i = 19;
			while (0 < i)
			{
				if (equal(g_eBhopChecker[id][bhcPatternBuffer][i], 69304, MaxClients))
				{
					g_eBhopChecker[id][bhcPatternBuffer][i] = 0;
				}
				else
				{
					if (g_eBhopChecker[id][bhcPatternBuffer][i])
					{
						new PatternCount;
						if (TrieKeyExists(g_eBhopStats[id][0][69], g_eBhopChecker[id][bhcPatternBuffer]))
						{
							TrieGetCell(g_eBhopStats[id][0][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount);
						}
						else
						{
							g_eBhopStats[id][0][37]++;
						}
						PatternCount++;
						TrieSetCell(g_eBhopStats[id][0][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount, 1);
						PatternCount = 0;
						if (TrieKeyExists(g_eBhopStats[id][1][69], g_eBhopChecker[id][bhcPatternBuffer]))
						{
							TrieGetCell(g_eBhopStats[id][1][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount);
						}
						else
						{
							g_eBhopStats[id][1][37]++;
						}
						PatternCount++;
						TrieSetCell(g_eBhopStats[id][1][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount, 1);
						g_eBhopChecker[id][bhcCollectPattern] = 0;
					}
				}
				i--;
			}
			new PatternCount;
			if (TrieKeyExists(g_eBhopStats[id][0][69], g_eBhopChecker[id][bhcPatternBuffer]))
			{
				TrieGetCell(g_eBhopStats[id][0][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount);
			}
			else
			{
				g_eBhopStats[id][0][37]++;
			}
			PatternCount++;
			TrieSetCell(g_eBhopStats[id][0][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount, 1);
			PatternCount = 0;
			if (TrieKeyExists(g_eBhopStats[id][1][69], g_eBhopChecker[id][bhcPatternBuffer]))
			{
				TrieGetCell(g_eBhopStats[id][1][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount);
			}
			else
			{
				g_eBhopStats[id][1][37]++;
			}
			PatternCount++;
			TrieSetCell(g_eBhopStats[id][1][69], g_eBhopChecker[id][bhcPatternBuffer], PatternCount, 1);
			g_eBhopChecker[id][bhcCollectPattern] = 0;
		}
	}
	if (15 <= g_ePlayer[id][WithoutJumpCmdFrames_current])
	{
		new var31;
		if (plugin_bhop_stats && !g_eBhopChecker[id][bhcStatsUploaded] && g_eBhopStats[id][1][BHOPS] >= 300)
		{
			CalculateBhopStats(id, true);
			API_LogBhopStats(id);
			g_eBhopChecker[id][bhcStatsUploaded] = 1;
		}
		new var32;
		if (containi(sz_plugin_debug_mode, "b") != -1 && g_ePlayer[id][7] && g_eBhopChecker[id][bhcDebugPrintPending])
		{
			static Color;
			if (g_ePlayer[id][5])
			{
				Color = -1;
			}
			else
			{
				if (g_eBhopChecker[id][bhcIdealCandidate])
				{
					Color = -3;
				}
				Color = -2;
			}
			new var33;
			if (equal(g_eBhopChecker[id][bhcDebugMoveLabel], "jumpbug", MaxClients))
			{
				var33 = 0;
			}
			else
			{
				var33 = g_ePlayer[id][FOG_old];
			}
			client_print_color(id, Color, "\x04[DEBUG] \x01#\x03%i (%s)\x01, FOG: \x03%i\x01, Speed: \x03%.3f (%.3f)\x01, Pattern: \x03%s", g_eBhopStats[id][0][BHOPS], g_eBhopChecker[id][bhcDebugMoveLabel], var33, g_eBhopChecker[id][bhcLastGroundSpeed], g_eBhopChecker[id][bhcLastMaxSpeed], g_eBhopChecker[id][bhcPatternBuffer]);
			g_eBhopChecker[id][bhcDebugPrintPending] = 0;
		}
	}
	if (!g_bPunished[id][0])
	{
		new bool:Phase[17];
		new bool:Instant[17];
		new bool:IncreasePhase;
		Phase[0] = g_eBhopStats[id][0][13] >= 4;
		Phase[1] = g_eBhopStats[id][0][14] >= 15;
		Phase[2] = g_eBhopStats[id][0][15] >= 15;
		Phase[3] = g_eBhopStats[id][0][BHOP_IDEAL_IAR] >= 17;
		Phase[4] = g_eBhopStats[id][0][29] >= 150;
		Phase[5] = g_eBhopStats[id][0][38] >= 3;
		Instant[0] = g_eBhopStats[id][1][13] >= 6;
		Instant[1] = g_eBhopStats[id][1][14] >= 20;
		Instant[2] = g_eBhopStats[id][1][15] >= 20;
		Instant[3] = g_eBhopStats[id][1][BHOP_IDEAL_IAR] >= 19;
		Instant[4] = g_eBhopStats[id][1][29] >= 200;
		Instant[5] = g_eBhopStats[id][1][38] >= 5;
		if (100 <= g_eBhopStats[id][0][BHOPS])
		{
			CalculateBhopStats(id, false);
			Phase[6] = g_eBhopStats[id][0][FOG0_P] >= 1103626240;
			Phase[7] = g_eBhopStats[id][0][FOG1_P] >= 1115815936;
			Phase[8] = g_eBhopStats[id][0][FOG2_P] >= 1115815936;
			Phase[9] = g_eBhopStats[id][0][BHOP_IDEAL_P] >= 1115815936;
			new var34;
			Phase[10] = g_eBhopStats[id][0][58] >= 1118437376 && g_eBhopStats[id][0][FAST_SCROLLED] <= 5;
			new var35;
			Phase[11] = g_eBhopStats[id][0][BHOP_FOG3] <= 3 && g_eBhopStats[id][0][57] <= 3.0;
			new var36;
			Phase[12] = g_eBhopStats[id][0][BHOP_FOG3] <= 3 && g_eBhopStats[id][0][57] >= 1082130432 && g_eBhopStats[id][0][58] <= 1103626240;
			new var37;
			Phase[13] = g_eBhopStats[id][0][BHOP_FOG3] <= 3 && g_eBhopStats[id][0][FAST_SCROLLED] <= 3;
			new var38;
			Phase[15] = g_eBhopStats[id][0][55] >= 1.0 && g_eBhopStats[id][0][56] >= 1080033280 && g_eBhopStats[id][0][37] <= 16 && g_eBhopStats[id][0][BHOP_IDEAL_P] >= 1109393408 && floatadd(g_eBhopStats[id][0][FOG1_P], g_eBhopStats[id][0][FOG2_P]) >= 1118175232 && g_eBhopStats[id][0][51] >= 1103626240 && g_eBhopStats[id][0][58] >= 1092616192;
			Instant[6] = g_eBhopStats[id][0][FOG0_P] >= 30.0;
			Instant[7] = g_eBhopStats[id][0][FOG1_P] >= 1116471296;
			Instant[8] = g_eBhopStats[id][0][FOG2_P] >= 1116471296;
			Instant[9] = g_eBhopStats[id][0][BHOP_IDEAL_P] >= 1116471296;
			new var39;
			Instant[10] = g_eBhopStats[id][0][58] >= 1119092736 && g_eBhopStats[id][0][FAST_SCROLLED] <= 3;
			new var40;
			Instant[11] = g_eBhopStats[id][0][BHOP_FOG3] <= 1 && g_eBhopStats[id][0][57] <= 1075838976;
			new var41;
			Instant[12] = g_eBhopStats[id][0][BHOP_FOG3] <= 1 && g_eBhopStats[id][0][57] >= 1082130432 && g_eBhopStats[id][0][58] <= 1101004800;
			new var42;
			Instant[13] = g_eBhopStats[id][0][BHOP_FOG3] <= 1 && g_eBhopStats[id][0][FAST_SCROLLED];
			new var43;
			if (g_eBhopStats[id][0][55] >= 1060320051 && g_eBhopStats[id][0][56] >= 1080033280 && g_eBhopStats[id][0][37] <= 13 && g_eBhopStats[id][0][BHOP_IDEAL_P] >= 1112014848 && floatadd(g_eBhopStats[id][0][FOG1_P], g_eBhopStats[id][0][FOG2_P]) >= 1118830592 && g_eBhopStats[id][0][51] >= 30.0 && g_eBhopStats[id][0][58] >= 1097859072)
			{
			}
		}
		new var44;
		if (g_eBhopStats[id][1][BHOPS] >= 250 && g_eBhopStats[id][1][BHOPS] % 25)
		{
			CalculateBhopStats(id, true);
			new var45;
			Phase[16] = g_eBhopStats[id][1][BHOP_FOG3] <= 7 && g_eBhopStats[id][1][58] <= 1114636288;
			new var46;
			if (g_eBhopStats[id][1][BHOP_FOG3] <= 5 && g_eBhopStats[id][1][58] <= 1112014848)
			{
			}
		}
		new i;
		while (i < 17)
		{
			if (Phase[i])
			{
				g_eBhopChecker[id][bhcPhase]++;
				g_eBhopChecker[id][bhcPunishmentReason] = i;
				IncreasePhase = true;
				new i;
				while (i < 17)
				{
					if (Instant[i])
					{
						g_eBhopChecker[id][bhcPhase] = 2;
						g_eBhopChecker[id][bhcPunishmentReason] = i;
						new var47;
						if (g_eBhopChecker[id][bhcPhase] >= 2 || IncreasePhase)
						{
							CalculateBhopStats(id, false);
							CalculateBhopStats(id, true);
							static szLog[768];
							FormatLogText(id, szLog, 767);
							format(szLog, 767, "[#%i] %s ::: %s", g_eBhopChecker[id][bhcPunishmentReason], PunishmentReason[g_eBhopChecker[id][bhcPunishmentReason]], szLog);
							if (g_eBhopChecker[id][bhcPhase] >= 2)
							{
								PunishClient(id, 0, "b", szLog);
							}
							else
							{
								new var48;
								if (IncreasePhase && containi(sz_plugin_punish_modules, "b") != -1)
								{
									PunishClient(id, 1, "b", szLog);
								}
							}
							ResetBhop(id, true, false);
						}
					}
					i++;
				}
				new var47;
				if (g_eBhopChecker[id][bhcPhase] >= 2 || IncreasePhase)
				{
					CalculateBhopStats(id, false);
					CalculateBhopStats(id, true);
					static szLog[768];
					FormatLogText(id, szLog, 767);
					format(szLog, 767, "[#%i] %s ::: %s", g_eBhopChecker[id][bhcPunishmentReason], PunishmentReason[g_eBhopChecker[id][bhcPunishmentReason]], szLog);
					if (2 <= g_eBhopChecker[id][bhcPhase])
					{
						PunishClient(id, 0, "b", szLog);
					}
					else
					{
						new var48;
						if (IncreasePhase && containi(sz_plugin_punish_modules, "b") != -1)
						{
							PunishClient(id, 1, "b", szLog);
						}
					}
					ResetBhop(id, true, false);
				}
			}
			i++;
		}
		
		new i;
		while (i < 17)
		{
			if (Instant[i])
			{
				g_eBhopChecker[id][bhcPhase] = 2;
				g_eBhopChecker[id][bhcPunishmentReason] = i;
				new var47;
				if (g_eBhopChecker[id][bhcPhase] >= 2 || IncreasePhase)
				{
					CalculateBhopStats(id, false);
					CalculateBhopStats(id, true);
					static szLog[768];
					FormatLogText(id, szLog, 767);
					format(szLog, 767, "[#%i] %s ::: %s", g_eBhopChecker[id][bhcPunishmentReason], PunishmentReason[g_eBhopChecker[id][bhcPunishmentReason]], szLog);
					if (2 <= g_eBhopChecker[id][bhcPhase])
					{
						PunishClient(id, 0, "b", szLog);
					}
					else
					{
						new var48;
						if (IncreasePhase && containi(sz_plugin_punish_modules, "b") != -1)
						{
							PunishClient(id, 1, "b", szLog);
						}
					}
					ResetBhop(id, true, false);
				}
			}
			i++;
		}
		new var47;
		if (g_eBhopChecker[id][bhcPhase] >= 2 || IncreasePhase)
		{
			CalculateBhopStats(id, false);
			CalculateBhopStats(id, true);
			static szLog[768];
			FormatLogText(id, szLog, 767);
			format(szLog, 767, "[#%i] %s ::: %s", g_eBhopChecker[id][bhcPunishmentReason], PunishmentReason[g_eBhopChecker[id][bhcPunishmentReason]], szLog);
			if (2 <= g_eBhopChecker[id][bhcPhase])
			{
				PunishClient(id, 0, "b", szLog);
			}
			else
			{
				new var48;
				if (IncreasePhase && containi(sz_plugin_punish_modules, "b") != -1)
				{
					PunishClient(id, 1, "b", szLog);
				}
			}
			ResetBhop(id, true, false);
		}
	}
	if (100 <= g_eBhopStats[id][0][BHOPS])
	{
		ResetBhop(id, false, false);
	}
	g_eBhopChecker[id][bhcPreviousButtons] = g_ePlayer[id][oldButtons];
	return 0;
}

CalculateBhopStats(id, bool:bTotal)
{
	decl Type;
	new var1;
	if (bTotal)
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	Type = var1;
	new i;
	while (i < 3)
	{
		g_eBhopStats[id][Type][40][i] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][i]), float(g_eBhopStats[id][Type][BHOPS])));
		i++;
	}
	new i;
	while (i < 6)
	{
		g_eBhopStats[id][Type][FOG0_P][i] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][4][i]), float(g_eBhopStats[id][Type][BHOPS])));
		i++;
	}
	g_eBhopStats[id][Type][BHOP_IDEAL_P] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][BHOP_IDEAL]), float(g_eBhopStats[id][Type][BHOPS])));
	new i = 1;
	while (i < 3)
	{
		g_eBhopStats[id][Type][BHOP_IDEAL_P][i] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][BHOP_IDEAL][i]), float(g_eBhopStats[id][Type][4][i])));
		i++;
	}
	new i;
	while (i < 3)
	{
		g_eBhopStats[id][Type][52][i] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][25][i]), float(g_eBhopStats[id][Type][BHOP_FOG3])));
		i++;
	}
	new i;
	while (i < 3)
	{
		g_eBhopStats[id][Type][55][i] = floatdiv(float(g_eBhopStats[id][Type][30][i]), float(g_eBhopStats[id][Type][BHOPS]));
		i++;
	}
	g_eBhopStats[id][Type][58] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][33]), float(g_eBhopStats[id][Type][BHOPS])));
	g_eBhopStats[id][Type][59] = floatdiv(float(g_eBhopStats[id][Type][34]), float(g_eBhopStats[id][Type][35]));
	g_eBhopStats[id][Type][FAST_SCROLLED_P] = floatmul(1120403456, floatdiv(float(g_eBhopStats[id][Type][FAST_SCROLLED]), float(g_eBhopStats[id][Type][BHOPS])));
	if (0 < g_eBhopStats[id][Type][BHOPS])
	{
		new Float:IdealRatio = floatdiv(float(g_eBhopStats[id][Type][BHOP_IDEAL]), float(g_eBhopStats[id][Type][BHOPS]));
		new Float:ThreeFogRatio = floatdiv(float(g_eBhopStats[id][Type][BHOP_FOG3]), float(g_eBhopStats[id][Type][BHOPS]));
		new Float:FourFogRatio = floatdiv(float(g_eBhopStats[id][Type][BHOP_FOG4]), float(g_eBhopStats[id][Type][BHOPS]));
		new Float:FiveFogRatio = floatdiv(float(g_eBhopStats[id][Type][BHOP_FOG5]), float(g_eBhopStats[id][Type][BHOPS]));
		g_eBhopStats[id][Type][BHOP_SKILL] = floatround(floatadd(1147207680, floatmul(1148846080, floatsub(floatsub(floatsub(floatmul(1036831949, IdealRatio), floatmul(1056964608, ThreeFogRatio)), floatmul(1060823368, FourFogRatio)), floatmul(1063675494, FiveFogRatio)))), MaxClients);
	}
	static Float:CoincidenceBhopsPerc;
	static Float:CoincidencePatternsPerc;
	static Count;
	static CoincidenceBhops;
	static CoincidencePatterns;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 5)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_HackHack[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_HackHack[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][61] = floatadd(CoincidencePatternsPerc, CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 5)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v1[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v1[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][62] = floatadd(CoincidencePatternsPerc, CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 45)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v2a[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v2a[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][63] = floatadd(CoincidencePatternsPerc, CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 22)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v2b[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v2b[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][64] = floatadd(CoincidencePatternsPerc, CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 12)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v3[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v3[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][65] = floatadd(CoincidencePatternsPerc, CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 12)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v4[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_XTREMEHACK_v4[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][66] = (CoincidencePatternsPerc + CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 12)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_FuriousHack_v3[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_FuriousHack_v3[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][67] = (CoincidencePatternsPerc + CoincidenceBhopsPerc) / 2;
	CoincidencePatterns = 0;
	CoincidenceBhops = 0;
	Count = 0;
	new Pattern;
	while (Pattern < 5)
	{
		if (TrieKeyExists(g_eBhopStats[id][Type][69], PS_FlatCheat[Pattern]))
		{
			TrieGetCell(g_eBhopStats[id][Type][69], PS_FlatCheat[Pattern], Count);
			CoincidencePatterns += 1;
			CoincidenceBhops = Count + CoincidenceBhops;
		}
		Pattern++;
	}
	CoincidencePatternsPerc = 100.0 * float(CoincidencePatterns) / float(g_eBhopStats[id][Type][37]);
	CoincidenceBhopsPerc = 100.0 * float(CoincidenceBhops) / float(g_eBhopStats[id][Type][BHOPS]);
	g_eBhopStats[id][Type][68] = floatadd(CoincidencePatternsPerc, CoincidenceBhopsPerc) / 2;
	return 0;
}

FormatLogText(id, szOutput[], iSize)
{
	formatex(szOutput, iSize, "Bhops: %i/%i, 0 FOG: %i|%i (%.2f%%%%), 1 FOG: %i|%i (%.2f%%%%, %.2f%%%%), 2 FOG: %i|%i (%.2f%%%%, %.2f%%%%), 3 FOG: %i/%i (%.2f%%%%) { %i, %i, %i }", g_eBhopStats[id][0][BHOPS], g_eBhopStats[id][1][BHOPS], g_eBhopStats[id][0][4], g_eBhopStats[id][1][13], g_eBhopStats[id][0][FOG0_P], g_eBhopStats[id][0][5], g_eBhopStats[id][1][14], g_eBhopStats[id][0][FOG1_P], g_eBhopStats[id][0][50], g_eBhopStats[id][0][6], g_eBhopStats[id][1][15], g_eBhopStats[id][0][FOG2_P], g_eBhopStats[id][0][51], g_eBhopStats[id][0][BHOP_FOG3], g_eBhopStats[id][1][BHOP_FOG3], g_eBhopStats[id][0][FOG3_P], g_eBhopStats[id][0][25], g_eBhopStats[id][0][26], g_eBhopStats[id][0][27]);
	format(szOutput, iSize, "%s, Max. bhops without 3 FOG: %i", szOutput, g_eBhopStats[id][1][WHIO3FOG]);
	format(szOutput, iSize, "%s, 4 FOG: %i/%i (%.2f%%%%), 5 FOG: %i/%i (%.2f%%%%), Ideal bhops: %i|%i (%.2f%%%%), Failed bhops in a row: %i, Ideally distr. bhops: %i (%.2f%%%%)", szOutput, g_eBhopStats[id][0][BHOP_FOG4], g_eBhopStats[id][1][BHOP_FOG4], g_eBhopStats[id][0][FOG4_P], g_eBhopStats[id][0][BHOP_FOG5], g_eBhopStats[id][1][BHOP_FOG5], g_eBhopStats[id][0][FOG5_P], g_eBhopStats[id][0][BHOP_IDEAL], g_eBhopStats[id][1][BHOP_IDEAL_IAR], g_eBhopStats[id][0][BHOP_IDEAL_P], g_eBhopStats[id][1][BHOP_NOT_IDEAL_IAR], g_eBhopStats[id][0][33], g_eBhopStats[id][0][58]);
	format(szOutput, iSize, "%s, Jump cmds ratio: %.2f (%.2f) %.2f, Jump cmds in a row: %i, Jump cmds timing: %.2f, Jump cmds IN_ALT1: %i, Too fast scrolled bhops: %i (%.2f%%%%), Unique patterns: %i", szOutput, g_eBhopStats[id][0][55], g_eBhopStats[id][0][57], g_eBhopStats[id][0][56], g_eBhopStats[id][1][29], g_eBhopStats[id][0][59], g_eBhopStats[id][1][38], g_eBhopStats[id][0][FAST_SCROLLED], g_eBhopStats[id][0][FAST_SCROLLED_P], g_eBhopStats[id][0][37]);
	format(szOutput, iSize, "%s, Cheat patterns: { HackHack: %.f%%%%, XH v1: %.f%%%%, XH v2a: %.f%%%%, XH v2b: %.f%%%%, XH v3: %.f%%%%, XH v4: %.f%%%%, FSH v3: %.f%%%%, FC: %.f%%%% }", szOutput, g_eBhopStats[id][0][61], g_eBhopStats[id][0][62], g_eBhopStats[id][0][63], g_eBhopStats[id][0][64], g_eBhopStats[id][0][65], g_eBhopStats[id][0][66], g_eBhopStats[id][0][67], g_eBhopStats[id][0][68]);
	return 0;
}

ResetBhop(id, bool:bFullReset, bool:bTotalReset)
{
	g_eBhopChecker[id][bhcJumpToggleCounter] = 0;
	g_eBhopStats[id][0][33] = 0;
	g_eBhopStats[id][0][34] = 0;
	g_eBhopStats[id][0][35] = 0;
	g_eBhopStats[id][0][FAST_SCROLLED] = 0;
	g_eBhopStats[id][0][37] = 0;
	g_eBhopStats[id][0][38] = 0;
	g_eBhopStats[id][0][BHOP_SKILL] = 0;
	g_eBhopStats[id][0][BHOP_NOT_IDEAL_IAR] = 0;
	g_eBhopStats[id][0][WHIO3FOG] = 0;
	g_eBhopStats[id][0][58] = 0;
	g_eBhopStats[id][0][59] = 0;
	g_eBhopStats[id][0][FAST_SCROLLED_P] = 0;
	arrayset(g_eBhopStats[id][0], MaxClients, NULL_STRING);
	arrayset(g_eBhopStats[id][0][4], MaxClients, 6);
	arrayset(g_eBhopStats[id][0][BHOP_IDEAL], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][25], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][30], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][40], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][FOG0_P], MaxClients, 6);
	arrayset(g_eBhopStats[id][0][BHOP_IDEAL_P], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][52], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][55], MaxClients, 3);
	arrayset(g_eBhopStats[id][0][61], MaxClients, NULL_VECTOR);
	if (g_eBhopStats[id][0][69])
	{
		TrieClear(g_eBhopStats[id][0][69]);
	}
	if (bFullReset)
	{
		g_eBhopChecker[id][bhcStartDuckState] = 0;
		g_eBhopChecker[id][bhcReadyForPerfectChain] = 0;
		g_eBhopChecker[id][bhcWaitingForGap] = 0;
		g_eBhopChecker[id][bhcDistributionReady] = 0;
		g_eBhopChecker[id][bhcFailedChainWindow] = 0;
		g_eBhopChecker[id][bhcFastScrollGuard] = 0;
		g_eBhopChecker[id][bhcCollectPattern] = 0;
		g_eBhopChecker[id][bhcDebugPrintPending] = 0;
		g_eBhopChecker[id][bhcPreviousFog] = 0;
		g_eBhopChecker[id][bhcPreviousButtons] = 0;
		g_eBhopStats[id][0][19] = 0;
		g_eBhopStats[id][0][BHOP_IDEAL_IAR] = 0;
		g_eBhopStats[id][0][28] = 0;
		g_eBhopStats[id][0][29] = 0;
		g_eBhopChecker[id][bhcLastGroundSpeed] = 0;
		g_eBhopChecker[id][bhcLastMaxSpeed] = 0;
		arrayset(g_eBhopChecker[id][bhcPatternBuffer], 0, BHOP_PATTERN_BUFFER);
		arrayset(g_eBhopChecker[id][bhcDebugMoveLabel], 0, BHOP_DEBUG_LABEL_LEN);
		arrayset(g_eBhopStats[id][0][10], 0, 3);
		arrayset(g_eBhopStats[id][0][13], 0, 3);
	}
	if (bTotalReset)
	{
		g_eBhopChecker[id][bhcIdealCandidate] = 0;
		g_eBhopChecker[id][bhcStatsUploaded] = 0;
		g_eBhopChecker[id][bhcPhase] = 0;
		g_eBhopChecker[id][bhcPunishmentReason] = 0;
		g_eBhopStats[id][1][19] = 0;
		g_eBhopStats[id][1][BHOP_IDEAL_IAR] = 0;
		g_eBhopStats[id][1][28] = 0;
		g_eBhopStats[id][1][29] = 0;
		g_eBhopStats[id][1][BHOP_NOT_IDEAL_IAR] = 0;
		g_eBhopStats[id][1][WHIO3FOG] = 0;
		g_eBhopStats[id][1][33] = 0;
		g_eBhopStats[id][1][34] = 0;
		g_eBhopStats[id][1][35] = 0;
		g_eBhopStats[id][1][FAST_SCROLLED] = 0;
		g_eBhopStats[id][1][37] = 0;
		g_eBhopStats[id][1][38] = 0;
		g_eBhopStats[id][1][BHOP_SKILL] = 0;
		g_eBhopStats[id][1][58] = 0;
		g_eBhopStats[id][1][59] = 0;
		g_eBhopStats[id][1][FAST_SCROLLED_P] = 0;
		arrayset(g_eBhopStats[id][1], 0, NULL_STRING);
		arrayset(g_eBhopStats[id][1][4], 0, 6);
		arrayset(g_eBhopStats[id][1][10], 0, 3);
		arrayset(g_eBhopStats[id][1][13], 0, 3);
		arrayset(g_eBhopStats[id][1][BHOP_IDEAL], 0, 3);
		arrayset(g_eBhopStats[id][1][25], 0, 3);
		arrayset(g_eBhopStats[id][1][30], 0, 3);
		arrayset(g_eBhopStats[id][1][40], 0, 3);
		arrayset(g_eBhopStats[id][1][FOG0_P], 0, 6);
		arrayset(g_eBhopStats[id][1][BHOP_IDEAL_P], 0, 3);
		arrayset(g_eBhopStats[id][1][52], 0, 3);
		arrayset(g_eBhopStats[id][1][55], 0, 3);
		arrayset(g_eBhopStats[id][1][61], 0, NULL_VECTOR);
		if (g_eBhopStats[id][1][69])
		{
			TrieClear(g_eBhopStats[id][1][69]);
		}
	}
	return 0;
}

CheckGstrafe(id)
{
	new var1;
	if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND
	&& g_ePlayer[id][FOG_current] <= 5
	&& g_ePlayer[id][e_ducked]
	&& ~g_ePlayer[id][e_PlayerFlags] & 16384)
	{
		g_eGstrafe[id][2]++;
		g_eGstrafeTotal[id][2]++;
		switch (g_ePlayer[id][FOG_current])
		{
			case 1:
			{
				g_eGstrafe[id][3]++;
				g_eGstrafe[id][8]++;
				g_eGstrafeTotal[id][8]++;
				if (g_eGstrafe[id][8] > g_eGstrafe[id][11])
				{
					g_eGstrafe[id][11] = g_eGstrafe[id][8];
				}
				if (g_eGstrafeTotal[id][8] > g_eGstrafeTotal[id][11])
				{
					g_eGstrafeTotal[id][11] = g_eGstrafeTotal[id][8];
				}
				g_eGstrafe[id][9] = 0;
				g_eGstrafeTotal[id][9] = 0;
				g_eGstrafe[id][10] = 0;
				g_eGstrafeTotal[id][10] = 0;
			}
			case 2:
			{
				g_eGstrafe[id][4]++;
				g_eGstrafe[id][9]++;
				g_eGstrafeTotal[id][9]++;
				if (g_eGstrafe[id][9] > g_eGstrafe[id][12])
				{
					g_eGstrafe[id][12] = g_eGstrafe[id][9];
				}
				if (g_eGstrafeTotal[id][9] > g_eGstrafeTotal[id][12])
				{
					g_eGstrafeTotal[id][12] = g_eGstrafeTotal[id][9];
				}
				g_eGstrafe[id][8] = 0;
				g_eGstrafeTotal[id][8] = 0;
				g_eGstrafe[id][10] = 0;
				g_eGstrafeTotal[id][10] = 0;
			}
			case 3:
			{
				g_eGstrafe[id][5]++;
				g_eGstrafe[id][10]++;
				g_eGstrafeTotal[id][10]++;
				if (g_eGstrafe[id][10] > g_eGstrafe[id][13])
				{
					g_eGstrafe[id][13] = g_eGstrafe[id][10];
				}
				if (g_eGstrafeTotal[id][10] > g_eGstrafeTotal[id][13])
				{
					g_eGstrafeTotal[id][13] = g_eGstrafeTotal[id][10];
				}
				g_eGstrafe[id][8] = 0;
				g_eGstrafeTotal[id][8] = 0;
				g_eGstrafe[id][9] = 0;
				g_eGstrafeTotal[id][9] = 0;
			}
			case 4:
			{
				g_eGstrafe[id][6]++;
				g_eGstrafe[id][8] = 0;
				g_eGstrafeTotal[id][8] = 0;
				g_eGstrafe[id][9] = 0;
				g_eGstrafeTotal[id][9] = 0;
				g_eGstrafe[id][10] = 0;
				g_eGstrafeTotal[id][10] = 0;
			}
			case 5:
			{
				g_eGstrafe[id][7]++;
				g_eGstrafe[id][8] = 0;
				g_eGstrafeTotal[id][8] = 0;
				g_eGstrafe[id][9] = 0;
				g_eGstrafeTotal[id][9] = 0;
				g_eGstrafe[id][10] = 0;
				g_eGstrafeTotal[id][10] = 0;
			}
			default:
			{
			}
		}
		new i;
		while (i < 5)
		{
			g_eGstrafe[id][18][i] = 100.0 * float(g_eGstrafe[id][3][i]) / float(g_eGstrafe[id][2]);
			i++;
		}
		new var2;
		if (containi(sz_plugin_debug_mode, "g") != -1 && g_ePlayer[id][7])
		{
			new var3;
			var3 = (g_eGstrafe[id][0]) ? 82212 : 82280;
			new var4;
			if (g_eGstrafe[id][1])
			{
				var4 = -3;
			}
			else
			{
				var4 = -2;
			}
			client_print_color(id, var4, "\x04[DEBUG] \x01#\x03%i (%s)\x01, FOG: \x03%i\x01, Speed: \x03%.3f", g_eGstrafe[id][2], var3, g_ePlayer[id][FOG_current], g_ePlayer[id][37]);
		}
	}
	if (3 <= g_ePlayer[id][FOG_current])
	{
		g_eGstrafe[id][8] = 0;
		g_eGstrafeTotal[id][8] = 0;
	}
	if (4 <= g_ePlayer[id][FOG_current])
	{
		g_eGstrafe[id][9] = 0;
		g_eGstrafeTotal[id][9] = 0;
	}
	if (5 <= g_ePlayer[id][FOG_current])
	{
		g_eGstrafe[id][10] = 0;
		g_eGstrafeTotal[id][10] = 0;
	}
	new var5;
	if (g_ePlayer[id][e_ducked] && g_ePlayer[id][FOG_old] <= 5 && g_ePlayer[id][3] == 1)
	{
		g_eGstrafe[id][14]++;
		g_eGstrafe[id][23] = floatdiv(float(g_eGstrafe[id][14]), float(g_eGstrafe[id][2]));
	}
	if (g_ePlayer[id][28])
	{
		if (4 <= g_ePlayer[id][28])
		{
			g_eGstrafe[id][15] = 0;
		}
	}
	else
	{
		g_eGstrafe[id][15]++;
		if (g_eGstrafe[id][15] > g_eGstrafe[id][16])
		{
			g_eGstrafe[id][16] = g_eGstrafe[id][15];
		}
	}
	decl bool:bOneFog;
	new var7;
	bOneFog = g_eGstrafe[id][11] >= 15 || (g_eGstrafe[id][2] >= 100 && g_eGstrafe[id][18] >= 75.0 && g_eGstrafe[id][11] >= 10);
	decl bool:bTwoFog;
	new var9;
	bTwoFog = g_eGstrafe[id][12] >= 15 || (g_eGstrafe[id][2] >= 100 && g_eGstrafe[id][19] >= 75.0 && g_eGstrafe[id][12] >= 10);
	new bool:bThreeFog = g_eGstrafe[id][13] >= 15;
	new bool:bOneFogInsta = g_eGstrafeTotal[id][11] >= 18;
	new bool:bTwoFogInsta = g_eGstrafeTotal[id][12] >= 18;
	new bool:bThreeFogInsta = g_eGstrafeTotal[id][13] >= 18;
	new var11;
	if (!g_bPunished[id][1] && (bOneFog || bTwoFog || bThreeFog || bOneFogInsta || bTwoFogInsta || bThreeFogInsta))
	{
		g_eGstrafe[id][gstrafe_phase]++;
		static szLog[256];
		formatex(szLog, 255, "Gstrafes: %i/%i, 1 FOG: %i|%i (%.2f%%%%), 2 FOG: %i|%i (%.2f%%%%), 3 FOG: %i|%i (%.2f%%%%), 4 FOG: %i (%.2f%%%%), 5 FOG: %i (%.2f%%%%)", g_eGstrafe[id][2], g_eGstrafeTotal[id][2], g_eGstrafe[id][3], g_eGstrafeTotal[id][11], g_eGstrafe[id][18], g_eGstrafe[id][4], g_eGstrafeTotal[id][12], g_eGstrafe[id][19], g_eGstrafe[id][5], g_eGstrafeTotal[id][13], g_eGstrafe[id][20], g_eGstrafe[id][6], g_eGstrafe[id][21], g_eGstrafe[id][7], g_eGstrafe[id][22]);
		format(szLog, 255, "%s, Duck cmds ratio: %.2f, Duck cmds in a row: %i", szLog, g_eGstrafe[id][23], g_eGstrafe[id][16]);
		new var12;
		if (g_eGstrafe[id][gstrafe_phase] >= 3 || bOneFogInsta || bTwoFogInsta || bThreeFogInsta)
		{
			PunishClient(id, 0, "g", szLog);
		}
		if (containi(sz_plugin_punish_modules, "g") != -1)
		{
			PunishClient(id, 1, "g", szLog);
		}
		ResetGstrafe(id, 1, 0);
	}
	if (100 <= g_eGstrafe[id][2])
	{
		ResetGstrafe(id, 0, 0);
	}
	return 0;
}

ResetGstrafe(id, bFull, bResetTotal)
{
	g_eGstrafe[id][2] = 0;
	g_eGstrafe[id][14] = 0;
	g_eGstrafe[id][23] = 0;
	arrayset(g_eGstrafe[id][3], 0, 5);
	arrayset(g_eGstrafe[id][18], 0, 5);
	if (bFull)
	{
		g_eGstrafe[id][0] = 0;
		g_eGstrafe[id][1] = 0;
		g_eGstrafe[id][15] = 0;
		g_eGstrafe[id][16] = 0;
		arrayset(g_eGstrafe[id][8], 0, 3);
		arrayset(g_eGstrafe[id][11], 0, 3);
	}
	if (bResetTotal)
	{
		g_eGstrafe[id][gstrafe_phase] = 0;
		g_eGstrafeTotal[id][2] = 0;
		arrayset(g_eGstrafeTotal[id][8], 0, 3);
		arrayset(g_eGstrafeTotal[id][11], 0, 3);
	}
	return 0;
}

CheckJumpbug(id)
{
	if (g_ePlayer[id][4])
	{
		g_eJumpbug[id][3]++;
		g_eJumpbug[id][29] = floatsub(g_eJumpbug[id][28], g_ePlayer[id][FOG2_P]);
		new var2;
		if (!g_bPunished[id][2]
		&& g_ePlayer[id][30] == 1
		&& (abs(g_ePlayer[id][e_msec] - g_ePlayer[id][e_msec_old]) >= 30 || g_ePlayer[id][e_msec_old] <= 1))
		{
			g_eJumpbug[id][jumpbug_phase]++;
			new Num = g_eJumpbug[id][jumpbug_phase] - 1;
			g_eJumpbug[id][5][Num] = g_ePlayer[id][e_playerFPS];
			g_eJumpbug[id][15][Num] = g_ePlayer[id][emulated_fps];
			g_eJumpbug[id][30][Num] = g_eJumpbug[id][29];
			if (g_eJumpbug[id][jumpbug_phase] == 5)
			{
				QCC(id, 0);
				QCC(id, 1);
			}
			static szLog[384];
			if (containi(sz_plugin_punish_modules, "j") != -1)
			{
				GenerateDetailedJumpbugLog(id, szLog, 383);
				PunishClient(id, 1, "j", szLog);
			}
			if (10 <= g_eJumpbug[id][jumpbug_phase])
			{
				GenerateJumpbugLog(id, szLog, 383);
				PunishClient(id, 0, "j", szLog);
			}
		}
		new var3;
		if (containi(sz_plugin_debug_mode, "j") != -1 && g_ePlayer[id][7])
		{
			client_print_color(id, -2, "\x04[DEBUG] \x01Jumpbug height: \x03%.3f\x01, FPS: \x03%i\x01, Msec: \x03%i\x01, Jump frames: \x03%i", g_eJumpbug[id][29], g_ePlayer[id][e_playerFPS], g_ePlayer[id][e_msec_old], g_ePlayer[id][30]);
		}
		g_eJumpbug[id][2] = 0;
	}
	new var4;
	g_eJumpbug[id][0] = g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND || g_ePlayer[id][12] == 5 || g_ePlayer[id][4];
	new var5;
	if (!g_eJumpbug[id][0] && g_eJumpbug[id][1])
	{
		g_eJumpbug[id][2] = 1;
		g_eJumpbug[id][28] = 0;
	}
	if (g_eJumpbug[id][2])
	{
		new var6;
		if (0 == g_eJumpbug[id][28] || g_eJumpbug[id][28] < g_eJumpbug[id][27])
		{
			g_eJumpbug[id][28] = g_eJumpbug[id][27];
		}
	}
	g_eJumpbug[id][1] = g_eJumpbug[id][0];
	new i;
	while (i < 3)
	{
		g_eJumpbug[id][25][i] = g_ePlayer[id][e_origin][i];
		i++;
	}
	return 0;
}

GenerateDetailedJumpbugLog(id, szOutput[], iSize)
{
	static szGameTime[12];
	GetGameTime(szGameTime, 11, 1);
	formatex(szOutput, iSize, "#%i/%i\x09<%s> : Height: %.3f, FPS: %i, Msec: %i, Emulated FPS: %i", g_eJumpbug[id][jumpbug_phase], g_eJumpbug[id][3], szGameTime, g_eJumpbug[id][29], g_ePlayer[id][e_playerFPS], g_ePlayer[id][e_msec_old], g_ePlayer[id][emulated_fps]);
	return 0;
}

GenerateJumpbugLog(id, szOutput[], iSize)
{
	formatex(szOutput, iSize, "Illegal jumpbugs: %i/%i", g_eJumpbug[id][jumpbug_phase], g_eJumpbug[id][3]);
	new i;
	while (i < 10)
	{
		if (i)
		{
			format(szOutput, iSize, "%s, %i", szOutput, g_eJumpbug[id][5][i]);
			if (i == 9)
			{
				add(szOutput, iSize, " }", MaxClients);
			}
		}
		else
		{
			format(szOutput, iSize, "%s, FPS: { %i", szOutput, g_eJumpbug[id][5][i]);
		}
		i++;
	}
	new i;
	while (i < 10)
	{
		if (i)
		{
			format(szOutput, iSize, "%s, %i", szOutput, g_eJumpbug[id][15][i]);
			if (i == 9)
			{
				add(szOutput, iSize, " }", MaxClients);
			}
		}
		else
		{
			format(szOutput, iSize, "%s, Emulated FPS: { %i", szOutput, g_eJumpbug[id][15][i]);
		}
		i++;
	}
	new i;
	while (i < 10)
	{
		if (i)
		{
			format(szOutput, iSize, "%s, %.3f", szOutput, g_eJumpbug[id][30][i]);
			if (i == 9)
			{
				add(szOutput, iSize, " }", MaxClients);
			}
		}
		else
		{
			format(szOutput, iSize, "%s, Height: { %.3f", szOutput, g_eJumpbug[id][30][i]);
		}
		i++;
	}
	format(szOutput, iSize, "%s, fps_max: %.3f, fps_override: %.3f", szOutput, g_eClientCVar[id], g_eClientCVar[id][1]);
	return 0;
}

ResetJumpbug(id)
{
	arrayset(g_eJumpbug[id], MaxClients, 40);
	return 0;
}

CheckMoves(id)
{
	if (g_ePlayer[id][MaxSpeed_current] <= 200.0)
	{
		return 0;
	}

	new Float:forwardIntent = (CL_KeyState(id, IN_FORWARD) - CL_KeyState(id, IN_BACK)) * 400.0;
	new Float:sideIntent = (CL_KeyState(id, IN_MOVERIGHT) - CL_KeyState(id, IN_MOVELEFT)) * 400.0;
	g_eMoves[id][mvExpectedForward] = forwardIntent;
	g_eMoves[id][mvExpectedSide] = sideIntent;

	new Float:moveIntent = floatsqroot(floatadd(floatmul(forwardIntent, forwardIntent), floatmul(sideIntent, sideIntent)));
	g_eMoves[id][mvExpectedMove] = moveIntent;

	if (moveIntent > g_ePlayer[id][MaxSpeed_current])
	{
		new Float:scale = floatdiv(g_ePlayer[id][MaxSpeed_current], moveIntent);
		g_eMoves[id][mvExpectedScale] = scale;
		forwardIntent = floatmul(forwardIntent, scale);
		sideIntent = floatmul(sideIntent, scale);
		g_eMoves[id][mvExpectedForward] = forwardIntent;
		g_eMoves[id][mvExpectedSide] = sideIntent;
		g_eMoves[id][mvExpectedMove] = floatsqroot(floatadd(floatmul(forwardIntent, forwardIntent), floatmul(sideIntent, sideIntent)));
	}

	g_eMoves[id][mvExpectedWalkForward] = floatmul(MOVE_WALK_RATIO, g_eMoves[id][mvExpectedForward]);
	g_eMoves[id][mvExpectedWalkSide] = floatmul(MOVE_WALK_RATIO, g_eMoves[id][mvExpectedSide]);

	g_eMoves[id][mvForwardDelta] = floatabs(floatsub(g_ePlayer[id][e_forwardmove], g_eMoves[id][mvExpectedForward]));
	g_eMoves[id][mvForwardWalkDelta] = floatabs(floatsub(g_ePlayer[id][e_forwardmove], g_eMoves[id][mvExpectedWalkForward]));
	g_eMoves[id][mvSideDelta] = floatabs(floatsub(g_ePlayer[id][e_lerp_msec], g_eMoves[id][mvExpectedSide]));
	g_eMoves[id][mvSideWalkDelta] = floatabs(floatsub(g_ePlayer[id][e_lerp_msec], g_eMoves[id][mvExpectedWalkSide]));

	new bool:bInvalidForward = (g_eMoves[id][mvForwardDelta] > 1.0 && g_eMoves[id][mvForwardWalkDelta] > 1.0);
	new bool:bInvalidSide = (g_eMoves[id][mvSideDelta] > 1.0 && g_eMoves[id][mvSideWalkDelta] > 1.0);
	new bool:bSuspiciousCmd = bInvalidForward || bInvalidSide;

	g_eMoves[id][mvAnglesClamped] = 0;
	if (bSuspiciousCmd && containi(sz_plugin_block_modules, "m") != -1)
	{
		if (g_ePlayer[id][37] > g_ePlayer[id][38])
		{
			for (new axis = 0; axis < 3; axis++)
			{
				g_eMoves[id][mvSavedAngles][axis] = g_ePlayer[id][49][axis];
			}
			set_pev(id, pev_angles, g_eMoves[id][mvSavedAngles]);
			g_eMoves[id][mvAnglesClamped] = 1;
		}

		if (containi(sz_plugin_debug_mode, "m") != -1 && g_ePlayer[id][7])
		{
			PrintDebugMessage(id);
		}
	}

	if (g_ePlayer[id][MaxSpeed_current] != g_ePlayer[id][MaxSpeed_old])
	{
		g_eMoves[id][mvLastMaxSpeedChange] = g_eServer[1];
	}

	new bool:bReadyWindow = g_ePlayer[id][9] >= 50
		&& floatsub(g_eServer[1], g_eMoves[id][mvLastMaxSpeedChange]) >= 0.5
		&& g_ePlayer[id][e_upmove] == 0
		&& g_ePlayer[id][41] != 0
		&& g_ePlayer[id][42] != 0
		&& (g_ePlayer[id][ucButtons] & IN_JUMP4)
		&& g_ePlayer[id][e_forwardmove] == 0;

	if (bReadyWindow)
	{
		if (g_ePlayer[id][36] != 0)
		{
			g_eMoves[id][mvSamples]++;
		}

		if (bSuspiciousCmd)
		{
			g_eMoves[id][mvInvalidTicks]++;

			if (!g_bPunished[id][3])
			{
				g_eMoves[id][mvPhase]++;
				if (g_eMoves[id][mvPhase] > g_eMoves[id][mvPhasePeak])
				{
					g_eMoves[id][mvPhasePeak] = g_eMoves[id][mvPhase];
				}

				if (bInvalidForward)
				{
					g_eMoves[id][mvForwardMismatchCount]++;
					g_eMoves[id][mvForwardMismatchStreak]++;
					if (g_eMoves[id][mvForwardMismatchStreak] > g_eMoves[id][mvForwardMismatchPeak])
					{
						g_eMoves[id][mvForwardMismatchPeak] = g_eMoves[id][mvForwardMismatchStreak];
					}
				}
				else
				{
					g_eMoves[id][mvForwardMismatchStreak] = 0;
				}

				if (bInvalidSide)
				{
					g_eMoves[id][mvSideMismatchCount]++;
					g_eMoves[id][mvSideMismatchStreak]++;
					if (g_eMoves[id][mvSideMismatchStreak] > g_eMoves[id][mvSideMismatchPeak])
					{
						g_eMoves[id][mvSideMismatchPeak] = g_eMoves[id][mvSideMismatchStreak];
					}
				}
				else
				{
					g_eMoves[id][mvSideMismatchStreak] = 0;
				}

				if (g_eMoves[id][mvMinMove] > g_ePlayer[id][36] || g_eMoves[id][mvMinMove] == 0)
				{
					g_eMoves[id][mvMinMove] = g_ePlayer[id][36];
				}
				if (g_eMoves[id][mvMinForward] > g_ePlayer[id][e_forwardmove])
				{
					g_eMoves[id][mvMinForward] = g_ePlayer[id][e_forwardmove];
				}
				if (g_eMoves[id][mvMinSide] > g_ePlayer[id][e_lerp_msec])
				{
					g_eMoves[id][mvMinSide] = g_ePlayer[id][e_lerp_msec];
				}
				if (g_eMoves[id][mvMaxMove] < g_ePlayer[id][36])
				{
					g_eMoves[id][mvMaxMove] = g_ePlayer[id][36];
				}
				if (g_eMoves[id][mvMaxForward] < g_ePlayer[id][e_forwardmove])
				{
					g_eMoves[id][mvMaxForward] = g_ePlayer[id][e_forwardmove];
				}
				if (g_eMoves[id][mvMaxSide] < g_ePlayer[id][e_lerp_msec])
				{
					g_eMoves[id][mvMaxSide] = g_ePlayer[id][e_lerp_msec];
				}

				if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
				{
					g_eMoves[id][mvGroundTicks]++;
				}
				if (g_ePlayer[id][19] > g_eMoves[id][mvPeakFps])
				{
					g_eMoves[id][mvPeakFps] = g_ePlayer[id][19];
				}
				if (g_eMoves[id][mvPeakSpeed] < g_ePlayer[id][37])
				{
					g_eMoves[id][mvPeakSpeed] = g_ePlayer[id][37];
				}
				g_eMoves[id][mvSpeedDelta] = floatsub(g_ePlayer[id][37], g_ePlayer[id][38]);

				g_eMoves[id][mvLastWeaponId] = get_user_weapon(id, 0, 0);
				if (g_eMoves[id][mvLastWeaponId])
				{
					get_weaponname(g_eMoves[id][mvLastWeaponId], g_eMoves[id][mvWeaponName], "");
					replace(g_eMoves[id][mvWeaponName], "", "weapon_", 101996);
				}

				if (g_eMoves[id][mvPhase] == 5)
				{
					QCC(id, 2);
					QCC(id, 3);
					QCC(id, 4);
					QCC(id, 5);
				}
				if (g_eMoves[id][mvPhase] == 10)
				{
					client_cmd(id, "lookstrafe 0;joystick 0;+mlook;-klook;-jlook;-strafe;cl_forwardspeed 400;cl_backspeed 400;cl_sidespeed 400;MC_CS_RECEIVED");
					g_eMoves[id][mvConfigSentFlag] = 1;
					g_eMoves[id][mvConfigSentPhase] = g_eMoves[id][mvPhase];
					g_eMoves[id][mvConfigAckPhase] = 0;
				}

				static szLog[512];
				if (containi(sz_plugin_punish_modules, "m") != -1 && g_eMoves[id][mvPhase] >= 3)
				{
					GenerateDetailedMovesLog(id, szLog, 511);
					PunishClient(id, 1, "m", szLog);
				}
				if (g_eMoves[id][mvPhase] >= 25)
				{
					GenerateMovesLog(id, szLog, 511);
					PunishClient(id, 0, "m", szLog);
				}
			}

			if (containi(sz_plugin_debug_mode, "m") != -1
			&& g_ePlayer[id][7]
			&& containi(sz_plugin_block_modules, "m") == -1)
			{
				PrintDebugMessage(id);
			}
		}
		else
		{
			g_eMoves[id][mvPhase] = 0;
			g_eMoves[id][mvForwardMismatchStreak] = 0;
			g_eMoves[id][mvSideMismatchStreak] = 0;
		}

		if (g_eMoves[id][mvSamples] >= 100)
		{
			ResetMoves(id, 0);
		}
	}

	return 0;
}

Float:CL_KeyState(id, iKey)
{
	new Float:flValue = 0.0;
	new var1;
	if (iKey & g_ePlayer[id][ucButtons] && iKey & ~g_ePlayer[id][oldButtons])
	{
		flValue = 0.5;
	}
	else
	{
		new var2;
		if (iKey & g_ePlayer[id][ucButtons] && iKey & g_ePlayer[id][oldButtons])
		{
			flValue = 1.0;
		}
	}
	return flValue;
}

public cmdMC_CorrectSettingsReceived(id)
{
	g_eMoves[id][mvConfigAckFlag] = 1;
	g_eMoves[id][mvConfigAckPhase] = g_eMoves[id][mvPhase];
	return 1;
}

PrintDebugMessage(id)
{
	client_print_color(id, -2, "\x04[DEBUG] \x01Move: \x03%.3f \x01(should be \x03%.3f\x01), ForwardMove: \x03%.3f \x01(should be \x03%.3f\x01), SideMove: \x03%.3f \x01(should be \x03%.3f\x01)", g_ePlayer[id][36], g_eMoves[id][mvExpectedMove], g_ePlayer[id][e_forwardmove], g_eMoves[id][mvExpectedForward], g_ePlayer[id][e_lerp_msec], g_eMoves[id][mvExpectedSide]);
	return 0;
}

GenerateDetailedMovesLog(id, szOutput[], iSize)
{
	static szGameTime[12];
	GetGameTime(szGameTime, 11, 1);
	new var1;
	if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
	{
		var1 = 105644;
	}
	else
	{
		var1 = 105672;
	}
	formatex(szOutput, iSize, "#%i\x09<%s, %s> : Move: %.3f (should be %.3f), ForwardMove: %.3f (should be %.3f or %.3f), SideMove: %.3f (should be %.3f or %.3f)", g_eMoves[id][mvPhase], szGameTime, var1, g_ePlayer[id][36], g_eMoves[id][mvExpectedMove], g_ePlayer[id][e_forwardmove], g_eMoves[id][mvExpectedForward], g_eMoves[id][mvExpectedWalkForward], g_ePlayer[id][e_lerp_msec], g_eMoves[id][mvExpectedSide], g_eMoves[id][mvExpectedWalkSide]);
	format(szOutput, iSize, "%s, KeyState: { %.2f, %.2f, %.2f, %.2f }, MaxSpeed: %.3f (%s), cl_(*)speed: { %.3f, %.3f, %.3f }, cl_movespeedkey: %.2f", szOutput, CL_KeyState(id, IN_FORWARD), CL_KeyState(id, IN_BACK), CL_KeyState(id, IN_MOVELEFT), CL_KeyState(id, IN_MOVERIGHT), g_ePlayer[id][MaxSpeed_current], g_eMoves[id][mvWeaponName], g_eClientCVar[id][2], g_eClientCVar[id][3], g_eClientCVar[id][4], g_eClientCVar[id][5]);
	new var2;
	if (g_eMoves[id][mvSpeedDelta] > 0)
	{
		var2 = 106448;
	}
	else
	{
		var2 = 106456;
	}
	format(szOutput, iSize, "%s, Speed: %.3f (%s%.3f), Yaw speed: %.2f, Pitch speed: %.2f, FPS: %i", szOutput, g_ePlayer[id][37], var2, g_eMoves[id][mvSpeedDelta], g_ePlayer[id][41], g_ePlayer[id][42], g_ePlayer[id][19]);
	if (g_eMoves[id][mvAnglesClamped])
	{
		add(szOutput, iSize, " BLOCKED", MaxClients);
	}
	if (g_eMoves[id][mvConfigSentFlag])
	{
		add(szOutput, iSize, " CS_SENT", MaxClients);
		g_eMoves[id][mvConfigSentFlag] = 0;
	}
	if (g_eMoves[id][mvConfigAckFlag])
	{
		add(szOutput, iSize, " CS_RECEIVED", MaxClients);
		g_eMoves[id][mvConfigAckFlag] = 0;
	}
	return 0;
}

GenerateMovesLog(id, szOutput[], iSize)
{
	formatex(szOutput, iSize, "Move: %i/%i | %i, ForwardMove: %i/%i | %i, SideMove: %i/%i | %i, Min. moves: { %.3f, %.3f, %.3f }, Max. moves: { %.3f, %.3f, %.3f }", g_eMoves[id][mvInvalidTicks], g_eMoves[id][mvSamples], g_eMoves[id][mvPhasePeak], g_eMoves[id][mvForwardMismatchCount], g_eMoves[id][mvSamples], g_eMoves[id][mvForwardMismatchPeak], g_eMoves[id][mvSideMismatchCount], g_eMoves[id][mvSamples], g_eMoves[id][mvSideMismatchPeak], g_eMoves[id][mvMinMove], g_eMoves[id][mvMinForward], g_eMoves[id][mvMinSide], g_eMoves[id][mvMaxMove], g_eMoves[id][mvMaxForward], g_eMoves[id][mvMaxSide]);
	format(szOutput, iSize, "%s, MaxSpeed: %.3f (%s), Ground frames: %i/%i, cl_(*)speed: { %.3f, %.3f, %.3f }, Max. speed: %.3f, Max. FPS: %i, CS_SENT: %i, CS_RECEIVED: %i", szOutput, g_ePlayer[id][MaxSpeed_current], g_eMoves[id][mvWeaponName], g_eMoves[id][mvGroundTicks], g_eMoves[id][mvInvalidTicks], g_eClientCVar[id][2], g_eClientCVar[id][3], g_eClientCVar[id][4], g_eMoves[id][mvPeakSpeed], g_eMoves[id][mvPeakFps], g_eMoves[id][mvConfigSentPhase], g_eMoves[id][mvConfigAckPhase]);
	return 0;
}

ResetMoves(id, bFull)
{
	g_eMoves[id][mvSamples] = 0;
	g_eMoves[id][mvInvalidTicks] = 0;
	g_eMoves[id][mvForwardMismatchCount] = 0;
	g_eMoves[id][mvSideMismatchCount] = 0;
	g_eMoves[id][mvGroundTicks] = 0;
	g_eMoves[id][mvPeakFps] = 0;
	g_eMoves[id][mvMinMove] = 0;
	g_eMoves[id][mvMinForward] = 0;
	g_eMoves[id][mvMinSide] = 0;
	g_eMoves[id][mvMaxMove] = 0;
	g_eMoves[id][mvMaxForward] = 0;
	g_eMoves[id][mvMaxSide] = 0;
	g_eMoves[id][mvPeakSpeed] = 0;
	if (bFull)
	{
		g_eMoves[id][mvConfigSentFlag] = 0;
		g_eMoves[id][mvConfigAckFlag] = 0;
		g_eMoves[id][mvAnglesClamped] = 0;
		g_eMoves[id][mvPhase] = 0;
		g_eMoves[id][mvPhasePeak] = 0;
		g_eMoves[id][mvForwardMismatchStreak] = 0;
		g_eMoves[id][mvForwardMismatchPeak] = 0;
		g_eMoves[id][mvSideMismatchStreak] = 0;
		g_eMoves[id][mvSideMismatchPeak] = 0;
		g_eMoves[id][mvLastWeaponId] = 0;
		g_eMoves[id][mvConfigSentPhase] = 0;
		g_eMoves[id][mvConfigAckPhase] = 0;
		g_eMoves[id][mvExpectedMove] = 0;
		g_eMoves[id][mvExpectedForward] = 0;
		g_eMoves[id][mvExpectedSide] = 0;
		g_eMoves[id][mvExpectedScale] = 0;
		g_eMoves[id][mvExpectedWalkForward] = 0;
		g_eMoves[id][mvExpectedWalkSide] = 0;
		g_eMoves[id][mvForwardDelta] = 0;
		g_eMoves[id][mvForwardWalkDelta] = 0;
		g_eMoves[id][mvSideDelta] = 0;
		g_eMoves[id][mvSideWalkDelta] = 0;
		g_eMoves[id][mvLastMaxSpeedChange] = 0;
		g_eMoves[id][mvSpeedDelta] = 0;
		arrayset(g_eMoves[id][mvWeaponName], 0, MOVE_WEAPON_NAME_LEN);
		g_eClientCVar[id][2] = 0;
		g_eClientCVar[id][3] = 0;
		g_eClientCVar[id][4] = 0;
		g_eClientCVar[id][5] = 0;
	}
	return 0;
}

CheckAngles(id)
{
	g_eAngles[id][7] = floatabs(g_ePlayer[id][41]);
	new var1;
	if (g_eAngles[id][7] >= 2.5 && !g_ePlayer[id][ucButtons] & 384 && floatabs(floatsub(g_eAngles[id][7], g_eAngles[id][8])) <= 0.005493)
	{
		g_eAngles[id][3]++;
		if (5 <= g_eAngles[id][3])
		{
			g_eAngles[id][2] = 0;
			new var2;
			if (containi(sz_plugin_block_modules, "a") != -1 && g_ePlayer[id][37] > g_ePlayer[id][38])
			{
				for (new i; i < 3; i++) {
					g_eAngles[id][e_angles_old][i] = g_ePlayer[id][e_angles_current][i];
				}
				new var5 = g_eAngles[id][e_angles_old];
				var5 = floatsub(var5, floatmul(1.0, floatsub(g_ePlayer[id][e_angles_current], g_ePlayer[id][49])));
				new var6 = g_eAngles[id][12];
				var6 = floatsub(var6, floatmul(1.0, floatsub(g_ePlayer[id][47], g_ePlayer[id][50])));
				set_pev(id, pev_angles, g_eAngles[id][e_angles_old]);
				g_eAngles[id][2] = 1;
				new var3;
				if (g_eAngles[id][angles_phase] >= 7 && floatsub(g_eServer[1], g_eAngles[id][fl_last_msl_warning]) >= 60.0)
				{
					client_print_color(id, -2, "\x04%s \x03Mouse Speed Limit detected! \x01Check console for more information.", sz_plugin_custom_prefix);
					console_print(id, "\n\x09%s Your speed will be reduced during strafing until you get rid of Mouse Speed Limit.", sz_plugin_custom_prefix);
					console_print(id, "\x09%s You can learn what Mouse Speed Limit is here: %s\n", sz_plugin_custom_prefix, "https://goo.gl/npxSqm");
					g_eAngles[id][fl_last_msl_warning] = g_eServer[1];
				}
			}
			if (!g_bPunished[id][4])
			{
				g_eAngles[id][3] = 0;
				if (floatabs(floatsub(g_eAngles[id][7], g_eAngles[id][9])) <= 0.005493)
				{
					g_eAngles[id][angles_phase]++;
					if (g_eAngles[id][angles_phase] == 3)
					{
						QCC(id, 6);
						QCC(id, 7);
						QCC(id, 8);
						QCC(id, 9);
					}
					if (g_eAngles[id][angles_phase] == 4)
					{
						client_cmd(id, "joystick 0;-jlook;AC_CS_RECEIVED");
						g_eAngles[id][0] = 1;
						g_eAngles[id][5] = g_eAngles[id][angles_phase];
						g_eAngles[id][6] = 0;
					}
					if (g_eAngles[id][10] < g_eAngles[id][7])
					{
						g_eAngles[id][10] = g_eAngles[id][7];
					}
					static szLog[256];
					if (containi(sz_plugin_punish_modules, "a") != -1)
					{
						GenerateDetailedAnglesLog(id, szLog, 255);
						PunishClient(id, 1, "a", szLog);
					}
					if (g_eAngles[id][angles_phase] >= 7)
					{
						GenerateAnglesLog(id, szLog, 255);
						PunishClient(id, 0, "a", szLog);
					}
				}
				else
				{
					g_eAngles[id][angles_phase] = 0;
				}
				g_eAngles[id][9] = g_eAngles[id][7];
			}
		}
		new var4;
		if (containi(sz_plugin_debug_mode, "a") != -1 && g_ePlayer[id][7])
		{
			client_print_color(id, -2, "\x04[DEBUG] \x01Phase: \x03%i\x01, In a row: \x03%i\x01, Yaw speed: \x03%f", g_eAngles[id][angles_phase], g_eAngles[id][3], g_ePlayer[id][41]);
		}
	}
	else
	{
		g_eAngles[id][3] = 0;
	}
	g_eAngles[id][8] = g_eAngles[id][7];
	return 0;
}

public cmdAC_CorrectSettingsReceived(id)
{
	g_eAngles[id][1] = 1;
	g_eAngles[id][6] = g_eAngles[id][angles_phase];
	return 1;
}

GenerateDetailedAnglesLog(id, szOutput[], iSize)
{
	static szGameTime[12];
	GetGameTime(szGameTime, 11, 1);
	new var1;
	if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
	{
		var1 = 112308;
	}
	else
	{
		var1 = 112336;
	}
	formatex(szOutput, iSize, "#%i\x09<%s, %s> : Yaw speed: %f", g_eAngles[id][angles_phase], szGameTime, var1, g_ePlayer[id][41]);
	if (g_eAngles[id][2])
	{
		add(szOutput, iSize, " BLOCKED", MaxClients);
	}
	if (g_eAngles[id][0])
	{
		add(szOutput, iSize, " CS_SENT", MaxClients);
		g_eAngles[id][0] = 0;
	}
	if (g_eAngles[id][1])
	{
		add(szOutput, iSize, " CS_RECEIVED", MaxClients);
		g_eAngles[id][1] = 0;
	}
	return 0;
}

GenerateAnglesLog(id, szOutput[], iSize)
{
	formatex(szOutput, iSize, "Yaw speed: %f, Biggest yaw speed: %f, sensitivity: %.3f, m_filter: %.3f, m_rawinput: %.3f, m_customaccel: %.3f, CS_SENT: %i, CS_RECEIVED: %i", g_eAngles[id][7], g_eAngles[id][10], g_eClientCVar[id][6], g_eClientCVar[id][7], g_eClientCVar[id][8], g_eClientCVar[id][9], g_eAngles[id][5], g_eAngles[id][6]);
	return 0;
}

ResetAngles(id)
{
	arrayset(g_eAngles[id], 0, 15);
	return 0;
}

CheckFPS(id)
{
	new var1;
	if (g_ePlayer[id][19] >= 4 && g_ePlayer[id][19] <= 100)
	{
		return 0;
	}
	new var2;
	if (!g_bPunished[id][5] && g_eServer[1] > floatadd(1.0, g_eFPS[id][21]))
	{
		g_eFPS[id]++;
		new Num = g_eFPS[id][fps_phase] - 1;
		g_eFPS[id][1][Num] = g_ePlayer[id][19];
		g_eFPS[id][11][Num] = g_ePlayer[id][emulated_fps];
		if (g_eFPS[id][fps_phase] == 1)
		{
			QCC(id, 0);
			QCC(id, 1);
		}
		static szLog[256];
		if (containi(sz_plugin_punish_modules, "f") != -1)
		{
			GenerateDetailedFpsLog(id, szLog, 255);
			PunishClient(id, 1, "f", szLog);
			if (g_ePlayer[id][19] > 100)
			{
				client_cmd(id, "fps_max 99.5");
			}
		}
		if (10 <= g_eFPS[id][fps_phase])
		{
			GenerateFpsLog(id, szLog, 255);
			PunishClient(id, 0, "f", szLog);
		}
		g_eFPS[id][21] = g_eServer[1];
	}
	new var3;
	if (containi(sz_plugin_debug_mode, "f") != -1 && g_ePlayer[id][7])
	{
		client_print_color(id, -2, "\x04[DEBUG] \x01FPS: \x03%i\x01, Msec: \x03%i\x01, Emulated FPS: \x03%i", g_ePlayer[id][19], g_ePlayer[id][e_msec], g_ePlayer[id][emulated_fps]);
	}
	return 0;
}

GenerateDetailedFpsLog(id, szOutput[], iSize)
{
	static szGameTime[12];
	GetGameTime(szGameTime, 11, 1);
	static szButtons[19];
	new var1;
	if (g_ePlayer[id][ucButtons] & IN_DUCK)
	{
		var1 = 117692;
	}
	else
	{
		var1 = 117712;
	}
	new var2;
	if (g_ePlayer[id][ucButtons] & IN_JUMP)
	{
		var2 = 117652;
	}
	else
	{
		var2 = 117672;
	}
	new var3;
	if (g_ePlayer[id][ucButtons] & IN_MOVERIGHT)
	{
		var3 = 117636;
	}
	else
	{
		var3 = 117644;
	}
	new var4;
	if (g_ePlayer[id][ucButtons] & IN_BACK)
	{
		var4 = 117620;
	}
	else
	{
		var4 = 117628;
	}
	new var5;
	if (g_ePlayer[id][ucButtons] & IN_MOVELEFT)
	{
		var5 = 117604;
	}
	else
	{
		var5 = 117612;
	}
	new var6;
	if (g_ePlayer[id][ucButtons] & IN_FORWARD)
	{
		var6 = 117588;
	}
	else
	{
		var6 = 117596;
	}
	formatex(szButtons, 18, "{ %s%s%s%s %s %s }", var6, var5, var4, var3, var2, var1);
	static szOldButtons[19];
	new var7;
	if (g_ePlayer[id][oldButtons] & IN_DUCK)
	{
		var7 = 117988;
	}
	else
	{
		var7 = 118008;
	}
	new var8;
	if (g_ePlayer[id][oldButtons] & IN_JUMP)
	{
		var8 = 117948;
	}
	else
	{
		var8 = 117968;
	}
	new var9;
	if (g_ePlayer[id][oldButtons] & IN_MOVERIGHT)
	{
		var9 = 117932;
	}
	else
	{
		var9 = 117940;
	}
	new var10;
	if (g_ePlayer[id][oldButtons] & IN_BACK)
	{
		var10 = 117916;
	}
	else
	{
		var10 = 117924;
	}
	new var11;
	if (g_ePlayer[id][oldButtons] & IN_MOVELEFT)
	{
		var11 = 117900;
	}
	else
	{
		var11 = 117908;
	}
	new var12;
	if (g_ePlayer[id][oldButtons] & IN_FORWARD)
	{
		var12 = 117884;
	}
	else
	{
		var12 = 117892;
	}
	formatex(szOldButtons, 18, "{ %s%s%s%s %s %s }", var12, var11, var10, var9, var8, var7);
	new var13;
	if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
	{
		var13 = g_ePlayer[id][FOG_current];
	}
	else
	{
		var13 = g_ePlayer[id][AirFrames_current];
	}
	new var14;
	if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
	{
		var14 = 118748;
	}
	else
	{
		var14 = 118776;
	}
	formatex(szOutput, iSize, "#%i\x09<%s, %s (%i)> : FPS: %i, Msec: %i, Emulated FPS: %i, Buttons: %s, Old buttons: %s, Hor. speed: %.3f, Ver. speed: %.3f, Ground distance: %.3f, fps_max: %.3f, fps_override: %.3f", g_eFPS[id], szGameTime, var14, var13, g_ePlayer[id][19], g_ePlayer[id][e_msec], g_ePlayer[id][emulated_fps], szButtons, szOldButtons, g_ePlayer[id][37], -g_ePlayer[id][48], fm_distance_to_floor(id), g_eClientCVar[id], g_eClientCVar[id][1]);
	return 0;
}

GenerateFpsLog(id, szOutput[], iSize)
{
	new i;
	while (i < 10)
	{
		if (i)
		{
			if (i < 9)
			{
				format(szOutput, iSize, "%s %i,", szOutput, g_eFPS[id][1][i]);
			}
			format(szOutput, iSize, "%s %i }", szOutput, g_eFPS[id][1][i]);
		}
		else
		{
			formatex(szOutput, iSize, "FPS: {");
		}
		i++;
	}
	new i;
	while (i < 10)
	{
		if (i)
		{
			if (i < 9)
			{
				format(szOutput, iSize, "%s %i,", szOutput, g_eFPS[id][11][i]);
			}
			format(szOutput, iSize, "%s %i }", szOutput, g_eFPS[id][11][i]);
		}
		else
		{
			format(szOutput, iSize, "%s, Emulated FPS: {", szOutput);
		}
		i++;
	}
	format(szOutput, iSize, "%s, fps_max: %.3f, fps_override: %.3f", szOutput, g_eClientCVar[id], g_eClientCVar[id][1]);
	return 0;
}

ResetFPS(id)
{
	arrayset(g_eFPS[id], MaxClients, 22);
	return 0;
}

CheckGstrafeNSD(id)
{
	if (~g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
	{
		return 0;
	}
	if (~g_ePlayer[id][ucButtons] & IN_DUCK)
	{
		return 0;
	}
	if (g_ePlayer[id][oldButtons] & IN_DUCK)
	{
		return 0;
	}
	if (g_ePlayer[id][19])
	{
		return 0;
	}
	new var1;
	if (~g_ePlayer[id][oldButtons] & IN_DUCK && g_ePlayer[id][e_PlayerFlags] & 16384)
	{
		return 0;
	}
	if (!g_bPunished[id][6])
	{
		g_eGstrafeNSD[id]++;
		if (g_eGstrafeNSD[id][1] < g_ePlayer[id][37])
		{
			g_eGstrafeNSD[id][1] = g_ePlayer[id][37];
		}
		static szLog[128];
		if (containi(sz_plugin_punish_modules, "n") != -1)
		{
			GenerateDetailedGstrafeNsdLog(id, szLog, 127);
			PunishClient(id, 1, "n", szLog);
		}
		if (5 <= g_eGstrafeNSD[id][0])
		{
			GenerateGstrafeNsdLog(id, szLog, 127);
			PunishClient(id, 0, "n", szLog);
		}
	}
	new var2;
	if (containi(sz_plugin_debug_mode, "n") != -1 && g_ePlayer[id][7])
	{
		client_print_color(id, -2, "\x04[DEBUG] \x01Old buttons: \x03%i\x01, Prev. buttons: \x03%i\x01, FPS: \x03%i", g_ePlayer[id][oldButtons], g_ePlayer[id][oldButtons], g_ePlayer[id][19]);
	}
	return 0;
}

GenerateDetailedGstrafeNsdLog(id, szOutput[], iSize)
{
	static szGameTime[12];
	GetGameTime(szGameTime, 11, 1);
	formatex(szOutput, iSize, "#%i\x09<%s> : Old buttons: %i, Prev. buttons: %i, FPS: %i, Emulated FPS: %i, Speed: %.3f", g_eGstrafeNSD[id], szGameTime, g_ePlayer[id][oldButtons], g_ePlayer[id][oldButtons], g_ePlayer[id][19], g_ePlayer[id][emulated_fps], g_ePlayer[id][37]);
	return 0;
}

GenerateGstrafeNsdLog(id, szOutput[], iSize)
{
	formatex(szOutput, iSize, "No slowdown gstrafes: %i, Max. speed: %.3f", g_eGstrafeNSD[id], g_eGstrafeNSD[id][1]);
	return 0;
}

ResetGstrafeNSD(id)
{
	g_eGstrafeNSD[id][0] = 0;
	g_eGstrafeNSD[id][1] = 0;
	return 0;
}

CheckCVars(id)
{
	decl size;
	new var1;
	if (g_iBuild[id] == 4554)
	{
		var1 = 6;
	}
	else
	{
		var1 = 43;
	}
	size = var1;
	new i;
	while (i < size)
	{
		static params[1];
		params[0] = i;
		set_task(0.1 + i, "taskCheckCVars", id + taskid_check_cvars, params, 1, "c", MaxClients);
		set_task(9662 + i, "taskCheckCVars", id + taskid_check_cvars, params, 1, 123684, MaxClients);
		i++;
	}
	return 0;
}

public taskCheckCVars(params[], id)
{
	if (containi(sz_plugin_modules_working, "c") != -1)
	{
		new var1;
		if (g_iBuild[id] == 4554)
		{
			var1 = g_szCVarsOld[params[0]];
		}
		else
		{
			var1 = g_szCVarsNew[params[0]];
		}
		query_client_cvar(id, var1, "taskCheckCVars_Result", 0, 30580);
	}
	return 0;
}

public taskCheckCVars_Result(id, szCVar[], szValue[])
{
	new var1;
	if (!g_bPunished[id][7] && !equal(szValue, "Bad CVAR request"))
	{
		PunishClient(id, 0, "a", "Found cheat cvar: %s %s", szCVar, szValue);
		remove_task(id + taskid_check_cvars);
	}
	return 0;
}

CheckCommands(id)
{
	new size;
	size = (g_iBuild[id] == 4554) ? 6 : 32;
	new i;
	while (i < size)
	{
		static params[1];
		params[0] = i;
		set_task(1.0 + i, "taskCheckCommands", id + taskid_check_cmd_result, params, 1, "c", MaxClients);
		set_task(90.0 + i, "taskCheckCommands", id + taskid_check_cmd_result, params, 1, 146436, MaxClients);
		i++;
	}
	return 0;
}

public taskCheckCommands(params[], id)
{
	if (containi(sz_plugin_modules_working, "o") == -1)
	{
		return 0;
	}
	id -= taskid_check_cmd_result;
	new CmdNum = params[0];
	g_eCommands[id][CmdNum] = 1;
	g_eCommands[id][32][CmdNum]++;
	static type;
	static cmd[32];
	if (g_iBuild[id] == 4554)
	{
		copy(cmd, 31, g_szCommandsOld[CmdNum]);
		type = g_szCommandsOld[CmdNum][32];
	}
	else
	{
		copy(cmd, 31, g_szCommandsNew[CmdNum]);
		type = g_szCommandsNew[CmdNum][32];
	}
	client_cmd(id, cmd);
	switch (type)
	{
		case 1:
		{
			cmd[0] = 45;
			client_cmd(id, cmd);
		}
		case 2:
		{
			client_cmd(id, cmd);
		}
		default:
		{
		}
	}
	set_task(5.0, "taskCheckCommands_Result", id + taskid_check_cmd_result, params, 1, "c", MaxClients);
	return 0;
}

CheckCommand(id, szCmd[])
{
	decl CmdNum;
	new var1;
	if (g_iBuild[id] == 4554)
	{
		var1[0] = 123960;
	}
	else
	{
		var1[0] = 124776;
	}
	CmdNum = InArrayStr(szCmd, var1, 32);
	if (CmdNum != -1)
	{
		g_eCommands[id][CmdNum] = 0;
	}
	return 0;
}

public taskCheckCommands_Result(params[], id)
{
	if (containi(sz_plugin_modules_working, "o") == -1)
	{
		return 0;
	}
	id -= taskid_check_cmd_result;
	new CmdNum = params[0];
	static cmd[32];
	if (g_iBuild[id] == 4554)
	{
		copy(cmd, 31, g_szCommandsOld[CmdNum]);
	}
	else
	{
		copy(cmd, 31, g_szCommandsNew[CmdNum]);
	}
	if (g_eCommands[id][CmdNum])
	{
		g_eCommands[id][64][CmdNum]++;
		if (containi(sz_plugin_debug_mode, "o") != -1)
		{
			client_print_color(id, -2, "\x04[DEBUG] \x01Command is registered: \x03%s (%i/%i)", cmd, g_eCommands[id][64][CmdNum], g_eCommands[id][32][CmdNum]);
		}
		if (containi(sz_plugin_punish_modules, "o") != -1)
		{
			static szGameTime[12];
			static szLog[96];
			GetGameTime(szGameTime, 11, 1);
			formatex(szLog, 95, "<%s> : %s (%i|%i|%i)", szGameTime, cmd, g_eCommands[id][32][CmdNum], g_eCommands[id][64][CmdNum], g_eCommands[id][96][CmdNum]);
			PunishClient(id, 1, "o", szLog);
			g_bLoggedDetailed[id] = 1;
		}
	}
	else
	{
		g_eCommands[id][96][CmdNum]++;
		if (containi(sz_plugin_debug_mode, "o") != -1)
		{
			client_print_color(id, -3, "\x04[DEBUG] \x01Command is not registered: \x03%s (%i/%i)", cmd, g_eCommands[id][64][CmdNum], g_eCommands[id][32][CmdNum]);
		}
	}
	new var1;
	if (!g_bPunished[id][8] && g_eCommands[id][64][CmdNum] >= 3)
	{
		new szLog[384];
		GenerateCommandsLog(id, szLog, 383);
		PunishClient(id, 0, "o", szLog);
		remove_task(id + taskid_check_cmd_result);
	}
	return 0;
}

GenerateCommandsLog(id, szOutput[], iSize)
{
	new CommandsRegistered;
	new i;
	while (i < 32)
	{
		if (g_eCommands[id][64][i])
		{
			CommandsRegistered++;
			static cmd[32];
			if (g_iBuild[id] == 4554)
			{
				copy(cmd, 31, g_szCommandsOld[i]);
			}
			else
			{
				copy(cmd, 31, g_szCommandsNew[i]);
			}
			if (CommandsRegistered == 1)
			{
				formatex(szOutput, iSize, "Found cheat command(s): %s (%i|%i|%i)", cmd, g_eCommands[id][32][i], g_eCommands[id][64][i], g_eCommands[id][96][i]);
			}
			else
			{
				format(szOutput, iSize, "%s, %s (%i|%i|%i)", szOutput, cmd, g_eCommands[id][32][i], g_eCommands[id][64][i], g_eCommands[id][96][i]);
				if (CommandsRegistered == 5)
				{
					return 0;
				}
			}
		}
		i++;
	}
	return 0;
}

ResetCommands(id)
{
	g_bLoggedDetailed[id] = 0;
	arrayset(g_eCommands[id], MaxClients, 128);
	return 0;
}

public taskCheckDemoPlayer(id)
{
	if (containi(sz_plugin_modules_working, 148376) != -1)
	{
		new CmdNum = random_num(MaxClients, 5);
		client_cmd(id - taskid_check_demoplayer, g_szDemoPlayerCmds[CmdNum]);
	}
	return 0;
}

CheckDemoPlayer(id, szCmd[])
{
	new var1;
	if (!g_bPunished[id][9] && InArrayStr(szCmd, g_szDemoPlayerCmds, 6) != -1)
	{
		PunishClient(id, 0, "d", "Command %s is not registered in client", szCmd);
	}
	return 0;
}

public taskCheckProtector(id)
{
	new var1;
	if (containi(sz_plugin_modules_working, "p") != -1 && !pev(id, pev_flags) & -0 && !g_eServer[0])
	{
		client_cmd(id, "+alt1");
		g_eProtector[id]++;
		set_task(5.0, "taskCheckProtector_Result", id + taskid_check_protector, 30724, MaxClients, "c", MaxClients);
	}
	return 0;
}

public taskCheckProtector_Result(id)
{
	new var1;
	if (!pev(id, pev_flags) & -0 && !g_eServer[0])
	{
		if (pev(id, pev_button) & 16384)
		{
			g_eProtector[id][1]++;
			g_eProtector[id][3] = 0;
		}
		g_eProtector[id][2]++;
		g_eProtector[id][3]++;
		if (5 <= g_eProtector[id][3])
		{
			PunishClient(id, 0, "p", "Protector commands sent: %i, Received: %i, Not received: %i", g_eProtector[id], g_eProtector[id][1], g_eProtector[id][2]);
			remove_task(id + taskid_check_protector);
		}
		new var2;
		if (containi(sz_plugin_debug_mode, "p") != -1 && g_ePlayer[id][7])
		{
			client_print_color(id, -2, "\x04%s \x01Protector commands sent: \x03%i\x01, Received: \x03%i\x01, Not received: \x03%i", sz_plugin_custom_prefix, g_eProtector[id], g_eProtector[id][1], g_eProtector[id][2]);
		}
	}
	client_cmd(id, "-alt1");
	return 0;
}

ResetProtector(id)
{
	arrayset(g_eProtector[id], MaxClients, NULL_STRING);
	return 0;
}

public RecordDemo(id)
{
	if (g_hVault == -1)
	{
		return 0;
	}
	id -= taskid_record_demo;
	static iTimeStamp;
	static szData[8];
	if (!nvault_lookup(g_hVault, g_eDemo[id][2], szData, 7, iTimeStamp))
	{
		nvault_pset(g_hVault, g_eDemo[id][2], szData);
	}
	static szNumber[3];
	static szStatus[2];
	parse(szData, szStatus, 1, szNumber, 2);
	new var1;
	if (str_to_num(szStatus))
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	g_eDemo[id][0] = var1;
	if (g_eDemo[id][0])
	{
		copy(g_eDemo[id][23], 63, sz_plugin_demo_name);
		if (1 < g_eConfig[229])
		{
			new iNewNumber = str_to_num(szNumber);
			if (plugin_recording_demo_counts <= iNewNumber)
			{
				iNewNumber = 0;
			}
			static szNewData[8];
			iNewNumber++;
			formatex(szNewData, 7, "1 %i", iNewNumber);
			nvault_pset(g_hVault, g_eDemo[id][2], szNewData);
			format(g_eDemo[id][23], 63, "%s_%s", g_eDemo[id][23], szNumber);
		}
		new i;
		while (i < 31)
		{
			replace_all(g_eDemo[id][23], 63, g_szReplaceCharList[i], 162044);
			i++;
		}
		client_cmd(id, "stop;record %s", g_eDemo[id][23]);
	}
	if (g_eConfig[228])
	{
		if (g_eDemo[id][0])
		{
			client_print_color(id, -1, "\x04%s \x01Demo recording has started: \x03%s.dem", sz_plugin_custom_prefix, g_eDemo[id][23]);
		}
		else
		{
			client_print_color(id, -1, "\x04%s \x01Demo recording is \x03disabled", sz_plugin_custom_prefix);
		}
		client_print_color(id, -3, "\x04%s \x01Type \x03/demo_menu \x01in chat to manage demo recording settings", sz_plugin_custom_prefix);
	}
	g_eDemo[id][1] = 1;
	return 0;
}

ChangeDemoRecordingStatus(id)
{
	if (g_hVault == -1)
	{
		return 0;
	}
	static szData[8];
	nvault_get(g_hVault, g_eDemo[id][2], szData, 7);
	g_eDemo[id][0] = !g_eDemo[id][0];
	new var1;
	if (g_eDemo[id][0])
	{
		var1 = 49;
	}
	else
	{
		var1 = 48;
	}
	szData[0] = var1;
	nvault_pset(g_hVault, g_eDemo[id][2], szData);
	return 0;
}

public cmdDemoMenu(id)
{
	new hMenu = menu_create("CA: Demo menu", "cmdDemoMenu_Handle", MaxClients);
	static szDemoRecording[48];
	if (g_eConfig[230])
	{
		new var1;
		if (g_eDemo[id][0])
		{
			var1 = 163252;
		}
		else
		{
			var1 = 163292;
		}
		formatex(szDemoRecording, 47, "Demo recording: %s\n", var1);
	}
	else
	{
		copy(szDemoRecording, 47, "Demo recording: \ddisabled by server\n");
	}
	menu_additem(hMenu, szDemoRecording, 163488, MaxClients, -1);
	menu_addtext(hMenu, "\x09\x09\dIf it does not cause any discomfort to you,", 1);
	menu_addtext(hMenu, "\x09\x09it is strongly recommended to keep demo", 1);
	menu_addtext(hMenu, "\x09\x09recording enabled, otherwise it will greatly", 1);
	menu_addtext(hMenu, "\x09\x09reduce your chances of getting unban.", 1);
	menu_addtext(hMenu, "\n\x09\x09Changes will apply upon the next connection", 1);
	menu_display(id, hMenu, MaxClients, -1);
	return 1;
}

public cmdDemoMenu_Handle(id, hMenu, iItem)
{
	if (!iItem)
	{
		if (g_eConfig[230])
		{
			ChangeDemoRecordingStatus(id);
		}
		cmdDemoMenu(id);
	}
	menu_destroy(hMenu);
	return 0;
}

ResetDemoRecording(id)
{
	g_eDemo[id][0] = 0;
	g_eDemo[id][1] = 0;
	if (!g_eConfig[230])
	{
	}
	return 0;
}

PunishClient(id, iPunishType, szCheatType[], szText[])
{
	static szSessionTime[8];
	GetSessionTime(id, szSessionTime, 7);
	static szGameTime[8];
	GetGameTime(szGameTime, 7, 0);
	static szFormattedText[768];
	vformat(szFormattedText, 767, szText, 5);
	if (iPunishType)
	{
		static szDate[22];
		get_time("%d.%m.%Y - %H:%M:%S", szDate, 21);
		if (!dir_exists(g_szLogsDir, MaxClients))
		{
			mkdir(g_szLogsDir, 511);
		}
		static iPhaseNum;
		static szLogsDir[128];
		new iFirstLog = 1;
		
		switch (szCheatType[0])
		{
			case 'a':
			{
				formatex(szLogsDir, 127, "%s/detailed_angles", g_szLogsDir);
				iPhaseNum = g_eAngles[id][angles_phase];
			}
			case 'b':
			{
				formatex(szLogsDir, 127, "%s/detailed_bhop", g_szLogsDir);
				iPhaseNum = g_eBhopChecker[id][bhcPhase];
			}
			case 'f':
			{
				formatex(szLogsDir, 127, "%s/detailed_fps", g_szLogsDir);
				iPhaseNum = g_eFPS[id][fps_phase];
			}
			case 'g':
			{
				formatex(szLogsDir, 127, "%s/detailed_gstrafe", g_szLogsDir);
				iPhaseNum = g_eGstrafe[id][gstrafe_phase];
			}
			case 'j':
			{
				formatex(szLogsDir, 127, "%s/detailed_jumpbug", g_szLogsDir);
				iPhaseNum = g_eJumpbug[id][jumpbug_phase];
			}
			case 'm':
			{
				formatex(szLogsDir, 127, "%s/detailed_moves", g_szLogsDir);
				iPhaseNum = g_eMoves[id][mvPhase];
				iFirstLog = 3;
			}
			case 'n':
			{
				formatex(szLogsDir, 127, "%s/detailed_gstrafe_nsd", g_szLogsDir);
				iPhaseNum = g_eGstrafeNSD[id][0];
			}
			case 'o':
			{
				formatex(szLogsDir, 127, "%s/detailed_commands", g_szLogsDir);
				iPhaseNum = g_bLoggedDetailed[id] ? 0 : 1;
			}
			default:
			{
			}
		}
		if (!dir_exists(szLogsDir))
		{
			mkdir(szLogsDir, 511);
		}
		static szLogPath[128];
		formatex(szLogPath, 127, "%s/%s.log", szLogsDir, g_ePlayer[id][e_steamid]);
		replace_all(szLogPath, 127, 171568, 171576);
		decl bool:bFileExists;
		bFileExists = !!file_exists(szLogPath);
		new hFile = fopen(szLogPath, "at");
		if (hFile)
		{
			if (iFirstLog == iPhaseNum)
			{
				if (bFileExists)
				{
					fputc(hFile, 10);
				}
				fprintf(hFile, "%s / %s (ID: %i) / %s / %s / %s / %s / %s / %i / %s\n", szDate, g_ePlayer[id][61], id, g_ePlayer[id][e_steamid], g_ePlayer[id][114], g_szMap, szSessionTime, szGameTime, g_iBuild[id], g_eDemo[id][23]);
			}
			fprintf(hFile, "\x09%s\n", szFormattedText);
			fclose(hFile);
		}
		else
		{
			LogError(1, "ERROR: Couldn't open file '%s'", szLogPath);
		}
		new var10;
		if (szCheatType[0] == 98 || szCheatType[0] == 103)
		{
			new var11;
			if (plugin_automatically_punish && plugin_print_warns_for_admins && containi(sz_plugin_modules, szCheatType) != -1)
			{
				PrintToAdmins(-2, false, "\x04%s \x01ADMIN: \x03%s \x01is suspected for using cheats! \x03[type: %c, phase: %i]", sz_plugin_custom_prefix, g_ePlayer[id][61], szCheatType, iPhaseNum);
			}
			server_print("[CA] %s (%s) is suspected for using cheats! [type: %c, phase: %i]", g_ePlayer[id][61], g_ePlayer[id][e_steamid], szCheatType, iPhaseNum);
		}
	}
	else
	{
		static szPunishment[16];
		new var1;
		if (plugin_print_warns_for_admins && containi(sz_plugin_modules, szCheatType) != -1)
		{
		}
		new szType[16];
		switch (szCheatType[0])
		{
			case 97:
			{
				szType = {65,110,103,108,101,115,0};
			}
			case 98:
			{
				szType = {66,104,111,112,0};
			}
			case 99:
			{
				szType = {67,86,97,114,0};
			}
			case 100:
			{
				szType = {68,101,109,111,32,80,108,97,121,101,114,0};
			}
			case 102:
			{
				szType = {70,80,83,0};
			}
			case 103:
			{
				szType = {71,115,116,114,97,102,101,0};
			}
			case 106:
			{
				szType = {74,117,109,112,98,117,103,0};
			}
			case 109:
			{
				szType = {77,111,118,101,115,0};
			}
			case 110:
			{
				szType = {71,115,116,114,97,102,101,32,78,83,68,0};
			}
			case 111:
			{
				szType = {67,111,109,109,97,110,100,0};
			}
			case 112:
			{
				szType = {80,114,111,116,101,99,116,111,114,0};
			}
			case 122:
			{
				szType = {84,101,115,116,0};
			}
			default:
			{
			}
		}
		API_LogClient(id, szSessionTime, szGameTime, szPunishment, szType, szFormattedText);
		switch (szCheatType[0])
		{
			case 97:
			{
				g_bPunished[id][4] = true;
			}
			case 98:
			{
				g_bPunished[id][0] = true;
			}
			case 99:
			{
				g_bPunished[id][7] = true;
			}
			case 100:
			{
				g_bPunished[id][9] = true;
			}
			case 102:
			{
				g_bPunished[id][5] = true;
			}
			case 103:
			{
				g_bPunished[id][1] = true;
			}
			case 106:
			{
				g_bPunished[id][2] = true;
			}
			case 109:
			{
				g_bPunished[id][3] = true;
			}
			case 110:
			{
				g_bPunished[id][6] = true;
			}
			case 111:
			{
				g_bPunished[id][8] = true;
			}
			case 112:
			{
				g_bPunished[id][10] = true;
			}
			default:
			{
			}
		}
		new Float:flBanDelay = random_float(1092616192, 1114636288);
		new var4;
		if (plugin_punish_disconnected && ((plugin_print_warns_for_admins && containi(sz_plugin_modules, szCheatType) != -1) || szCheatType[0] == 122))
		{
			g_iNotifyQueque += 1;
			new Float:flElapsedTime = floatsub(get_gametime(), g_flLastNotification);
			if (!g_eConfig[131])
			{
				if (flElapsedTime >= 7.0)
				{
					ShowNotification(id + 61359);
				}
				else
				{
					set_task(floatsub(1088421888 * g_iNotifyQueque, flElapsedTime), "ShowNotification", id + 61359, 30724, MaxClients, "c", MaxClients);
				}
			}
			else
			{
				if (flElapsedTime >= 7.0)
				{
					set_task(flBanDelay, "ShowNotification", id + 61359, 30724, MaxClients, "c", MaxClients);
				}
				set_task(floatadd(flBanDelay, floatsub(1088421888 * g_iNotifyQueque, flElapsedTime)), "ShowNotification", id + 61359, 30724, MaxClients, "c", MaxClients);
			}
			g_flLastNotification = get_gametime();
		}
		new var7;
		if (plugin_automatically_punish && ((plugin_print_warns_for_admins && containi(sz_plugin_modules, szCheatType) != -1) || szCheatType[0] == 122))
		{
			PrintToAdmins(-2, false, "\x04%s \x01ADMIN: \x03%s \x01has been caught for using cheats! \x03[type: %c]", sz_plugin_custom_prefix, g_ePlayer[id][61], szCheatType);
		}
		new var8;
		if (equal(szPunishment, "Perm. banned") || szCheatType[0] == 122)
		{
			static type[1];
			type[0] = szCheatType[0];
			if (g_eConfig[131])
			{
				set_task(flBanDelay, "BanClient", id + taskid_ban_client, type, 1, "c", 0);
			}
			else
			{
				set_task(0.1, "BanClient", id + taskid_ban_client, type, 1, "c", 0);
			}
			g_bWaitingBan[id] = 1;
		}
	}
	return 0;
}

public ShowNotification(id)
{
	set_dhudmessage(255, 0, 0, -1082130432, 1041865114, 0, 1086324736, 1084227584, 1056964608, 1056964608);
	show_dhudmessage(0, "%s has been punished for using cheats!", g_ePlayer[id][61]);
	client_print(0, 2, "%s %s has been punished for using cheats!", sz_plugin_custom_prefix, g_ePlayer[id][61]);
	if (g_eConfig[308])
	{
		emit_sound(id, 6, PUNISH_SOUND, 1045220557, 1061997773, 0, 100);
	}
	g_iNotifyQueque -= 1;
	return 0;
}

public BanClient(type[], id)
{
	static szUserID[8];
	formatex(szUserID, 7, "#%i", get_user_userid(id));
	static szCmd[80];
	copy(szCmd, 79, sz_plugin_string_main_ban);
	replace(szCmd, 79, "%name%", "^"%name%^"");
	replace(szCmd, 79, "%name%", g_ePlayer[id][61]);
	replace(szCmd, 79, "%steam_id%", "%steamid%");
	replace(szCmd, 79, "%steamid%", "^"%steamid%^"");
	replace(szCmd, 79, "%steamid%", g_ePlayer[id][e_steamid]);
	replace(szCmd, 79, "%ip%", g_ePlayer[id][114]);
	replace(szCmd, 79, "%userid%", szUserID);
	replace(szCmd, 79, "%time%", 173580);
	replace(szCmd, 79, "%reason%", "^"%reason%^"");
	replace(szCmd, 79, "%reason%", sz_plugin_reason_of_punish);
	if (type[0] != 122)
	{
		server_cmd(szCmd);
		server_exec();
	}
	new var1;
	if (containi(sz_plugin_debug_mode, "") != -1 && g_ePlayer[id][7])
	{
		client_print_color(id, -2, "\x04[DEBUG] \x03%s", szCmd);
	}
	g_bWaitingBan[id] = 0;
	return 0;
}

BanDisconnectedClient(id)
{
	if (g_eConfig[307])
	{
		g_iNotifyQueque += 1;
		new Float:flElapsedTime = floatsub(get_gametime(), g_flLastNotification);
		if (flElapsedTime >= 7.0)
		{
			ShowNotification(id + 61359);
		}
		else
		{
			set_task(floatsub(1088421888 * g_iNotifyQueque, flElapsedTime), "ShowNotification", id + 61359, 30724, MaxClients, "c", MaxClients);
		}
		g_flLastNotification = get_gametime();
	}
	static szUserID[8];
	formatex(szUserID, 7, "#%i", get_user_userid(id));
	static szCmd[80];
	copy(szCmd, 79, sz_plugin_string_other_ban);
	replace(szCmd, 79, "%name%", "^"%name%^"");
	replace(szCmd, 79, "%name%", g_ePlayer[id][61]);
	replace(szCmd, 79, "%steam_id%", "%steamid%");
	replace(szCmd, 79, "%steamid%", "^"%steamid%^"");
	replace(szCmd, 79, "%steamid%", g_ePlayer[id][e_steamid]);
	replace(szCmd, 79, "%ip%", g_ePlayer[id][114]);
	replace(szCmd, 79, "%userid%", szUserID);
	replace(szCmd, 79, "%time%", 174588);
	replace(szCmd, 79, "%reason%", "^"%reason%^"");
	replace(szCmd, 79, "%reason%", sz_plugin_reason_of_punish);
	server_cmd(szCmd);
	server_exec();
	g_bWaitingBan[id] = 0;
	return 0;
}

ResetPunishment(id)
{
	arrayset(g_bPunished[id], MaxClients, 11);
	g_bWaitingBan[id] = 0;
	return 0;
}

CollectGraphData(id)
{
	new frame = g_eGraph[id][1];
	g_eGraph[id][2][frame] = 0;
	if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
	{
		g_eGraph[id][2][frame] |= 1;
	}
	else
	{
		if (g_ePlayer[id][12] == 5)
		{
			g_eGraph[id][2][frame] |= 2;
		}
		if (g_ePlayer[id][e_PlayerFlags] & IN_BACK)
		{
			g_eGraph[id][2][frame] |= 4;
		}
	}
	if (g_ePlayer[id][ucButtons] & IN_FORWARD) {
		g_eGraph[id][2][frame] |= 8;
	}
	
	if (g_ePlayer[id][ucButtons] & IN_BACK) {
		g_eGraph[id][2][frame] |= 16;
	}
	
	if (g_ePlayer[id][ucButtons] & IN_MOVELEFT) {
		g_eGraph[id][2][frame] |= 32;
	}
	
	if (g_ePlayer[id][ucButtons] & IN_MOVERIGHT) {
		g_eGraph[id][2][frame] |= 64;
	}
	
	if (g_ePlayer[id][42] < 0) {
		g_eGraph[id][2][frame] |= 128;
	}
	else
	{
		if (g_ePlayer[id][42] > 0) {
			g_eGraph[id][2][frame] |= 256;
		}
	}
	
	if (g_ePlayer[id][41] < 0)
	{
		g_eGraph[id][2][frame] |= 1024;
	}
	else
	{
		if (g_ePlayer[id][41] > 0)
		{
			g_eGraph[id][2][frame] |= 512;
		}
	}
	
	if (g_ePlayer[id][ucButtons] & IN_JUMP) {
		g_eGraph[id][2][frame] |= 2048;
	}
	
	if (g_ePlayer[id][ucButtons] & IN_DUCK) {
		g_eGraph[id][2][frame] |= 4096;
	}
	
	if (g_ePlayer[id][4] || (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND && g_ePlayer[id][FOG_current] <= 5 && (g_ePlayer[id][e_jumped] || (g_ePlayer[id][e_ducked] && ~g_ePlayer[id][e_PlayerFlags] & 16384))))
	{
		if (g_ePlayer[id][4])
		{
			g_eGraph[id][2][frame] |= 32768;
		}
		
		if (g_eBhopChecker[id][bhcIdealCandidate] || g_eGstrafe[id][1])
		{
			g_eGraph[id][2][frame] |= 8192;
		}
		g_eGraph[id][2][frame] |= 16384;
	}
	g_eGraph[id][1]++;
	if (5000 <= g_eGraph[id][1])
	{
		g_eGraph[id][0] = 1;
		g_eGraph[id][1] = 0;
	}
	return 0;
}

WriteGraphData(id, file)
{
	decl frames;
	new var1;
	if (g_eGraph[id][0])
	{
		var1 = 5000;
	}
	else
	{
		var1 = g_eGraph[id][1];
	}
	frames = var1;
	static frame;
	static buffer[8];
	new i;
	while (i < frames)
	{
		if (g_eGraph[id][0])
		{
			frame = g_eGraph[id][1][i] % 5000;
		}
		else
		{
			frame = i;
		}
		if (frames - 1 > i)
		{
			formatex(buffer, 7, "%i,", g_eGraph[id][2][frame]);
		}
		else
		{
			formatex(buffer, 7, "%i", g_eGraph[id][2][frame]);
		}
		fputs(file, buffer, MaxClients);
		i++;
	}
	return 0;
}

ResetGraphData(id)
{
	arrayset(g_eGraph[id], MaxClients, 5002);
	return 0;
}

API_Init()
{
	get_localinfo("ca_api_key", g_szApiKey, "NO_ACC_COM");
	if (!g_szApiKey[0])
	{
		LogError(2, "ERROR: API key is not found!");
	}
	get_user_ip(MaxClients, g_szServerIP, 21, MaxClients);
	if (!g_szServerIP[0])
	{
		LogError(2, "ERROR: Couldn't retrieve server IP address!");
	}
	formatex(g_szUserAgent, 47, "%s/%s", PLUGIN, VERSION);
	curl_slist_append(g_hHeaders, "Content-Type: multipart/form-data");
	PurgeTempDir();
	formatex(g_szTempVersion, 95, "%s/version.tmp", g_szTempDir);
	formatex(g_szTempConfig, 95, "%s/config.tmp", g_szTempDir);
	formatex(g_szTempUpdate, 95, "%s/update.tmp", g_szTempDir);
	API_CheckVersion();
	return 0;
}

API_CheckVersion()
{
	server_print("[CA] Checking for updates...");
	static url[128];
	formatex(url, 127, "%s/api/get_version2?key=%s&ip=%s&amxx_version=%i", CURL_HOST, g_szApiKey, g_szServerIP, 190);
	static data[2];
	data[0] = fopen(g_szTempVersion, "wb");
	data[1] = 1;
	if (!data[0])
	{
		LogError(2, "ERROR: Couldn't open temp file! (#1)");
	}
	API_Request(0, url, data, 2, "API_CheckVersion_CB", "write", 0);
	return 0;
}

public API_CheckVersion_CB(CURL:curl, CURLcode:code, data[])
{
	new msec = GetRequestTime(curl);
	static response;
	curl_easy_getinfo(curl, 2097154, response);
	curl_easy_cleanup(curl);
	fclose(data[0]);
	if (code)
	{
		static error[256];
		curl_easy_strerror(code, error, 255);
		LogError(2, "ERROR: Couldn't check for updates! (#%i: %s)", code, error);
	}
	static content[96];
	if (LoadFileForMe(g_szTempVersion, content, 95, 0) == -1)
	{
		LogError(2, "ERROR: Couldn't load temp file content! (#1)");
	}
	delete_fil3(g_szTempVersion);
	if (equal(content, "[CA] ERROR: Bad request!", MaxClients))
	{
		LogError(2, "ERROR: Bad API request! (#1)");
	}
	else
	{
		if (equal(content, "[CA] ERROR: Server is deactivated!", MaxClients))
		{
			LogError(2, "ERROR: Server is deactivated!");
		}
	}
	if (!replace(content, 95, "@ok\n", 841464))
	{
		LogError(2, "ERROR: Bad HTTP status code: %i (#1)", response);
	}
	static updateInfo[3][48];
	ExplodeStr1ng(updateInfo, 3, 47, content, 10);
	new var1 = updateInfo;
	copy(g_eUpdate, 11, var1[0][var1]);
	g_eUpdate[12] = str_to_num(updateInfo[1]);
	g_eUpdate[13] = str_to_num(updateInfo[2]);
	if (g_eUpdate[12] > VERSION_NUM)
	{
		server_print("[CA] Доступна новая версия %s! (%ims)", g_eUpdate, msec);
		API_UpdatePlugin();
	}
	else
	{
		server_print("[CA] OK! Плагин обновлен. (%ims)", msec);
		API_LoadConfig(0);
	}
	return 0;
}

API_UpdatePlugin()
{
	server_print("[CA] Обновление...");
	get_localinfo("amxx_pluginsdir", g_szPluginsDir, 63);
	if (file_exists(g_szTempUpdate, MaxClients))
	{
		delete_fil3(g_szTempUpdate);
	}
	static url[128];
	formatex(url, 127, "%s/api/get_plugin?key=%s&ip=%s&amxx_version=%i", CURL_HOST, g_szApiKey, g_szServerIP, 190);
	static data[2];
	data[0] = fopen(g_szTempUpdate, "wb");
	data[1] = 1;
	if (!data[0])
	{
		LogError(2, "ERROR: Couldn't open file!");
	}
	API_Request(0, url, data, 2, "API_UpdatePlugin_CB", "writeUpdate", 0);
	return 0;
}

public API_UpdatePlugin_CB(CURL:curl, CURLcode:code, data[])
{
	new msec = GetRequestTime(curl);
	static response;
	curl_easy_getinfo(curl, 2097154, response);
	curl_easy_cleanup(curl);
	fclose(data[0]);
	if (code)
	{
		static error[256];
		curl_easy_strerror(code, error, 255);
		LogError(2, "ERROR: Couldn't update plugin! (#%i: %s)", code, error);
	}
	new filesize = file_size(g_szTempUpdate, MaxClients);
	if (g_eUpdate[13] == filesize)
	{
		static szPluginPath[96];
		formatex(szPluginPath, 95, "%s/client_analyzer.amxx", g_szPluginsDir);
		if (!file_exists(szPluginPath, MaxClients))
		{
			LogError(2, "ERROR: Couldn't find %s file!", szPluginPath);
		}
		static szVersion[12];
		szVersion = VERSION;
		replace_all(szVersion, 11, 845468, 845476);
		static szBackupPath[96];
		formatex(szBackupPath, 95, "%s/client_analyzer_v%s.amxx", g_szPluginsDir, szVersion);
		if (file_exists(szBackupPath, MaxClients))
		{
			delete_fil3(szBackupPath);
		}
		if (!rename_file(szPluginPath, szBackupPath, 1))
		{
			LogError(2, "ERROR: Couldn't rename plugin! (#1)");
		}
		if (!rename_file(g_szTempUpdate, szPluginPath, 1))
		{
			LogError(2, "ERROR: Couldn't rename plugin! (#2)");
		}
		LogError(0, "NOTICE: Plugin was updated from %s to %s version.", VERSION, g_eUpdate);
		server_print("[CA] OK! Successfully updated from %s to %s version. (%ims)", VERSION, g_eUpdate, msec);
		server_print("[CA] Please, restart the server to apply changes.");
	}
	else
	{
		LogError(2, "ERROR: Incorrect file size! Received %i of expected %i bytes. (status code: %i)", filesize, 837328 + 52, response);
	}
	return 0;
}

API_LoadConfig(reload)
{
	new var1;
	if (reload)
	{
		var1 = 847328;
	}
	else
	{
		var1 = 847368;
	}
	server_print("[CA] %s configuration...", var1);
	static url[128];
	formatex(url, 127, "%s/api/get_configuration2?key=%s&ip=%s", CURL_HOST, g_szApiKey, g_szServerIP);
	static data[2];
	data[0] = fopen(g_szTempConfig, "wb");
	data[1] = !reload;
	if (!data[0])
	{
		LogError(reload ? 1 : 2, "ERROR: Couldn't open temp file! (#2)");
		if (reload)
		{
			return 0;
		}
	}
	API_Request(0, url, data, 2, "API_LoadConfig_CB", "write", 0);
	return 0;
}

public API_LoadConfig_CB(CURL:curl, CURLcode:code, data[])
{
	new msec = GetRequestTime(curl);
	static response;
	curl_easy_getinfo(curl, 2097154, response);
	curl_easy_cleanup(curl);
	fclose(data[0]);
	if (code)
	{
		static error[256];
		curl_easy_strerror(code, error, 255);
		LogError(data[1] ? 2 : 1, "ERROR: Couldn't load configuration! (#%i: %s)", code, error);
		if (!data[1])
		{
			return 0;
		}
	}
	static content[256];
	if (LoadFileForMe(g_szTempConfig, content, 255, 0) == -1)
	{
		LogError((data[1] ? 2 : 1, "ERROR: Couldn't load temp file content! (#2)");
		if (!data[1])
		{
			return 0;
		}
	}
	delete_fil3(g_szTempConfig, 0, "GAMECONFIG");
	if (equal(content, "[CA] ERROR: Bad request!"))
	{
		LogError( data[1] ? 2 : 1, "ERROR: Bad API request! (#2)");
		if (!data[1])
		{
			return 0;
		}
	}
	if (!replace(content, 255, "@ok\n", 850984/*char 8*/))
	{
		LogError(data[1] ? 2 : 1, "ERROR: Bad HTTP status code: %i (#2)", response);
		if (!data[1])
		{
			return 0;
		}
	}
	static settings[374][64];
	ExplodeStr1ng(settings, 374, 63, content, 10);
	new i;
	
	plugin_just_admin_in_bytes = str_to_num(settings[++i]); 				// админ в байтах
	plugin_main_admin_in_bytes = str_to_num(settings[++i]); 				// суперадмин в байтах
	plugin_automatically_punish = str_to_num(settings[++i]); 				// автоматический бан
	copy(sz_plugin_string_main_ban, 63, settings[i++]);		// основной бан
	copy(sz_plugin_string_other_ban, 63, settings[i++]);	// сторонний бан
	plugin_using_delay_punish = str_to_num(settings[i++]);				// задержка бана
	copy(sz_plugin_block_modules, 15, settings[i++]);		// [cheattype] модули которые блокируют читы
	copy(sz_plugin_debug_mode, 15, settings[i++]);			// дебаг мод
	copy(sz_plugin_demo_name, 63, settings[i++]);			// название демки
	plugin_recording_demo_auto = str_to_num(settings[i++]);				// записывать демо автоматом
	plugin_recording_demo_counts = str_to_num(settings[i++]);				// сколько демо писать цикличко после коннекта
	plugin_recording_demo_use_nvault = str_to_num(settings[i++]);				// использовать nvault
	plugin_recording_demo_status = str_to_num(settings[i++]);				// запись демо
	copy(sz_plugin_punish_modules, 15, settings[i++]);		// [cheattype] модули которые банят
	plugin_using_tasks = str_to_num(settings[i++]);				// таски
	plugin_using_graph = str_to_num(settings[i++]);				// график
	copy(sz_plugin_hud_info, 7, settings[i++]);				// худ инфо
	copy(sz_plugin_modules_working, 15, settings[i++]);		// [cheattype] модули которые работают
	copy(sz_plugin_custom_prefix, 15, settings[i++]);		// префикс
	plugin_print_warns_for_admins = str_to_num(settings[i++]);				// хз что это
	copy(sz_plugin_modules, 15, settings[i++]);				// [cheattype] модули
	plugin_punish_disconnected = str_to_num(settings[i++]);				// банить вышедших
	plugin_emit_sounds = str_to_num(settings[i++]);				// emit sound
	copy(sz_plugin_reason_of_punish, 63, settings[i++]);	// причина бана
	plugin_bhop_stats = str_to_num(settings[i]);				// бхоп статистика
	new var5;
	if (data[1])
	{
		var5 = 948564;
	}
	else
	{
		var5 = 948592;
	}
	server_print("[CA] OK! Configuration successfully %s. (%ims)", var5, msec);
	if (!data[1])
	{
		PrintToAdmins(-3, true, "\x04[CA] \x03ADMIN: Configuration was successfully reloaded!");
	}
	API_OnLoad();
	return 0;
}

API_OnLoad()
{
	InitCore();
	InitOptional();
	new id = 1;
	while (id < 33)
	{
		new var1;
		if (is_user_connected(id) && g_ePlayer[id][0])
		{
			RegisterClientTasks(id);
		}
		id++;
	}
	return 0;
}

API_CheckProxy(ip[], userid)
{
	static url[96];
	formatex(url, 95, "%s/api/get_proxy_status/%s", CURL_HOST, ip);
	static szTempFile[96];
	formatex(szTempFile, 95, "%s/%s", g_szTempDir, ip);
	replace_all(szTempFile, 95, 949748, 949756);
	add(szTempFile, 95, ".tmp", MaxClients);
	static data[3];
	data[0] = fopen(szTempFile, "wb");
	data[1] = 0;
	data[2] = userid;
	if (!data[0])
	{
		LogError(1, "ERROR: Couldn't open temp file! (#3)");
		return 0;
	}
	API_Request(0, url, data, 3, "API_CheckProxy_CB", "write", 0);
	return 0;
}

public API_CheckProxy_CB(CURL:curl, CURLcode:code, data[])
{
	static response;
	curl_easy_getinfo(curl, 2097154, response);
	static url[96];
	curl_easy_getinfo(curl, 1048577, url, 95);
	curl_easy_cleanup(curl);
	fclose(data[0]);
	if (code)
	{
		static error[256];
		curl_easy_strerror(code, error, 255);
		LogError(1, "ERROR: Couldn't check for proxy! (#%i: %s)", code, error);
		return 0;
	}
	static ip[6][32];
	ExplodeStr1ng(ip, 6, 31, url, 47);
	static szTempFile[96];
	formatex(szTempFile, 95, "%s/%s", g_szTempDir, ip[5]);
	replace_all(szTempFile, 95, 952836, 952844);
	add(szTempFile, 95, ".tmp", MaxClients);
	static content[8];
	if (LoadFileForMe(szTempFile, content, 7, 0) == -1)
	{
		LogError(1, "ERROR: Couldn't load temp file content! (#3)");
		return 0;
	}
	delete_fil3(szTempFile);
	new var1;
	if (strfind(content, "true", MaxClients, MaxClients) == -1 && strfind(content, "false", MaxClients, MaxClients) == -1)
	{
		LogError(1, "ERROR: Bad HTTP status code: %i (#3)", response);
		return 0;
	}
	if (content[0] == 116)
	{
		nvault_pset(g_hProxyVault, ip[5], 953276);
		server_cmd("amx_kick #%i ^"Proxy detected^"", data[2]);
	}
	else
	{
		nvault_pset(g_hProxyVault, ip[5], 953404);
	}
	return 0;
}

API_LogClient(id, szSessionTime[], szGameTime[], szPunishment[], szType[], szCheatDetails[])
{
	server_print("[CA] Logging %s (%s) to database...", g_ePlayer[id][61], g_ePlayer[id][e_steamid]);
	static url[128];
	formatex(url, 127, "%s/api/log_client?key=%s&ip=%s", CURL_HOST, g_szApiKey, g_szServerIP);
	static szBuild[5];
	num_to_str(g_iBuild[id], szBuild, NULL_STRING);
	static szRandom[16];
	GetRandomString(szRandom, 15);
	static szTempFile[96];
	formatex(szTempFile, 95, "%s/%s.tmp", g_szTempDir, szRandom);
	new file = fopen(szTempFile, "wt");
	if (g_eConfig[249])
	{
		WriteGraphData(id, file);
	}
	fputc(file, 10);
	fputs(file, VERSION, MaxClients);
	fputc(file, 10);
	fputs(file, g_ePlayer[id][61], MaxClients);
	fputc(file, 10);
	fputs(file, g_ePlayer[id][e_steamid], MaxClients);
	fputc(file, 10);
	fputs(file, g_ePlayer[id][114], MaxClients);
	fputc(file, 10);
	fputs(file, g_szMap, MaxClients);
	fputc(file, 10);
	fputs(file, szSessionTime, MaxClients);
	fputc(file, 10);
	fputs(file, szGameTime, MaxClients);
	fputc(file, 10);
	fputs(file, szBuild, MaxClients);
	fputc(file, 10);
	fputs(file, g_eDemo[id][23], MaxClients);
	fputc(file, 10);
	fputs(file, szPunishment, MaxClients);
	fputc(file, 10);
	fputs(file, szType, MaxClients);
	fputc(file, 10);
	fputs(file, szCheatDetails, MaxClients);
	fclose(file);
	static data[4];
	data[0] = fopen(szTempFile, "rb");
	data[1] = id;
	data[2] = 0;
	data[3] = 0;
	API_Request(1, url, data, 4, "API_LogClient_CB", "read", file_size(szTempFile, MaxClients));
	return 0;
}

API_LogBhopStats(id)
{
	server_print("[CA] Logging bhop stats of %s (%s) to database...", g_ePlayer[id][61], g_ePlayer[id][e_steamid]);
	static url[128];
	formatex(url, 127, "%s/api/log_bhop_stats?key=%s&ip=%s", CURL_HOST, g_szApiKey, g_szServerIP);
	static szSessionTime[8];
	GetSessionTime(id, szSessionTime, 7);
	static szGameTime[8];
	GetGameTime(szGameTime, 7, 0);
	static szBuild[5];
	num_to_str(g_iBuild[id], szBuild, NULL_STRING);
	static szBhopStats[512];
	formatex(szBhopStats, 511, "%i\n%i\n%i\n%i\n%i\n%.2f\n%.2f\n%.2f\n%i\n%i\n%i\n%i\n%i\n%i\n%.2f\n%.2f\n%.2f\n%.2f\n%.2f\n%.2f\n", g_eBhopStats[id][1][BHOP_SKILL], g_eBhopStats[id][1][BHOPS], g_eBhopStats[id][1], g_eBhopStats[id][1][1], g_eBhopStats[id][1][2], g_eBhopStats[id][1][40], g_eBhopStats[id][1][41], g_eBhopStats[id][1][42], g_eBhopStats[id][1][4], g_eBhopStats[id][1][5], g_eBhopStats[id][1][6], g_eBhopStats[id][1][BHOP_FOG3], g_eBhopStats[id][1][BHOP_FOG4], g_eBhopStats[id][1][BHOP_FOG5], g_eBhopStats[id][1][FOG0_P], g_eBhopStats[id][1][FOG1_P], g_eBhopStats[id][1][FOG2_P], g_eBhopStats[id][1][FOG3_P], g_eBhopStats[id][1][FOG4_P], g_eBhopStats[id][1][FOG5_P]);
	format(szBhopStats, 511, "%s%i\n%i\n%i\n%i\n%i\n%i\n%.2f\n%.2f\n%.2f\n%i\n%i\n%.2f\n%i\n%i\n%i\n%.2f\n%.2f\n%i\n", szBhopStats, g_eBhopStats[id][1][13], g_eBhopStats[id][1][14], g_eBhopStats[id][1][15], g_eBhopStats[id][1][25], g_eBhopStats[id][1][26], g_eBhopStats[id][1][27], g_eBhopStats[id][1][52], g_eBhopStats[id][1][53], g_eBhopStats[id][1][54], g_eBhopStats[id][1][WHIO3FOG], g_eBhopStats[id][1][BHOP_IDEAL], g_eBhopStats[id][1][BHOP_IDEAL_P], g_eBhopStats[id][1][BHOP_IDEAL_IAR], g_eBhopStats[id][1][17], g_eBhopStats[id][1][18], g_eBhopStats[id][1][50], g_eBhopStats[id][1][51], g_eBhopStats[id][1][BHOP_NOT_IDEAL_IAR]);
	format(szBhopStats, 511, "%s%i\n%i\n%i\n%i\n%.2f\n%.2f\n%.2f\n%.2f\n%i\n%i\n%.2f\n%i\n%.2f\n", szBhopStats, g_eBhopStats[id][1][29], g_eBhopStats[id][1][30], g_eBhopStats[id][1][31], g_eBhopStats[id][1][32], g_eBhopStats[id][1][55], g_eBhopStats[id][1][56], g_eBhopStats[id][1][57], g_eBhopStats[id][1][59], g_eBhopStats[id][1][38], g_eBhopStats[id][1][33], g_eBhopStats[id][1][58], g_eBhopStats[id][1][FAST_SCROLLED], g_eBhopStats[id][1][FAST_SCROLLED_P]);
	format(szBhopStats, 511, "%s%i\n%.2f\n%.2f\n%.2f\n%.2f\n%.2f\n%.2f\n%.2f\n%.2f\n", szBhopStats, g_eBhopStats[id][1][37], g_eBhopStats[id][1][61], g_eBhopStats[id][1][62], g_eBhopStats[id][1][63], g_eBhopStats[id][1][64], g_eBhopStats[id][1][65], g_eBhopStats[id][1][66], g_eBhopStats[id][1][67], g_eBhopStats[id][1][68]);
	static szRandom[16];
	GetRandomString(szRandom, 15);
	static szTempFile[96];
	formatex(szTempFile, 95, "%s/%s.tmp", g_szTempDir, szRandom);
	new file = fopen(szTempFile, "wt");
	if (g_eConfig[249])
	{
		WriteGraphData(id, file);
	}
	fputc(file, 10);
	fputs(file, VERSION, MaxClients);
	fputc(file, 10);
	fputs(file, g_ePlayer[id][61], MaxClients);
	fputc(file, 10);
	fputs(file, g_ePlayer[id][e_steamid], MaxClients);
	fputc(file, 10);
	fputs(file, g_ePlayer[id][114], MaxClients);
	fputc(file, 10);
	fputs(file, g_szMap, MaxClients);
	fputc(file, 10);
	fputs(file, szSessionTime, MaxClients);
	fputc(file, 10);
	fputs(file, szGameTime, MaxClients);
	fputc(file, 10);
	fputs(file, szBuild, MaxClients);
	fputc(file, 10);
	fputs(file, g_eDemo[id][23], MaxClients);
	fputc(file, 10);
	fputs(file, szBhopStats, MaxClients);
	fclose(file);
	static data[4];
	data[0] = fopen(szTempFile, "rb");
	data[1] = id;
	data[2] = 0;
	data[3] = 1;
	API_Request(1, url, data, 4, "API_LogClient_CB", "read", file_size(szTempFile, MaxClients));
	return 0;
}

public API_LogClient_CB(CURL:curl, CURLcode:code, data[])
{
	curl_easy_cleanup(curl);
	fclose(data[0]);
	if (code)
	{
		static error[256];
		curl_easy_strerror(code, error, 255);
		new id = data[1];
		new var1;
		if (data[3])
		{
			var1 = 960656;
		}
		else
		{
			var1 = 960716;
		}
		LogError(1, "ERROR: Couldn't log %s%s (%s) to database! (#%i: %s)", var1, g_ePlayer[id][61], g_ePlayer[id][e_steamid], code, error);
	}
	return 0;
}

API_Request(type, url[], data[], size, callback[], processFunc[], contentSize)
{
	new CURL:curl = curl_easy_init();
	if (!curl)
	{
		fclose(data[0]);
		new var1;
		if (data[1])
		{
			var1 = 2;
		}
		else
		{
			var1 = 1;
		}
		LogError(var1, "ERROR: Couldn't initialize cURL!");
		if (!data[1])
		{
			return 0;
		}
	}
	curl_easy_setopt(curl, 10002, url);
	curl_easy_setopt(curl, 10018, g_szUserAgent);
	curl_easy_setopt(curl, 64, 0);
	curl_easy_setopt(curl, 81, 0);
	curl_easy_setopt(curl, 78, 10);
	curl_easy_setopt(curl, 13, 10);
	curl_easy_setopt(curl, 99, 1);
	if (type)
	{
		curl_easy_setopt(curl, 10023, g_hHeaders);
		curl_easy_setopt(curl, 47, 1);
		curl_easy_setopt(curl, 60, contentSize);
		curl_easy_setopt(curl, 10009, data);
		curl_easy_setopt(curl, 20012, processFunc);
	}
	else
	{
		curl_easy_setopt(curl, 98, 1024);
		curl_easy_setopt(curl, 20011, processFunc);
		curl_easy_setopt(curl, 10001, data);
	}
	curl_easy_perform(curl, callback, data, size);
	return 0;
}

public read(data[], size, nmemb, file)
{
	return fread_blocks(file, data, nmemb, 1);
}

public write(data[], size, nmemb, file)
{
	return fwrite_blocks(file, data, nmemb, 1);
}

public writeUpdate(data[], size, nmemb, file)
{
	return fwrite_blocks(file, data, nmemb, 1);
}

GetRequestTime(CURL:curl)
{
	static Float:seconds;
	curl_easy_getinfo(curl, 3145731, seconds);
	return floatround(seconds * 1000, MaxClients);
}

PurgeTempDir()
{
	formatex(g_szTempDir, 63, "%s/client_analyzer_temp", g_szDataDir);
	if (!dir_exists(g_szTempDir, MaxClients))
	{
		mkdir(g_szTempDir, 511);
		return 0;
	}
	static dir;
	static filename[32];
	dir = open_dir(g_szTempDir, filename, "", 0);
	while (next_file(dir, filename, "", 0))
	{
		if (!(filename[0] == 46))
		{
			static filepath[96];
			formatex(filepath, 95, "%s/%s", g_szTempDir, filename);
			delete_fil3(filepath);
		}
	}
	close_dir(dir);
	return 0;
}

public UnknownCommandWorkaround()
{
	return 1;
}

public cmdGetCVar(id, lvl, cid)
{
	new var1;
	if (!cmd_access(id, lvl, cid, 3, false) || read_argc() < 3)
	{
		return 1;
	}
	static szTarget[32];
	read_argv(1, szTarget, "");
	new iTarget = cmd_target(id, szTarget, 10);
	if (!iTarget)
	{
		return 1;
	}
	static szCVar[64];
	read_argv(2, szCVar, 63);
	static iParams[1];
	iParams[0] = id;
	query_client_cvar(iTarget, szCVar, "cmdGetCVar_Result", 1, iParams);
	return 1;
}

public cmdGetCVar_Result(iTarget, szCVar[], szValue[], iParams[])
{
	new id = iParams[0];
	if (equal(szValue, "Bad CVAR request", MaxClients))
	{
		console_print(id, "%s Client %s (%s) doesn't have %s cvar", sz_plugin_custom_prefix, g_ePlayer[iTarget][61], g_ePlayer[iTarget][93], szCVar);
	}
	else
	{
		console_print(id, "%s Client %s (%s) has %s %s", sz_plugin_custom_prefix, g_ePlayer[iTarget][61], g_ePlayer[iTarget][93], szCVar, szValue);
	}
	return 0;
}

public cmdSendCmd(id, lvl, cid)
{
	new var1;
	if (!cmd_access(id, lvl, cid, 3, false) || read_argc() < 3)
	{
		return 1;
	}
	static szTarget[32];
	read_argv(1, szTarget, "");
	new iTarget = cmd_target(id, szTarget, 10);
	if (!iTarget)
	{
		return 1;
	}
	if (get_gametime() < g_flNextCheckAllowedSince[iTarget])
	{
		console_print(id, "%s You need to wait for previous check response!", sz_plugin_custom_prefix);
		return 1;
	}
	static szMethod[2];
	read_argv(NULL_STRING, szMethod, 1);
	read_argv(2, g_szCmdName[iTarget], 63);
	if (szMethod[0] == 49)
	{
		client_cmd(iTarget, g_szCmdName[iTarget]);
	}
	else
	{
		client_cmd(iTarget, g_szCmdName[iTarget]);
	}
	static szDelay[8];
	read_argv(3, szDelay, 7);
	new Float:flDelay = str_to_float(szDelay);
	if (flDelay < 0.1)
	{
		flDelay = 0.1;
	}
	static iParams[1];
	iParams[0] = iTarget;
	set_task(flDelay, "cmdSendCmd_Result", id + 61423, iParams, 1, "c", MaxClients);
	g_bLookingForCmd[iTarget] = 1;
	g_flNextCheckAllowedSince[iTarget] = floatadd(get_gametime(), flDelay);
	return 1;
}

public cmdSendCmd_Result(iParams[], id)
{
	new target = iParams[0];
	new var1;
	if (g_bLookingForCmd[target])
	{
		var1 = 971720;
	}
	else
	{
		var1 = 971736;
	}
	console_print(id - 61423, "%s Client %s (%s) %s %s command", sz_plugin_custom_prefix, g_ePlayer[target][61], g_ePlayer[target][93], var1, g_szCmdName[target]);
	g_bLookingForCmd[target] = 0;
	return 0;
}

public cmdReloadConfig(id, lvl, cid)
{
	if (!cmd_access(id, lvl, cid, 1, false))
	{
		return 1;
	}
	API_LoadConfig(1);
	return 1;
}

ShowHudInfo(id)
{
	decl iPlayer;
	new var1;
	if (g_eHUD[id][0] >= 2 && is_user_alive(id))
	{
		var2 = id;
	}
	else
	{
		var2 = pev(id, 101);
	}
	iPlayer = var2;
	if (!iPlayer)
	{
		return 0;
	}
	if (containi(sz_plugin_hud_info, "d") != -1)
	{
		new var6;
		if (g_ePlayer[iPlayer][4] || (g_ePlayer[iPlayer][10] & FL_ONGROUND && g_ePlayer[iPlayer][22] <= 5 && (g_ePlayer[iPlayer][1] || (g_ePlayer[iPlayer][2] && ~g_ePlayer[iPlayer][10] & 16384))))
		{
			g_eHUD[id][1] = g_ePlayer[iPlayer][22];
			g_eHUD[id][7] = g_ePlayer[iPlayer][37];
			if (!g_ePlayer[iPlayer][4])
			{
				new var7;
				if (g_eBhopChecker[iPlayer][bhcIdealCandidate] || g_eGstrafe[iPlayer][1])
				{
				}
			}
		}
		set_dhudmessage(g_eHUD[id][2], g_eHUD[id][3], g_eHUD[id][4], 1057467924, 1057803469, MaxClients, 1086324736, 1036831949, MaxClients, MaxClients);
		show_dhudmessage(id, "%i\n%.3f", g_eHUD[id][1], g_eHUD[id][7]);
	}
	if (containi(sz_plugin_hud_info, "e") != -1)
	{
		if (is_user_alive(iPlayer))
		{
			new var9;
			if (g_ePlayer[iPlayer][1] || (g_ePlayer[iPlayer][13] & 2 && g_ePlayer[iPlayer][27] < 5))
			{
				g_eHUD[id][5]++;
			}
			else
			{
				if (20 <= g_ePlayer[iPlayer][27])
				{
					g_eHUD[id][5] = 0;
				}
			}
			if (g_ePlayer[iPlayer][28])
			{
				if (8 <= g_ePlayer[iPlayer][28])
				{
					g_eHUD[id][6] = 0;
				}
			}
			g_eHUD[id][6]++;
		}
		decl iScrolls;
		new var10;
		if (g_ePlayer[iPlayer][3])
		{
			var10 = g_eHUD[id][6];
		}
		else
		{
			var10 = g_eHUD[id][5];
		}
		iScrolls = var10;
		static iScrollsColor[3];
		if (!(iScrolls >= 10))
		{
			if (iScrolls >= 4)
			{
			}
		}
		if (0 < iScrolls)
		{
			set_dhudmessage(iScrollsColor[0], iScrollsColor[1], iScrollsColor[2], 1055957975, 1057803469, MaxClients, 1086324736, 1036831949, MaxClients, MaxClients);
			show_dhudmessage(id, 973112, iScrolls);
		}
	}
	if (containi(sz_plugin_hud_info, 973124) != -1)
	{
		decl iIdealIar;
		new var11;
		if (g_ePlayer[iPlayer][3])
		{
			var11 = g_eGstrafeTotal[iPlayer][8];
		}
		else
		{
			var11 = g_eBhopStats[iPlayer][1][19];
		}
		iIdealIar = var11;
		static iIdealIarColor[3];
		if (!(iIdealIar >= 15))
		{
			if (iIdealIar >= 10)
			{
			}
		}
		if (iIdealIar >= 5)
		{
			set_dhudmessage(iIdealIarColor[0], iIdealIarColor[1], iIdealIarColor[2], 1055957975, 1058390671, 0, 1086324736, 1036831949, 0, 0);
			show_dhudmessage(id, 973180, iIdealIar);
		}
	}
	if (containi(sz_plugin_hud_info, 973192) != -1)
	{
		set_dhudmessage(255, 255, 255, 1056293519, 1052602532, 0, 1086324736, 1036831949, 0, 0);
		new var12;
		if (g_ePlayer[iPlayer][ucButtons] & IN_MOVERIGHT)
		{
			var12 = 973304;
		}
		else
		{
			var12 = 973312;
		}
		new var13;
		if (g_ePlayer[iPlayer][ucButtons] & IN_BACK)
		{
			var13 = 973288;
		}
		else
		{
			var13 = 973296;
		}
		new var14;
		if (g_ePlayer[iPlayer][ucButtons] & IN_MOVELEFT)
		{
			var14 = 973272;
		}
		else
		{
			var14 = 973280;
		}
		new var15;
		if (g_ePlayer[iPlayer][ucButtons] & IN_FORWARD)
		{
			var15 = 973256;
		}
		else
		{
			var15 = 973264;
		}
		show_dhudmessage(id, "  %s\n%s %s %s", var15, var14, var13, var12);
	}
	new var16;
	if (containi(sz_plugin_hud_info, "e") != -1 && g_eMoves[iPlayer][mvInvalidTicks])
	{
		set_dhudmessage(255, MaxClients, MaxClients, 1056964608, 1063675494, MaxClients, 1086324736, 1036831949, MaxClients, MaxClients);
		show_dhudmessage(id, "%i", g_eMoves[iPlayer][mvInvalidTicks]);
	}
	return 0;
}

ResetHudInfo(id)
{
	arrayset(g_eHUD[id], MaxClients, NULL_VECTOR);
	static iTimeStamp;
	static szData[4];
	if (g_ePlayer[id][6])
	{
		if (!nvault_lookup(g_hHudInfoVault, g_ePlayer[id][e_steamid], szData, 3, iTimeStamp))
		{
			nvault_pset(g_hHudInfoVault, g_ePlayer[id][e_steamid], 973360);
		}
		g_eHUD[id][0] = str_to_num(szData);
	}
	return 0;
}

public cmdMenu(id)
{
	if (!g_ePlayer[id][6])
	{
		console_print(id, "You have no access to that command");
		return 1;
	}
	static szHeader[96];
	formatex(szHeader, 95, "%s\n", PLUGIN);
	format(szHeader, 95, "%s\dVersion: %s\n", szHeader, VERSION);
	format(szHeader, 95, "%sCompilation date: %s - %s", szHeader, "01/12/2019", "22:31:18");
	new hMenu = menu_create(szHeader, "cmdMenu_Handle", MaxClients);
	static szHudMode[16];
	if (g_eHUD[id][0])
	{
		if (!(g_eHUD[id][0] == 1))
		{
			if (!(g_eHUD[id][0] == 2))
			{
				if (g_eHUD[id][0] == 3)
				{
				}
			}
		}
	}
	static szHudInfo[32];
	formatex(szHudInfo, "", "HUD info: %s\n", szHudMode);
	menu_additem(hMenu, szHudInfo, 163488, MaxClients, -1);
	menu_additem(hMenu, "Get bhop stats", 163488, MaxClients, -1);
	menu_additem(hMenu, "Get gstrafe stats", 163488, MaxClients, -1);
	menu_additem(hMenu, "Get total bhop stats\n", 163488, MaxClients, -1);
	if (g_ePlayer[id][7])
	{
		menu_additem(hMenu, "Trigger fake ban", 163488, MaxClients, -1);
	}
	else
	{
		menu_addtext(hMenu, "\r5. \dTrigger fake ban", 1);
	}
	menu_display(id, hMenu, MaxClients, -1);
	return 1;
}

public cmdMenu_Handle(id, hMenu, iItem)
{
	switch (iItem)
	{
		case 0:
		{
			g_eHUD[id]++;
			if (3 < g_eHUD[id][0])
			{
				g_eHUD[id][0] = 0;
			}
			static str[4];
			num_to_str(g_eHUD[id][0], str, 3);
			nvault_pset(g_hHudInfoVault, g_ePlayer[id][e_steamid], str);
			cmdMenu(id);
		}
		case 1:
		{
			PlayerMenu(id, 975072);
		}
		case 2:
		{
			PlayerMenu(id, 975080);
		}
		case 3:
		{
			PlayerMenu(id, 975088);
		}
		case 4:
		{
			PlayerMenu(id, 975096);
		}
		default:
		{
		}
	}
	menu_destroy(hMenu);
	return 0;
}

PlayerMenu(id, szType[])
{
	static szHeader[64];
	switch (szType[0])
	{
		case 97:
		{
			formatex(szHeader, 63, "%s\n\dGet bhop stats", PLUGIN);
		}
		case 98:
		{
			formatex(szHeader, 63, "%s\n\dGet gstrafe stats", PLUGIN);
		}
		case 99:
		{
			formatex(szHeader, 63, "%s\n\dGet total bhop stats", PLUGIN);
		}
		case 100:
		{
			formatex(szHeader, 63, "%s\n\dReset client", PLUGIN);
		}
		case 101:
		{
			formatex(szHeader, 63, "%s\n\dTrigger fake ban", PLUGIN);
		}
		default:
		{
		}
	}
	new hMenu = menu_create(szHeader, "PlayerMenu_Handle", MaxClients);
	static iNumber;
	static iPlayers[32];
	get_players(iPlayers, iNumber, "ch");
	static szData[5];
	static iPlayer;
	new i;
	while (i < iNumber)
	{
		iPlayer = iPlayers[i];
		formatex(szData, 4, "%c %i", szType, iPlayer);
		static szEntryName[48];
		copy(szEntryName, 47, g_ePlayer[iPlayer][61]);
		if (iPlayer == id)
		{
			add(szEntryName, 47, " \r(you)");
		}
		else
		{
			if (is_user_admin(iPlayer))
			{
				add(szEntryName, 47, " \r*");
			}
		}
		menu_additem(hMenu, szEntryName, szData, MaxClients, -1);
		i++;
	}
	menu_display(id, hMenu, MaxClients, -1);
	return 0;
}

public PlayerMenu_Handle(id, hMenu, iItem)
{
	if (iItem == -3)
	{
		menu_destroy(hMenu);
		cmdMenu(id);
		return 0;
	}
	static callback;
	static data[5];
	static access;
	menu_item_getinfo(hMenu, iItem, access, data, NULL_STRING, {0}, MaxClients, callback);
	static szTarget[3];
	static szType[2];
	parse(data, szType, 1, szTarget, 2);
	new iTarget = str_to_num(szTarget);
	switch (szType[0])
	{
		case 97:
		{
			BhopStatsMenu(id, iTarget, 0);
		}
		case 98:
		{
			GstrafeStatsMenu(id, iTarget);
		}
		case 99:
		{
			BhopStatsMenu(id, iTarget, 1);
		}
		case 100:
		{
			ResetClient(id, iTarget);
		}
		case 101:
		{
			TriggerFakeBan(id, iTarget);
		}
		default:
		{
		}
	}
	return 0;
}

BhopStatsMenu(id, target, type)
{
	if (!is_user_connected(target))
	{
		client_print_color(id, -2, "\x03%s \x01Client is not connected", sz_plugin_custom_prefix);
		return 0;
	}
	static menu;
	static header[96];
	if (type)
	{
		copy(header, 95, "Bhop statistics (total)\n");
		format(header, 95, "%s\d%s (%s)", header, g_ePlayer[target][61], g_ePlayer[target][93]);
		menu = menu_create(header, "BhopStatsMenuTotal_Handle", MaxClients);
	}
	else
	{
		copy(header, 95, "Bhop statistics\n");
		format(header, 95, "%s\d%s (%s)", header, g_ePlayer[target][61], g_ePlayer[target][93]);
		menu = menu_create(header, "BhopStatsMenu_Handle", MaxClients);
	}
	static buffer[128];
	new var1;
	if (type == 1)
	{
		var1 = true;
	}
	else
	{
		var1 = false;
	}
	CalculateBhopStats(target, var1);
	num_to_str(target, buffer, 127);
	menu_additem(menu, "Refresh", buffer, MaxClients, -1);
	menu_addblank(menu, 1);
	formatex(buffer, 127, "\x09\x09\d Skill: %i", g_eBhopStats[target][type][BHOP_SKILL]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d Phase: %i", g_eBhopChecker[target][bhcPhase]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d Bhops: %i", g_eBhopStats[target][type][BHOPS]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d 0 FOG: %i|%i (%.2f%%)", g_eBhopStats[target][type][4], g_eBhopStats[target][type][13], g_eBhopStats[target][type][FOG0_P]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d 1 FOG: %i|%i (%.2f%%, %.2f%%)", g_eBhopStats[target][type][5], g_eBhopStats[target][type][14], g_eBhopStats[target][type][FOG1_P], g_eBhopStats[target][type][50]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d 2 FOG: %i|%i (%.2f%%, %.2f%%)", g_eBhopStats[target][type][6], g_eBhopStats[target][type][15], g_eBhopStats[target][type][FOG2_P], g_eBhopStats[target][type][51]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d 3 FOG: %i!%i (%.2f%%) { %i, %i, %i }", g_eBhopStats[target][type][BHOP_FOG3], g_eBhopStats[target][type][WHIO3FOG], g_eBhopStats[target][type][FOG3_P], g_eBhopStats[target][type][25], g_eBhopStats[target][type][26], g_eBhopStats[target][type][27]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d 4 FOG: %i (%.2f%%)", g_eBhopStats[target][type][BHOP_FOG4], g_eBhopStats[target][type][FOG4_P]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d 5 FOG: %i (%.2f%%)", g_eBhopStats[target][type][BHOP_FOG5], g_eBhopStats[target][type][FOG5_P]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d Ideal bhops: %i|%i!%i (%.2f%%)", g_eBhopStats[target][type][BHOP_IDEAL], g_eBhopStats[target][type][BHOP_IDEAL_IAR], g_eBhopStats[target][type][BHOP_NOT_IDEAL_IAR], g_eBhopStats[target][type][BHOP_IDEAL_P]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d Ideally distr. bhops: %i (%.2f%%)", g_eBhopStats[target][type][33], g_eBhopStats[target][type][58]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d Jump cmds: %.2f (%.2f) %.2f | %i", g_eBhopStats[target][type][55], g_eBhopStats[target][type][57], g_eBhopStats[target][type][56], g_eBhopStats[target][type][29]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d Too fast scrolled bhops: %i (%.2f%%)", g_eBhopStats[target][type][FAST_SCROLLED], g_eBhopStats[target][type][FAST_SCROLLED_P]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d Unique patterns: %i", g_eBhopStats[target][type][37]);
	menu_addtext(menu, buffer, MaxClients);
	menu_display(id, menu, MaxClients, -1);
	return 0;
}

GstrafeStatsMenu(id, target)
{
	if (!is_user_connected(target))
	{
		client_print_color(id, -2, "\x03%s \x01Client is not connected", sz_plugin_custom_prefix);
		return 0;
	}
	static header[96];
	format(header, 95, "Gstrafe statistics\n\d%s (%s)", g_ePlayer[target][61], g_ePlayer[target][93]);
	static buffer[128];
	new menu = menu_create(header, "GstrafeStatsMenu_Handle", MaxClients);
	num_to_str(target, buffer, 127);
	menu_additem(menu, "Refresh", buffer, MaxClients, -1);
	menu_addblank(menu, 1);
	formatex(buffer, 127, "\x09\x09\d Phase: %i", g_eGstrafe[target][17]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d Gstrafes: %i", g_eGstrafe[target][2]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d 1 FOG: %i|%i (%.2f%%)", g_eGstrafe[target][3], g_eGstrafeTotal[target][11], g_eGstrafe[target][18]);
	menu_addtext(menu, buffer, MaxClients);
	formatex(buffer, 127, "\x09\x09\d 2 FOG: %i|%i (%.2f%%)", g_eGstrafe[target][4], g_eGstrafeTotal[target][12], g_eGstrafe[target][19]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d 3 FOG: %i|%i (%.2f%%)", g_eGstrafe[target][5], g_eGstrafeTotal[target][13], g_eGstrafe[target][20]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d 4 FOG: %i (%.2f%%)", g_eGstrafe[target][6], g_eGstrafe[target][21]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d 5 FOG: %i (%.2f%%)", g_eGstrafe[target][7], g_eGstrafe[target][22]);
	menu_addtext(menu, buffer, 1);
	formatex(buffer, 127, "\x09\x09\d Duck cmds: %.2f | %i", g_eGstrafe[target][23], g_eGstrafe[target][16]);
	menu_addtext(menu, buffer, 1);
	menu_display(id, menu, MaxClients, -1);
	return 0;
}

public BhopStatsMenu_Handle(id, menu, item)
{
	static callback;
	static data[3];
	static access;
	menu_item_getinfo(menu, item, access, data, 2, {0}, MaxClients, callback);
	if (item)
	{
		PlayerMenu(id, 981652);
	}
	else
	{
		new target = str_to_num(data);
		if (is_user_connected(target))
		{
			BhopStatsMenu(id, target, 0);
		}
		else
		{
			client_print_color(id, -2, "\x03%s \x01Client is not connected", sz_plugin_custom_prefix);
		}
	}
	menu_destroy(menu);
	return 0;
}

public BhopStatsMenuTotal_Handle(id, menu, item)
{
	static callback;
	static data[3];
	static access;
	menu_item_getinfo(menu, item, access, data, 2, {0}, MaxClients, callback);
	if (item)
	{
		PlayerMenu(id, 981796);
	}
	else
	{
		new target = str_to_num(data);
		if (is_user_connected(target))
		{
			BhopStatsMenu(id, target, 1);
		}
		else
		{
			client_print_color(id, -2, "\x03%s \x01Client is not connected", sz_plugin_custom_prefix);
		}
	}
	menu_destroy(menu);
	return 0;
}

public GstrafeStatsMenu_Handle(id, menu, item)
{
	static callback;
	static data[3];
	static access;
	menu_item_getinfo(menu, item, access, data, 2, {0}, MaxClients, callback);
	if (item)
	{
		PlayerMenu(id, 981940);
	}
	else
	{
		new target = str_to_num(data);
		if (is_user_connected(target))
		{
			GstrafeStatsMenu(id, target);
		}
		else
		{
			client_print_color(id, -2, "\x03%s \x01Client is not connected", sz_plugin_custom_prefix);
		}
	}
	menu_destroy(menu);
	return 0;
}

ResetClient(id, iTarget)
{
	if (!is_user_connected(iTarget))
	{
		client_print_color(id, -2, "\x03%s \x01Client is not connected", sz_plugin_custom_prefix);
		return 0;
	}
	arrayset(g_bPunished[iTarget], MaxClients, 11);
	ResetClientCVars(iTarget);
	ResetCommands(iTarget);
	ResetProtector(iTarget);
	ResetBhop(iTarget, true, true);
	ResetGstrafe(iTarget, 1, 1);
	ResetJumpbug(iTarget);
	ResetMoves(iTarget, 1);
	ResetAngles(iTarget);
	ResetFPS(iTarget);
	ResetGstrafeNSD(iTarget);
	ResetGraphData(iTarget);
	client_print_color(id, -3, "\x04%s \x01Client \x03%s \x01(%s) has been reset", sz_plugin_custom_prefix, g_ePlayer[iTarget][61], g_ePlayer[iTarget][93]);
	return 0;
}

TriggerFakeBan(id, iTarget)
{
	PunishClient(iTarget, 0, "z", "Fake ban");
	client_print_color(id, -3, "\x04%s \x01Triggering fake ban on \x03%s \x01(%s)", sz_plugin_custom_prefix, g_ePlayer[iTarget][61], g_ePlayer[iTarget][93]);
	return 0;
}

public plugin_precache()
{
	precache_sound(PUNISH_SOUND);
	return 0;
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	get_localinfo("amxx_logs", g_szErrorLogsPath, 63);
	format(g_szErrorLogsPath, 63, "%s/client_analyzer_v%s", g_szErrorLogsPath, VERSION);
	if (is_linux_server())
	{
		replace_all(g_szErrorLogsPath, 63, 982540, 982548);
	}
	add(g_szErrorLogsPath, 63, ".log", MaxClients);
	if (!is_dedicated_server())
	{
		LogError(2, "ERROR: Server must be dedicated!");
	}
	if (!is_running("cstrike"))
	{
		LogError(2, "ERROR: Server must be running cstrike mod!");
	}
	get_localinfo("amxx_datadir", g_szDataDir, 63);
	API_Init();
	return 0;
}

InitCore()
{
	if (g_bInitialized)
	{
		return 0;
	}
	register_clcmd("ca_menu", "cmdMenu", g_eConfig[0], "Open main menu", -1, MaxClients);
	register_clcmd("say /demo_menu", "cmdDemoMenu", MaxClients, "Open demo menu", -1, MaxClients);
	register_concmd("ca_get_cvar", "cmdGetCVar", g_eConfig[0], "<name or #userid> <cvar>", -1, MaxClients);
	register_concmd("ca_send_cmd", "cmdSendCmd", g_eConfig[0], "<name or #userid> <cmd> [time_for_response=0.1] [method=2]", -1, MaxClients);
	register_concmd("ca_reload_config", "cmdReloadConfig", g_eConfig[1], 983908, -1, MaxClients);
	register_clcmd("MC_CS_RECEIVED", "cmdMC_CorrectSettingsReceived", -1, 984092, -1, MaxClients);
	register_clcmd("AC_CS_RECEIVED", "cmdAC_CorrectSettingsReceived", -1, 984092, -1, MaxClients);
	register_clcmd("BC_BLOCK", "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
	register_clcmd("BC_IN_ALT1", "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
	new i;
	while (i < 6)
	{
		register_clcmd(g_szDemoPlayerCmds[i], "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
		i++;
	}
	new i;
	while (i < 6)
	{
		register_clcmd(g_szCommandsOld[i], "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
		if (g_szCommandsOld[i][0] == 43)
		{
			static cmd[32];
			copy(cmd, 31, g_szCommandsOld[i]);
			cmd[0] = 45;
			register_clcmd(cmd, "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
		}
		i++;
	}
	new i;
	while (i < 32)
	{
		register_clcmd(g_szCommandsNew[i], "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
		if (g_szCommandsNew[i][0] == 43)
		{
			static cmd[32];
			copy(cmd, 31, g_szCommandsNew[i]);
			cmd[0] = 45;
			register_clcmd(cmd, "UnknownCommandWorkaround", -1, 984092, -1, MaxClients);
		}
		i++;
	}
	register_forward(125, "fwCmdStart", MaxClients);
	register_forward(126, "fwCmdEnd", MaxClients);
	register_event("30", "eventIntermission", 985476, 985484);
	RegisterHam(MaxClients, "player", "eventPlayerSpawnPost", 1, MaxClients);
	get_mapname(g_szMap, 63);
	formatex(g_szLogsDir, 63, "%s/client_analyzer_v%s", g_szDataDir, VERSION);
	if (is_linux_server())
	{
		replace_all(g_szLogsDir, 63, 985692, 985700);
	}
	new id = 1;
	while (id < 33)
	{
		g_eBhopStats[id][0][69] = TrieCreate();
		g_eBhopStats[id][1][69] = TrieCreate();
		id++;
	}
	if (!g_hHudInfoVault)
	{
		g_hHudInfoVault = nvault_open("client_analyzer_admin");
		if (g_hHudInfoVault == -1)
		{
			LogError(1, "ERROR: Couldn't open nVault file.");
		}
	}
	if (!g_hProxyVault)
	{
		g_hProxyVault = nvault_open("client_analyzer_proxy");
		if (g_hProxyVault == -1)
		{
			LogError(1, "ERROR: Couldn't open nVault file.");
		}
	}
	g_bInitialized = true;
	return 0;
}

InitOptional()
{
	new var1;
	if (!AddToFullPack && containi(sz_plugin_block_modules, "z") != -1)
	{
		AddToFullPack = register_forward(124, "fwAddToFullPack_Post", 1);
	}
	else
	{
		if (AddToFullPack)
		{
			unregister_forward(124, AddToFullPack, 1);
		}
	}
	new var2;
	if (!g_hVault && g_eConfig[230])
	{
		g_hVault = nvault_open("client_analyzer");
		if (g_hVault == -1)
		{
			LogError(1, "ERROR: Couldn't open nVault file.");
		}
	}
	return 0;
}

public server_frame()
{
	if (!g_bInitialized)
	{
		return 0;
	}
	new Float:flGameTime = get_gametime();
	if (flGameTime >= floatadd(1.0, g_eServer[2]))
	{
		new id;
		while (id < 33)
		{
			g_ePlayer[id][emulated_fps] = g_ePlayer[id][8];
			g_ePlayer[id][8] = 0;
			id++;
		}
		g_eServer[2] = flGameTime;
	}
	return 0;
}

public client_putinserver(id)
{
	arrayset(g_ePlayer[id], MaxClients, 130);
	new var1;
	g_ePlayer[id][0] = !is_user_bot(id) && !is_user_hltv(id);
	if (!g_ePlayer[id][0])
	{
		return 0;
	}
	new var2;
	if (plugin_just_admin_in_bytes & get_user_flags(id, MaxClients))
	{
		var2 = 1;
	}
	else
	{
		var2 = 0;
	}
	g_ePlayer[id][6] = var2;
	new var3;
	if (plugin_main_admin_in_bytes & get_user_flags(id, MaxClients))
	{
		var3 = 1;
	}
	else
	{
		var3 = 0;
	}
	g_ePlayer[id][7] = var3;
	get_user_authid(id, g_ePlayer[id][e_steamid], "%L");
	get_user_ip(id, g_ePlayer[id][114], 15, 1);
	g_bLookingForCmd[id] = 0;
	arrayset(g_szCmdName[id], MaxClients, 64);
	g_flNextCheckAllowedSince[id] = 0;
	g_iBuild[id] = 0;
	ResetDemoRecording(id);
	ResetClientCVars(id);
	ResetBhop(id, true, true);
	ResetGstrafe(id, 1, 1);
	ResetJumpbug(id);
	ResetMoves(id, 1);
	ResetAngles(id);
	ResetFPS(id);
	ResetGstrafeNSD(id);
	ResetCommands(id);
	ResetProtector(id);
	ResetHudInfo(id);
	ResetPunishment(id);
	ResetGraphData(id);
	if (SteamIdIsValid(id))
	{
		copy(g_eDemo[id][2], "%L", g_ePlayer[id][e_steamid]);
	}
	else
	{
		copy(g_eDemo[id][2], "%L", g_ePlayer[id][114]);
	}
	g_bTasksRegistered[id] = 0;
	if (g_bInitialized)
	{
		RegisterClientTasks(id);
	}
	return 0;
}

RegisterClientTasks(id)
{
	if (g_bTasksRegistered[id])
	{
		return 0;
	}
	if (g_eConfig[248])
	{
		set_task(float(id) / 5, "taskCheckProxy", id + taskid_check_proxy, 30724, MaxClients, "c", MaxClients);
	}
	set_task(1.0, "taskCheckBuild", id + taskid_check_build, 30724, MaxClients, "c", MaxClients);
	set_task(1.0, "taskForceCmdRate", id + taskid_force_cmdrate, 30724, MaxClients, 986636, MaxClients);
	new var1;
	
	if (plugin_recording_demo_use_nvault && !g_eConfig[231])
	{
		set_task(3.0, "RecordDemo", id + taskid_record_demo, 30724, MaxClients, "c", MaxClients);
	}
	set_task(30.0, "taskCheckDemoPlayer", id + taskid_check_demoplayer, 30724, MaxClients, "c", MaxClients);
	set_task(6.0, "taskCheckProtector", id + taskid_check_protector, 30724, MaxClients, "c", MaxClients);
	set_task(60.0, "taskCheckProtector", id + taskid_check_protector, 30724, MaxClients, 986920, MaxClients);
	g_bTasksRegistered[id] = 1;
	return 0;
}
set_task(30.0, function, id, const any:parameter[] = "", len = 0, const flags[] = "", repeat = 0)

public client_infochanged(id)
{
	if (g_ePlayer[id][0])
	{
		get_user_info(id, "name", g_ePlayer[id][61], "NO_ACC_COM");
	}
	return 0;
}

public client_command(id)
{
	if (!g_bInitialized)
	{
		return 0;
	}
	if (!g_ePlayer[id][0])
	{
		return 0;
	}
	static szCmd[64];
	read_argv(0, szCmd, 63);
	new var1;
	if (g_bLookingForCmd[id] && equali(szCmd, g_szCmdName[id], 0))
	{
		g_bLookingForCmd[id] = 0;
	}
	if (containi(sz_plugin_modules_working, "o") != -1)
	{
		CheckCommand(id, szCmd);
	}
	if (containi(sz_plugin_modules_working, "d") != -1)
	{
		CheckDemoPlayer(id, szCmd);
	}
	return 0;
}

public fwCmdStart(id, uc_handle)
{
	if (!g_ePlayer[id][0])
	{
		return 0;
	}
	if (g_eServer[0])
	{
		return 0;
	}
	g_ePlayer[id][e_PlayerFlags] = pev(id, 84);
	g_ePlayer[id][12] = pev(id, 69);
	if (g_ePlayer[id][e_PlayerFlags] & -2147479552)
	{
		return 0;
	}
	if (g_ePlayer[id][12] == 8)
	{
		return 0;
	}
	g_eServer[1] = get_gametime();
	if (is_user_alive(id))
	{
		g_ePlayer[id][8]++;
		g_ePlayer[id][9]++;
		g_ePlayer[id][ucButtons] = get_uc(uc_handle, UC_Buttons);
		g_ePlayer[id][oldButtons] = pev(id, pev_oldbuttons);
		g_ePlayer[id][e_msec] = get_uc(uc_handle, UC_Msec);
		pev(id, pev_maxspeed, g_ePlayer[id][MaxSpeed_current]);
		pev(id, pev_origin, g_ePlayer[id][e_origin]);
		pev(id, pev_angles, g_ePlayer[id][e_angles_current]);
		pev(id, pev_v_angle, g_ePlayer[id][e_v_angle]);
		get_uc(uc_handle, UC_ForwardMove, g_ePlayer[id][e_forwardmove]);
		get_uc(uc_handle, UC_LerpMsec, g_ePlayer[id][e_lerp_msec]);
		get_uc(uc_handle, UC_UpMove, g_ePlayer[id][e_upmove]);
		new var1;
		g_ePlayer[id][e_jumped] = g_ePlayer[id][ucButtons] & IN_JUMP && ~g_ePlayer[id][oldButtons] & IN_JUMP;
		new var2;
		g_ePlayer[id][e_ducked] = g_ePlayer[id][ucButtons] & IN_DUCK && ~g_ePlayer[id][oldButtons] & IN_DUCK;
		new var3;
		if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
		{
			new var21 = g_ePlayer[id][FOG_current];
			var21++;
			var3 = var21;
		}
		else
		{
			var3 = 0;
		}
		g_ePlayer[id][FOG_current] = var3;
		new var4;
		if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
		{
			var4 = 0;
		}
		else
		{
			new var22 = g_ePlayer[id][AirFrames_current];
			var22++;
			var4 = var22;
		}
		g_ePlayer[id][AirFrames_current] = var4;
		new var5;
		if (g_ePlayer[id][e_jumped])
		{
			var5 = 0;
		}
		else
		{
			new var23 = g_ePlayer[id][27];
			var23++;
			var5 = var23;
		}
		if (g_ePlayer[id][e_jumped])
			g_ePlayer[id][27] = 0
		else
			g_ePlayer[id][27]++
		
		if (g_ePlayer[id][ucButtons] & IN_JUMP)
			g_ePlayer[id][WithoutJumpCmdFrames_current] = 0;
		else
			g_ePlayer[id][WithoutJumpCmdFrames_current]++;
		
		new var7;
		if (g_ePlayer[id][e_ducked])
		{
			var7 = 0;
		}
		else
		{
			new var25 = g_ePlayer[id][28];
			var25++;
			var7 = var25;
		}
		g_ePlayer[id][28] = var7;
		if (g_ePlayer[id][WithoutJumpCmdFrames_current])
		{
			if (5 <= g_ePlayer[id][WithoutJumpCmdFrames_current])
			{
				g_ePlayer[id][30] = 0;
			}
		}
		else
		{
			g_ePlayer[id][30]++;
		}
		/* 
		new var8;
		if (g_ePlayer[id][e_PlayerFlags] & 16384)
		{
			var8 = 3;
		}
		else
		{
			var8 = 1;
		}
		 */
		g_ePlayer[id][e_player_IN_ALT1] = (g_ePlayer[id][e_PlayerFlags] & 16384) ? 3 : 1;
		if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND)
		{
			g_ePlayer[id][FOG_old] = g_ePlayer[id][FOG_current];
			if (g_ePlayer[id][e_jumped])
			{
				g_ePlayer[id][3] = 0;
			}
			if (g_ePlayer[id][e_ducked])
			{
				g_ePlayer[id][3] = 1;
			}
		}
		g_ePlayer[id][37] = floatsqroot(floatadd(floatmul(g_ePlayer[id][e_angles_current], g_ePlayer[id][e_angles_current]), floatmul(g_ePlayer[id][47], g_ePlayer[id][47])));
		g_ePlayer[id][41] = floatsub(g_ePlayer[id][56], g_ePlayer[id][59]);
		if (g_ePlayer[id][41] > 1127481344)
		{
			new var26 = g_ePlayer[id][41];
			var26 = floatsub(var26, 1135869952);
		}
		if (g_ePlayer[id][41] < -1020002304)
		{
			new var27 = g_ePlayer[id][41];
			var27 = floatadd(1135869952, var27);
		}
		g_ePlayer[id][42] = floatsub(g_ePlayer[id][e_v_angle], g_ePlayer[id][e_v_angle_old]);
		g_ePlayer[id][36] = floatsqroot(floatadd(floatadd(floatmul(g_ePlayer[id][e_forwardmove], g_ePlayer[id][e_forwardmove]), floatmul(g_ePlayer[id][e_lerp_msec], g_ePlayer[id][e_lerp_msec])), floatmul(g_ePlayer[id][e_upmove], g_ePlayer[id][e_upmove])));
		g_ePlayer[id][e_fps] = 0.001 * g_ePlayer[id][e_msec];
		new var9;
		if (g_ePlayer[id][e_fps] > 0)
		{
			var9 = floatround(floatdiv(1.0, g_ePlayer[id][e_fps]));
		}
		else
		{
			var9 = 0;
		}
		g_ePlayer[id][19] = var9;
		new var11;
		if (g_ePlayer[id][5] && (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND || g_ePlayer[id][12] == 5))
		{
			g_ePlayer[id][5] = 0;
		}
		new FOG = g_ePlayer[id][FOG_current];
		new Float:MaxPrestrafe = g_ePlayer[id][MaxSpeed_current] * 1.2;
		new Float:MaxPrestrafeIdeal = g_ePlayer[id][MaxSpeed_current] * 1.379999;
		new var14;
		g_eBhopChecker[id][bhcIdealCandidate] = (g_ePlayer[id][37] < MaxPrestrafe && (FOG == 1 || (FOG >= 2 && g_ePlayer[id][38] > MaxPrestrafe))) || (g_ePlayer[id][37] >= MaxPrestrafeIdeal && FOG == 1);
		if (FOG == 1)
		{
			g_eGstrafe[id][0] = g_ePlayer[id][e_PlayerFlags] & 16384;
		}
		new var18;
		g_eGstrafe[id][1] = FOG == 1 || (FOG == 2 && g_eGstrafe[id][0]);
		new var19;
		if (g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND && FOG <= 5)
		{
			new var20;
			if (g_ePlayer[id][e_ducked] && ~g_ePlayer[id][e_PlayerFlags] & 16384)
			{
				g_eBhopChecker[id][bhcIdealCandidate] = 0;
			}
			if (g_ePlayer[id][e_jumped])
			{
				g_eGstrafe[id][1] = 0;
			}
		}
		if (g_eConfig[249])
		{
			CollectGraphData(id);
		}
		if (containi(sz_plugin_modules_working, "b") != -1)
		{
			CheckBhop(id);
		}
		if (containi(sz_plugin_modules_working, "g") != -1)
		{
			CheckGstrafe(id);
		}
		if (containi(sz_plugin_modules_working, "m") != -1)
		{
			CheckMoves(id);
		}
		if (containi(sz_plugin_modules_working, "a") != -1)
		{
			CheckAngles(id);
		}
		if (containi(sz_plugin_modules_working, "f") != -1)
		{
			CheckFPS(id);
		}
		if (containi(sz_plugin_modules_working, "n") != -1)
		{
			CheckGstrafeNSD(id);
		}
		/*
		player_flags[id][1] = player_flags[id][0];
		g_ePlayer[id][14] = g_ePlayer[id][13];
		g_ePlayer[id][24] = g_ePlayer[id][23];
		g_ePlayer[id][26] = g_ePlayer[id][25];
		g_ePlayer[id][32] = g_ePlayer[id][31];
		*/
		g_ePlayer[id][ePlayerFlagsOld] = g_ePlayer[id][e_PlayerFlags];
		g_ePlayer[id][oldButtons] = g_ePlayer[id][ucButtons];
		g_ePlayer[id][AirFrames_old] = g_ePlayer[id][AirFrames_current];
		g_ePlayer[id][WithoutJumpCmdFrames_old] = g_ePlayer[id][WithoutJumpCmdFrames_current];
		g_ePlayer[id][MaxSpeed_old] = g_ePlayer[id][MaxSpeed_current];
		new i;
		while (i < 3)
		{
			g_ePlayer[id][49][i] = g_ePlayer[id][e_angles_current][i];
			g_ePlayer[id][e_v_angle_old][i] = g_ePlayer[id][e_v_angle][i];
			i++;
		}
	}
	else
	{
		g_ePlayer[id][9] = 0;
	}
	if (g_eHUD[id][0])
	{
		ShowHudInfo(id);
	}
	g_ePlayer[id][38] = g_ePlayer[id][37];
	return 0;
}

public fwCmdEnd(id, uc_handle)
{
	if (!g_ePlayer[id][0])
		return 0;
	if (g_eServer[0])
		return 0;
	if (pev(id, pev_flags) & 0)
		return 0;
	if (pev(id, pev_movetype) == 8)
		return 0;
	if (!is_user_alive(id))
		return 0;
	
	pev(id, pev_fuser2, g_ePlayer[id][e_fuser2]);
	pev(id, pev_colormap, g_ePlayer[id][e_colormap]);
	if (1151629635 == g_ePlayer[id][e_fuser2]
	&& g_ePlayer[id][ucButtons] & IN_JUMP
	&& ~g_ePlayer[id][e_PlayerFlags] & FL_ONGROUND
	&& g_ePlayer[id][48] < 0
	&& g_ePlayer[id][54] > 0)
	{
		g_ePlayer[id][4] = 1;
		g_ePlayer[id][5] = 1;
	}
	else
	{
		g_ePlayer[id][4] = 0;
	}
	if (containi(sz_plugin_modules_working, "j") != -1)
	{
		CheckJumpbug(id);
	}
	g_ePlayer[id][e_msec_old] = g_ePlayer[id][e_msec];
	g_ePlayer[id][e_playerFPS] = g_ePlayer[id][19];
	return 0;
}

public fwAddToFullPack_Post(es, e, ent, host, hostflags, player, pSet)
{
	set_es(es, 11, 0);
	return 0;
}

public eventPlayerSpawnPost(id)
{
	if (g_ePlayer[id][0] && is_user_alive(id) && plugin_recording_demo_use_nvault && plugin_recording_demo_status && !g_eDemo[id][1])
	{
		RecordDemo(id + taskid_record_demo);
	}
	return 0;
}

public client_disconnected(id)
{
	if (!g_ePlayer[id][0])
	{
		return 0;
	}
	new i = taskid_check_build;
	while (i <= taskid_maximal)
	{
		if (task_exists(i + id))
		{
			remove_task(i + id);
		}
		i += 32;
	}
	if (g_bWaitingBan[id])
	{
		BanDisconnectedClient(id);
	}
	return 0;
}

public eventIntermission()
{
	g_eServer[0] = 1;
	return 0;
}

public plugin_end()
{
	g_eServer[0] = 1;
	
	if (g_hVault && g_hVault != -1)
	{
		nvault_close(g_hVault);
	}
	
	if (g_hHudInfoVault && g_hHudInfoVault != -1)
	{
		nvault_close(g_hHudInfoVault);
	}
	
	if (g_hProxyVault && g_hProxyVault != -1)
	{
		nvault_close(g_hProxyVault);
	}
	
	curl_slist_free_all(g_hHeaders);
	return 0;
}
