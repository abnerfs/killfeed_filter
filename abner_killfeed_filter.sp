#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.1"

Handle g_Enabled;


public Plugin myinfo =
{
	name 			= "AbNeR Kill Feed Filter",
	author 			= "AbNeR @CSB",
	description 	= "Shows only kills of the player in his feed.",
	version 		= PLUGIN_VERSION,
	url 			= "www.tecnohardclan.com/forum"
}

public void OnPluginStart()
{
	g_Enabled = CreateConVar("abner_killfeed_filter", "1", "Enable/Disable Plugin");
	CreateConVar("abner_killfeed_filter_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY|FCVAR_REPLICATED);
	AutoExecConfig(true, "abner_killfeed_filter");
	
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
}


public Action OnPlayerDeath(Event event, char [] name, bool dontBroadcast)
{
	if(GetConVarInt(g_Enabled) <= 0)
		return Plugin_Continue;
		
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));   
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));   
	
	if(victim == attacker)
		return Plugin_Continue;
	
	char weapon[50];
	event.GetString("weapon", weapon, sizeof(weapon));
			
	Event newEvent = CreateEvent("player_death");
	newEvent.SetInt("userid", event.GetInt("userid"));
	newEvent.SetInt("attacker", event.GetInt("attacker"));
	newEvent.SetString("weapon", weapon);
	newEvent.SetBool("headshot", event.GetBool("headshot"));
	
	if(IsValidClient(attacker) && !IsFakeClient(attacker))
		newEvent.FireToClient(attacker);
		
	if(IsValidClient(victim) && !IsFakeClient(victim))
		newEvent.FireToClient(victim);

	return Plugin_Handled;
}

bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}



