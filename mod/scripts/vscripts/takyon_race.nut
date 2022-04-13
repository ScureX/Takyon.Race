global function RaceInit

array<entity> r_loadedProps = []

void function RaceInit(){
	PrecacheModel($"models/fx/xo_shield_wall.mdl")

	AddClientCommandCallback(".load", R_LoadRace_Callback)
	AddClientCommandCallback(".clear", R_ClearRace_Callback)
}

bool function R_LoadRace_Callback(entity player, array<string> args){
	thread R_LoadRace()
	return true
}

bool function R_ClearRace_Callback(entity player, array<string> args){
	thread R_ClearRace()
	return true
}

void function R_LoadRace(){
	wait 2
	print("[RACE] Starting race")
	Chat_ServerBroadcast("[RACE] Starting race")
	Save_ColonyInit()

	// create props
	foreach(R_PropSave prop in props){
		r_loadedProps.append(CreatePropDynamic(prop.prop, prop.location, prop.angle))
		print("[RACE] Created: " + prop.prop.tostring() + " " + prop.location.tostring() + " " + prop.angle.tostring() + " " )
	}

	// tp everyone to start and make invulnerable, freeze controls
	vector ang = props[0].angle  // shield is turned 180 degrees for some reason
    ang.y += 180 
	foreach(entity player in GetPlayerArray()){
		player.SetInvulnerable()
		player.SetOrigin(props[0].location) // start has to be first prop placed lol 
		player.SetAngles(ang)
		player.FreezeControlsOnServer()
	}

	// countdown
	for(int i = 5; i > 0; i--){
		else Chat_ServerBroadcast("[RACE] Starting in " + i)
		wait 1
	}

	// unfreeze
	Chat_ServerBroadcast("[RACE] GO!")
	foreach(entity player in GetPlayerArray()){
		player.UnfreezeControlsOnServer()
	}

}

void function R_ClearRace(){
	wait 2
	print("[RACE] Clearing race")
	//Chat_ServerBroadcast("[RACE] Ending race")

	foreach(entity prop in r_loadedProps){
		if(IsValid(prop)){
			ClearChildren(prop)
			prop.Destroy()
		}
	}

	// make players vulnerable again
	foreach(entity player in GetPlayerArray()){
		player.ClearInvulnerable()
	}
}