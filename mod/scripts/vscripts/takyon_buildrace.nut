untyped
global function BuildRaceInit

global struct R_PropSave{
    asset prop
    vector location
    vector angle
    string flag // start, cp
}

array<R_PropSave> propSaves = []

void function BuildRaceInit(){
    PrecacheModel($"models/fx/xo_shield_wall.mdl")
    AddClientCommandCallback(".start", PlaceStart)
    AddClientCommandCallback(".cp", PlaceCheckpoint)
    AddClientCommandCallback(".end", PlaceEnd) // if no end, use start as end
    AddClientCommandCallback(".save", R_Save)
}

bool function PlaceStart(entity player, array<string> args){
    if(!R_IsAdmin(player))
		return false
    vector ang = player.GetAngles()  // shield is turned 180 degrees for some reason
    ang.y += 180 

    R_PropSave start
    start.prop = $"models/fx/xo_shield_wall.mdl"
    start.location =  player.GetOrigin() 
    start.angle = ang
    start.flag = "start"
    propSaves.append(start)

    CreatePropDynamic($"models/fx/xo_shield_wall.mdl", player.GetOrigin(), ang)
    return true
}

bool function PlaceCheckpoint(entity player, array<string> args){
    if(!R_IsAdmin(player))
		return false
    vector ang = player.GetAngles()  // shield is turned 180 degrees for some reason
    ang.y += 180 

    R_PropSave cp
    cp.prop = $"models/fx/xo_shield_wall.mdl"
    cp.location =  player.GetOrigin() 
    cp.angle = ang
    cp.flag = "cp"
    propSaves.append(cp)

    CreatePropDynamic($"models/fx/xo_shield_wall.mdl", player.GetOrigin(), ang)
    return true
}

bool function PlaceEnd(entity player, array<string> args){
    if(!R_IsAdmin(player))
		return false
    vector ang = player.GetAngles()  // shield is turned 180 degrees for some reason
    ang.y += 180 

    R_PropSave end
    end.prop = $"models/fx/xo_shield_wall.mdl"
    end.location =  player.GetOrigin() 
    end.angle = ang
    end.flag = "end"
    propSaves.append(end)
    
    CreatePropDynamic($"models/fx/xo_shield_wall.mdl", player.GetOrigin(), ang)
    return true
}

bool function R_Save(entity player, array<string> args){
    if(!R_IsAdmin(player))
		return false
    string mapName = "ERROR"
    try{mapName = GetMapName()} catch(e){print("[Race] " + e)}

    string R_HEADER = "global function Save_" + mapName + "_Init\n\nglobal array<R_PropSave> " + mapName + "_props = []\n\nvoid function Save_" + mapName + "_Init(){\n" + mapName + "_props.clear()\n"
    string R_FOOTER = "\n}\n\nvoid function AddProp(asset prop, vector location, vector angle, string flag){\nR_PropSave temp\ntemp.prop = prop\ntemp.location =  location\ntemp.angle = angle\ntemp.flag = flag\n" + mapName + "_props.append(temp)\n}"
    string path = "../R2Northstar/mods/Takyon.Race/mod/scripts/vscripts/maps/" + mapName + ".nut"

    DevTextBufferClear()

    DevTextBufferWrite(R_HEADER)
    foreach(R_PropSave save in propSaves) {
        DevTextBufferWrite(format("AddProp(%s, %s, %s, \"%s\")\n", save.prop.tostring(), VectorFormatter(save.location), VectorFormatter(save.angle), save.flag))
    }
    DevTextBufferWrite(R_FOOTER)

    DevP4Checkout(path)
	DevTextBufferDumpToFile(path)
	DevP4Add(path)

    return true
}

string function VectorFormatter( vector vec ) {
    float x = vec.x
    float y = vec.y
    float z = vec.z

    return "< " + x + ", " + y + ", " + z + " >"
}