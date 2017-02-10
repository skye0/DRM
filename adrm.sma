#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <engine>

#define PLUGIN  "DRM"
#define AUTHOR  "ROYAL"
#define VER     "0.0.1a"

enum _:PlayerData {
  bool:inTeam
}

new g_PlayerData[33][PlayerData];

new p_MinRunnersToStart;

public plugin_init() {

  register_plugin(PLUGIN, AUTHOR, VER);

  // Cvars
  p_MinRunnersToStart = register_cvar("dr_start_minrunners", "3");
  // Client commands
  register_clcmd("jointeam", "handleJoin");
  register_clcmd("joinclass", "handleJoin");
  register_clcmd("chooseteam", "handleMenu");
  // Messages
  register_message(get_user_msgid("ShowMenu"), "handleTeam");
  register_message(get_user_msgid("VGUIMenu"), "handleTeam");

  // Hamsandwich

}

public handleMenu(id) {
  log_amx("%i", g_PlayerData[id][inTeam])
  return PLUGIN_HANDLED;
}

public client_putinserver(id) {
  g_PlayerData[id][inTeam] = false;
}

public handleJoin(id) {
  if(bool:g_PlayerData[id][inTeam] == true) {
    return PLUGIN_HANDLED;
  }
  return PLUGIN_CONTINUE;
}

public handleTeam(MsgID, Dst, id) {
  set_task(0.1, "sendToTeam", id);
  log_amx("New task")
  return PLUGIN_HANDLED;
}

public sendToTeam(id) {
  log_amx("sendToTeam")
  new Players[32], CTNum, TNum;
  get_players(Players, CTNum, "ceh", "CT");
  get_players(Players, TNum, "ceh", "T");

  if(task_exists(id)) {
    remove_task(id);
  }

  if(is_user_connected(id)) {
    if(bool:g_PlayerData[id][inTeam] == false && cs_get_user_team(id) == CS_TEAM_UNASSIGNED) {
      if(CTNum == p_MinRunnersToStart && TNum == 0) {
        engclient_cmd(id, "jointeam 1");
        engclient_cmd(id, "joinclass 5");
      } else {
        engclient_cmd(id, "jointeam", 2);
        engclient_cmd(id, "joinclass", 5);
      }
      if(cs_get_user_team(id) == CS_TEAM_CT || cs_get_user_team(id) ==  CS_TEAM_T) {
        g_PlayerData[id][inTeam] = true;
      }
    }
  }

  return PLUGIN_HANDLED;
}

public fwHamPlayerSpawnPost(id) {
  if(is_user_connected(id) && is_user_alive(id)) {
    strip_user_weapons(id);
    set_pdata_int(id, 116, 0);
    give_item(id, "weapon_knife");
  }
}
