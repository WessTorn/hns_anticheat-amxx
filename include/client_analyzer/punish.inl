stock PunishKickPlayer(id, szKick[165], szChat[165] = 0) {
	client_print_color(0, print_team_red, "%s ^3%n^1 was kicked. %s", g_szPrefix, id, szChat);

	server_cmd("kick #%i ^"%s^"", get_user_userid(id), szKick);
}

stock print_to_admins(message[], any: ...)
{
	static buffer[128];
	vformat(buffer, charsmax(buffer), message, 2);

	new players[MAX_PLAYERS], pnum;
	get_players(players, pnum, "ch");

	for (new i = 0; i < pnum; i++)
	{
		new const target = players[i];

		if (get_user_flags(target) & ADMIN_FLAG)
			client_print_color(target, print_team_blue, buffer);
    }
}