global function RaceInit
global function R_IsAdmin

global struct R_PropWithTrigger {
	entity prop
	array<entity> triggers
	string flag
}

global struct R_PlayerData {
	entity player
	array<R_PropWithTrigger> hitCheckpoints
}

bool r_raceRunning = false // prevent multiple instances
bool r_propsLoaded = false // spawnie thingy
global array<string> r_adminUids = [] // ppl who can exec commands

array<entity> r_loadedProps = []
global array<R_PropWithTrigger> r_loadedPropWithTriggers = []
array<R_PlayerData> r_livePlayers = []
array<entity> r_finishedPlayers = []
array<R_PropSave> props = []

void function RaceInit(){
	PrecacheModel($"models/fx/xo_shield_wall.mdl")
	PrecacheModel($"models/dev/editor_ref.mdl")

	UpdateAdminList()

	AddCallback_OnPlayerRespawned(R_OnPlayerSpawned)

	AddClientCommandCallback(".load", R_LoadRace_Callback)
	AddClientCommandCallback(".clear", R_ClearRace_Callback)
}

/*
 *	CALLBACKS
 */

bool function R_LoadRace_Callback(entity player, array<string> args){
	if(!R_IsAdmin(player))
		return false
	thread R_LoadRace(player)
	return true
}

bool function R_ClearRace_Callback(entity player, array<string> args){
	if(!R_IsAdmin(player))
		return false
	thread R_ClearRace()
	return true
}

void function R_OnPlayerSpawned(entity player){
	if(!r_raceRunning && !r_propsLoaded)
		return
	vector ang = props[0].angle  // shield is turned 180 degrees for some reason
	if(ang.y + 180 > 359.99)
		ang.y -= 180
	else
		ang.y += 180
	
	player.SetInvulnerable()
	player.SetOrigin(props[0].location) // start has to be first prop placed lol 
	player.SetAngles(ang)

	Chat_ServerPrivateMessage(player, "\x1b[34m[Race] \x1b[0mYou joined an ongoing race event! This will be over soon!", false)
}

/*
 *	GAME LOGIC
 */

void function R_LoadRace(entity initiator){
	if(r_raceRunning){
		print("There is already a race running!")
		return
	}

	switch(GetMapName()){
		case "mp_colony02":
			Save_mp_colony02_Init()
			props = mp_colony02_props
			break
		case "mp_black_water_canal":
			Save_mp_black_water_canal_Init()
			props = mp_black_water_canal_props
			break
		default:
			Chat_ServerPrivateMessage(initiator, "There is no race-track recorded for this map!", false)
			return
	}

	r_raceRunning = true

	wait 2
	print("[RACE] Starting race")
	Chat_ServerBroadcast("\x1b[34m[Race] \x1b[38;2;220;220;0mStarting race")

	foreach(entity player in GetPlayerArray()){
		R_PlayerData tmp
		tmp.player = player
		r_livePlayers.append(tmp)
	}

	// create props
	int index = 0
	foreach(R_PropSave prop in props){
		float radius = 100

		entity asd = CreatePropDynamic(prop.prop, prop.location, prop.angle)

		entity trig1 = CreateTriggerRadiusMultiple((asd.GetOrigin() + asd.GetForwardVector() * -200) + asd.GetRightVector() * 70, radius , [], TRIG_FLAG_PLAYERONLY)
		entity trig2 = CreateTriggerRadiusMultiple((asd.GetOrigin() + asd.GetForwardVector() * -200) + asd.GetRightVector() * -70, radius , [], TRIG_FLAG_PLAYERONLY)

		trig1.SetScriptName(index.tostring())
		trig2.SetScriptName(index.tostring())

		trig1.SetParent(asd)
		trig2.SetParent(asd)

		AddCallback_ScriptTriggerEnter(trig1, R_TriggerCallback)
		AddCallback_ScriptTriggerEnter(trig2, R_TriggerCallback)

		R_PropWithTrigger tmp
		tmp.prop= asd
		tmp.triggers = [trig1, trig2]
		tmp.flag = prop.flag

		r_loadedProps.append(asd)
		r_loadedPropWithTriggers.append(tmp)

		index++

		// DEBUG //
		//vector ang = prop.angle  // turn the prop that is created where the trigger is created
    	//ang.y -= 90
		entity dsa = CreatePropDynamic($"models/dev/editor_ref.mdl", asd.GetOrigin() + asd.GetForwardVector() * -200, prop.angle) // prop for origin of shield
		Highlight_SetNeutralHighlight(dsa, "enemy_boss_bounty")
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig1.GetOrigin(), prop.angle) // prop for center of trigger
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig1.GetOrigin() + <radius,0,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig1.GetOrigin() - <radius,0,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig1.GetOrigin() + <0,radius,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig1.GetOrigin() - <0,radius,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig2.GetOrigin(), prop.angle) // prop for center of trigger
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig2.GetOrigin() + <radius,0,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig2.GetOrigin() - <radius,0,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig2.GetOrigin() + <0,radius,0>, ang)
		//CreatePropDynamic($"models/dev/editor_ref.mdl", trig2.GetOrigin() - <0,radius,0>, ang)
		//print("[RACE] Created: " + prop.prop.tostring() + " " + prop.location.tostring() + " " + prop.angle.tostring() + " " )*/
	}
	r_propsLoaded = true
	// tp everyone to start and make invulnerable, freeze controls
	vector ang = props[0].angle  // shield is turned 180 degrees for some reason
	if(ang.y + 180 > 359.99)
		ang.y -= 180
	else
		ang.y += 180

	foreach(entity player in GetPlayerArray()){
		player.SetInvulnerable()
		player.SetVelocity(<0,0,0>)  
		player.SetOrigin(props[0].location) // start has to be first prop placed lol 
		player.SetAngles(ang)
		player.FreezeControlsOnServer()
	}

	// countdown
	for(int i = 5; i > 0; i--){
		Chat_ServerBroadcast("\x1b[34m[Race] \x1b[38;2;220;220;0mStarting in " + i)
		wait 1
	}

	thread R_StartRace()
}

