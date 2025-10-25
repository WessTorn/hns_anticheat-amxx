#define VERSION "1.0.4"

#include <hns_anticheat/index.inc>


public plugin_init() {
	register_plugin("Client Analyzer", "dev", "WessTorn");

	RegisterHookChain(RG_PwwM_Move, "rgPM_Move", false);
}

public rgPM_Move(id) {
	if (is_user_bot(id) || !is_user_alive(id) || is_user_hltv(id))
		return HC_CONTINUE;

	player_move(id);

	return HC_CONTINUE;
}

public client_disconnected(id) {
  clear_move(id);
}
