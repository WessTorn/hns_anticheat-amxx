public menu_init() {
	register_clcmd("ac_menu", "cmdMenu", ADMIN_BAN);
}

public cmdMenu(id) {
	if (~get_user_flags(id) & ADMIN_BAN) {
		client_print(id, print_console, "You have no access to that command");
		return PLUGIN_HANDLED;
	}

	static szHeader[128]; 
	formatex(szHeader, charsmax(szHeader), "\yAnti-Cheat \d^nVersion: %s^nCompilation date: %s - %s", VERSION, __DATE__, __TIME__);
	new hMenu = menu_create(szHeader, "cmdMenu_handler");

	menu_additem(hMenu, "HUD info: \rdisabled^n", "1");

	menu_additem(hMenu, "Get bhop stats", "2");
	menu_additem(hMenu, "Get gstrafe stats", "3");
	menu_additem(hMenu, "Get total bhop stats", "4");
	menu_additem(hMenu, "Get total gstrafe stats^n", "5");

	menu_additem(hMenu, "Trigger fake ban", "6");

	menu_display(id, hMenu, 0);
	return PLUGIN_HANDLED;
}

public cmdMenu_handler(id, hMenu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(hMenu);
		return PLUGIN_HANDLED;
	}
	static s_Name[32], s_Data[6], i_Access, i_Callback;
	menu_item_getinfo(hMenu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);
	new i_Key = str_to_num(s_Data);
	switch (i_Key) {
		case 1: {
			cmdMenu(id);
		}
		case 2: {
			cmdMenu(id);
		}
		case 3: {
			cmdMenu(id);
		}
	}
	menu_destroy(hMenu);
	return PLUGIN_HANDLED;
}