float r_startTime = 0.0
float r_raceMaxTime = 60.0

void function R_StartRace(){
	Chat_ServerBroadcast("\x1b[34m[Race] \x1b[38;2;75;245;66mGO!")
	// TODO maybe sound
	r_startTime = Time()

	// unfreeze
	foreach(entity player in GetPlayerArray()){
		player.UnfreezeControlsOnServer()
	}

	thread R_RaceLoop()
}

void function R_RaceLoop(){
	r_raceMaxTime = GetConVarFloat("race_max_time")
	while(Time() - r_startTime < r_raceMaxTime-5 && r_finishedPlayers.len() <= 3 && r_finishedPlayers.len() < GetPlayerArray().len()){
		wait 0.5
	}

	for(int i = 5; i > 0; i--){
		Chat_ServerBroadcast("\x1b[34m[Race] \x1b[38;2;220;220;0mEnding race in " + i)
		wait 1
	}

	R_EndRace() // end race after timer got yeeted
}

void function R_EndRace(){
	Chat_ServerBroadcast("\x1b[34m[Race] Race is over!")
	Chat_ServerBroadcast("\x1b[34m[Race] \x1b[38;2;0;220;30mLeaderboard")
	for(int i = 0; i < r_finishedPlayers.len(); i++){
		switch(i){
			case 0:
				Chat_ServerBroadcast("\x1b[38;2;254;214;0m[" + (i+1) + "] " + r_finishedPlayers[0].GetPlayerName() )
				break
			case 1:
				Chat_ServerBroadcast("\x1b[38;2;210;210;210m[" + (i+1) + "] " + r_finishedPlayers[1].GetPlayerName())
				break
			case 2:
				Chat_ServerBroadcast("\x1b[38;2;204;126;49m[" + (i+1) + "] " + r_finishedPlayers[2].GetPlayerName())
				break
			default:
				Chat_ServerBroadcast("\x1b[0m[" + (i+1) + "] " + r_finishedPlayers[i].GetPlayerName())
				break
		}
	}

	Chat_ServerBroadcast("")
	// make players vulnerable again
	foreach(entity player in GetPlayerArray()){
		player.ClearInvulnerable()
	}

	R_ClearRace()
}

