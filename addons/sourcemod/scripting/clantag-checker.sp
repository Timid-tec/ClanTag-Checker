#include <cstrike>
#include <timid>

public Plugin myinfo = 
{
	name = "Clan-tag checker", 
	author = PLUGIN_AUTHOR, 
	description = "Checks for clantag", 
	version = PLUGIN_VERSION, 
	url = ""
};


//String Values
char sectionName[100];
char nametag[32];

public void OnPluginStart()
{
	HookEvent("round_start", checkTag, EventHookMode_Pre);
	HookEvent("round_end", checkTag, EventHookMode_Pre);
	HookEvent("player_spawn", checkTag);
	HookEvent("player_death", checkTag);
	HookEvent("switch_team", checkTag);
	ParseKV();
}

public Action checkTag(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client))
		return;
	char sTag[256];
	CS_GetClientClanTag(client, sTag, 256);
	if (StrContains(sTag, nametag, true) != -1)
	{
		CS_SetClientClanTag(client, "☾MoonGlow☽");
		PrintToChat(client, "Switching %s to ☾MoonGlow☽", nametag);
	}
}

void ParseKV()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/clantag.cfg");
	
	if (!FileExists(path))
	{
		SetFailState("Configuration file %s is not found", path);
		return;
	}
	
	KeyValues kv = new KeyValues("steamgroup");
	
	if (!kv.ImportFromFile(path))
	{
		SetFailState("Unable to parse Key Values files %s", path);
		return;
	}
	
	if (!kv.JumpToKey("clantag"))
	{
		SetFailState("Unable to find clantags section in file %s", path);
		return;
	}
	
	if (!kv.GotoFirstSubKey())
	{
		SetFailState("Unable to find clantags section in file %s", path);
		return;
	}
	
	do {
		kv.GetSectionName(sectionName, sizeof(sectionName));
		kv.GetString("name", nametag, sizeof(nametag));
		
	} while (kv.GotoNextKey());
	delete kv;
	return;
}
