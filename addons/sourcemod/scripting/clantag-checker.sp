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

//ConVar
ConVar g_cvTagName;

//String Values
char sectionName[100];
char nametag[32];

/* Int Values */
char g_cNameTag[32];



public void OnPluginStart()
{
	HookEvent("round_start", checkTag, EventHookMode_Pre);
	HookEvent("round_end", checkTag, EventHookMode_Pre);
	HookEvent("player_spawn", checkTag);
	HookEvent("player_death", checkTag);
	HookEvent("switch_team", checkTag);
	ParseKV();
	
	//ConVar List
	g_cvTagName = CreateConVar("sm_check_tag", "☾MoonGlow☽", "Tag to check for switching (def. ☾MoonGlow☽ )");
	g_cvTagName.AddChangeHook(OnCVarChanged);
}

public void OnCVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
	if (convar == g_cvTagName)
	{
		GetConVarString(g_cvTagName, g_cNameTag, sizeof(g_cNameTag));
	}
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
		CS_SetClientClanTag(client, g_cNameTag);
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