void function R_ClearRace(){
	print("[RACE] Clearing race")

	foreach(R_PropWithTrigger pwt in r_loadedPropWithTriggers){
		if(IsValid(pwt.prop)){
			foreach(entity trigger in pwt.triggers){
				if(IsValid(trigger)){
					ClearChildren(trigger)
					trigger.Destroy()
				}
			}
			ClearChildren(pwt.prop)
			pwt.prop.Destroy()
		}
	}

	r_loadedProps.clear()
	r_loadedPropWithTriggers.clear()
	r_livePlayers.clear()
	r_finishedPlayers.clear()
	props.clear()
	r_raceRunning = false
}

void function R_TriggerCallback(entity trigger, entity player){
	foreach(R_PlayerData pd in r_livePlayers){ // loop through all players
		if(pd.player == player){ // find player
			if(r_finishedPlayers.contains(player))
				return
			entity parentProp = trigger.GetParent()

			// append pwt to player's hit checkpoints
			foreach(R_PropWithTrigger pwt in r_loadedPropWithTriggers){
				if(pwt.prop == parentProp){ // find the right pwt to get both triggers

					// check if anythign else hit before start to sto index fuckery below
					if(pd.hitCheckpoints.len() <= 0 && pwt.flag != "start"){ 
						Chat_ServerPrivateMessage(player, "\x1b[34m[Race] \x1b[38;2;220;20;20mWrong Checkpoint : " + trigger.GetScriptName().tointeger(), false)
						return
					}
					
					// check if just hit start trigger
					if(pd.hitCheckpoints.len() <= 0 && pwt.flag == "start"){
						Chat_ServerPrivateMessage(player, "\x1b[34m[Race] \x1b[38;2;75;245;66mSTART CHECKPOINT TRIGGERED!", false)
						pd.hitCheckpoints.append(pwt) // add to cps player has passed
						return
					}

					// check if hit cp is before last hit cp or before 2nd to last hit
					if(
						pd.hitCheckpoints[pd.hitCheckpoints.len()-1].triggers[0].GetScriptName().tointeger() + 1 < trigger.GetScriptName().tointeger() // cp passed more than 1 num higher than last
					 || pd.hitCheckpoints[pd.hitCheckpoints.len()-1].triggers[0].GetScriptName().tointeger() > trigger.GetScriptName().tointeger()
					){ 
						Chat_ServerPrivateMessage(player, "\x1b[34m[Race] \x1b[38;2;220;20;20mWrong Checkpoint : " + trigger.GetScriptName().tointeger(), false)
						return
					} 

					// check if player jsut reached the end trigger
					if(pwt.flag == "end" || trigger.GetScriptName().tointeger() >= r_loadedPropWithTriggers.len()-1){ 
						pd.hitCheckpoints.append(pwt) // add to cps player has passed
						Chat_ServerPrivateMessage(player, "\x1b[34m[Race] \x1b[38;2;75;245;66mEND REACHED!", false)
						r_finishedPlayers.append(player)
					}

					// check if player hit cp 1 higher than before (correct cp)
					if(pd.hitCheckpoints[pd.hitCheckpoints.len()-1].triggers[0].GetScriptName().tointeger() + 1 == trigger.GetScriptName().tointeger()){
						pd.hitCheckpoints.append(pwt) // add to cps player has passed
						Chat_ServerPrivateMessage(player, "\x1b[34m[Race] \x1b[38;2;75;245;66mYou hit checkpoint " + pwt.triggers[0].GetScriptName(), false)
					}

					return
				}
			}
		}
	}
}

/*
 *	HELPER FUNCTIONSi
 */

bool function R_IsAdmin(entity player){
    if(!r_adminUids.contains(player.GetUID())){
		print("[Race] No rights")
		return false
	}
    return true
}

void function UpdateAdminList()
{
    string cvar = GetConVarString( "race_admin_uids" )

    array<string> dirtyUIDs = split( cvar, "," )
    foreach ( string uid in dirtyUIDs )
        r_adminUids.append(strip(uid))
}
