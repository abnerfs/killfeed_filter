#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.2"

Handle g_Enabled;
Handle g_Assister;
Handle g_Victim;


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
	
	g_Victim = CreateConVar("killfeed_filter_victim", "1", "Show Feed to Dead Player");
	g_Assister = CreateConVar("killfeed_filter_assister", "1", "Show Feed to Assister Player");
	
	
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
	int assister = GetClientOfUserId(GetEventInt(event, "assister"));
	
	if(victim == attacker)
		return Plugin_Continue;
	
	char weapon[50];
	event.GetString("weapon", weapon, sizeof(weapon));
			
	Event newEvent = CreateEvent("player_death");
	newEvent.SetInt("userid", event.GetInt("userid"));
	newEvent.SetInt("attacker", event.GetInt("attacker"));
	newEvent.SetInt("assister", event.GetInt("assister"));
	newEvent.SetString("weapon", weapon);
	newEvent.SetBool("headshot", event.GetBool("headshot"));
	
	if(IsValidClient(attacker) && !IsFakeClient(attacker))
		newEvent.FireToClient(attacker);
		
	if(GetConVarInt(g_Victim) != 0 && IsValidClient(victim) && !IsFakeClient(victim))
		newEvent.FireToClient(victim);
		
	if(GetConVarInt(g_Assister) != 0 && IsValidClient(assister) && !IsFakeClient(assister))
		newEvent.FireToClient(assister);

	return Plugin_Handled;
}

bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}
