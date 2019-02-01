#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#define PLUGIN_VERSION "1.5"

Handle g_Enabled;
Handle g_Assister;
Handle g_Victim;
Handle g_Cookie;

public Plugin myinfo =
{
	name 			= "AbNeR Kill Feed Filter",
	author 			= "abnerfs",
	description 	= "See only your own kills in kill feed.",
	version 		= PLUGIN_VERSION,
	url 			= "https://github.com/abnerfs/killfeed_filter"
}

public void OnPluginStart()
{
	g_Enabled = CreateConVar("abner_killfeed_filter", "1", "Enable/Disable Plugin");
	g_Victim = CreateConVar("abner_killfeed_filter_victim", "1", "Show Feed to Dead Player");
	g_Assister = CreateConVar("abner_killfeed_filter_assister", "1", "Show Feed to Assister Player");
	
	RegConsoleCmd("killfeed", MenuCookie);
	
	
	CreateConVar("abner_killfeed_filter_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY|FCVAR_REPLICATED);
	AutoExecConfig(true, "abner_killfeed_filter");
	
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	
	g_Cookie = RegClientCookie("Kill Feed Filter", "", CookieAccess_Private);
	SetCookieMenuItem(CookieHandler, 0, "Kill Feed Filter");
}

public void CookieHandler(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
	MenuCookie(client, 0);
} 

public Action MenuCookie(int client, int args)
{
	int  cookievalue = GetIntCookie(client, g_Cookie);
	Handle g_Menu = CreateMenu(MenuHandler);
	SetMenuTitle(g_Menu, "Kill Feed Filter by AbNeR_CSS");
	switch(cookievalue)
	{
		case 1:
		{
			AddMenuItem(g_Menu, "enable", "Enabled - [X]");
			AddMenuItem(g_Menu, "disable", "Disabled");
		}
		case 0:
		{
			AddMenuItem(g_Menu, "enable", "Enabled");
			AddMenuItem(g_Menu, "disable", "Disabled  - [X]");
		}
	}

	SetMenuExitBackButton(g_Menu, true);
	SetMenuExitButton(g_Menu, true);
	DisplayMenu(g_Menu, client, 30);
}

int GetIntCookie(int client, Handle handle)
{
	char sCookieValue[11];
	GetClientCookie(client, handle, sCookieValue, sizeof(sCookieValue));
	if(StrEqual(sCookieValue, ""))
		return 1; //Default value
		
	return StringToInt(sCookieValue);
}

public int MenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if(param2 == MenuCancel_ExitBack)
	{
		ShowCookieMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
				SetClientCookie(param1, g_Cookie, "1");
			
			case 1:
				SetClientCookie(param1, g_Cookie, "0");
		}
		MenuCookie(param1, 0);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}

public Action OnPlayerDeath(Event ev, char [] name, bool dontBroadcast)
{
	if(GetConVarInt(g_Enabled) <= 0)
		return Plugin_Continue;
		
	int victim = GetClientOfUserId(GetEventInt(ev, "userid"));   
	int attacker = GetClientOfUserId(GetEventInt(ev, "attacker"));
	int assister = GetClientOfUserId(GetEventInt(ev, "assister"));

	ev.BroadcastDisabled = true
		
	if(IsValidClient(attacker) && !IsFakeClient(attacker))
		ev.FireToClient(attacker);
		
	if(GetConVarInt(g_Victim) != 0 && attacker != victim && IsValidClient(victim) && !IsFakeClient(victim))
		ev.FireToClient(victim);
		
	if(GetConVarInt(g_Assister) != 0 && victim != assister &&  IsValidClient(assister) && !IsFakeClient(assister))
		ev.FireToClient(assister);
	
	for(int i = 1; i <= MaxClients;i++)
	{
		if(!IsValidClient(i) || IsFakeClient(i) || i == victim || i == attacker || i == assister)
			continue;
			
		int cookievalue = GetIntCookie(i, g_Cookie);
		if(cookievalue == 0)
			ev.FireToClient(i);
	}
		
	return Plugin_Continue;
}

bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}