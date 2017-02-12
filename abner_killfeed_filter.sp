#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.3"

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
	g_Victim = CreateConVar("abner_killfeed_filter_victim", "1", "Show Feed to Dead Player");
	g_Assister = CreateConVar("abner_killfeed_filter_assister", "1", "Show Feed to Assister Player");
	
	
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

	Event newEvent = CreateEvent("player_death");
	newEvent.SetInt("userid", event.GetInt("userid"));
	newEvent.SetInt("attacker", event.GetInt("attacker"));
	newEvent.SetInt("assister", event.GetInt("assister"));
	newEvent.SetBool("headshot", event.GetBool("headshot"));
	newEvent.SetInt("penetrated", event.GetInt("penetrated"));
	newEvent.SetInt("dominated", event.GetInt("dominated"));
	newEvent.SetInt("revenge", event.GetInt("revenge"));
	
	char buffer[250];
	
	event.GetString("weapon", buffer, sizeof(buffer));
	newEvent.SetString("weapon", buffer);
	
	event.GetString("weapon_itemid", buffer, sizeof(buffer));
	newEvent.SetString("weapon_itemid", buffer);
	
	event.GetString("weapon_fauxitemid", buffer, sizeof(buffer));
	newEvent.SetString("weapon_fauxitemid", buffer);
	
	event.GetString("weapon_originalowner_xuid", buffer, sizeof(buffer));
	newEvent.SetString("weapon_originalowner_xuid", buffer);
	
	if(IsValidClient(attacker) && !IsFakeClient(attacker))
		newEvent.FireToClient(attacker);
		
	if(GetConVarInt(g_Victim) != 0 && attacker != victim && IsValidClient(victim) && !IsFakeClient(victim))
		newEvent.FireToClient(victim);
		
	if(GetConVarInt(g_Assister) != 0 && victim != assister &&  IsValidClient(assister) && !IsFakeClient(assister))
		newEvent.FireToClient(assister);
	
	newEvent.Cancel();
	return Plugin_Handled;
}

bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}
