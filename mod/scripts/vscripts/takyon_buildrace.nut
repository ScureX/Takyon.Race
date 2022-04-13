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

const string R_HEADER = "global function Save_ColonyInit\n\nglobal array<R_PropSave> props = []\n\nvoid function Save_ColonyInit(){\nprops.clear()\n"
const string R_FOOTER = "\n}\n\nvoid function AddProp(asset prop, vector location, vector angle, string flag){\nR_PropSave temp\ntemp.prop = prop\ntemp.location =  location\ntemp.angle = angle\ntemp.flag = flag\nprops.append(temp)\n}"
const string path = "../R2Northstar/mods/Takyon.Race/mod/scripts/vscripts/maps/save_colony.nut"

bool function R_Save(entity player, array<string> args){
    DevTextBufferClear()

    DevTextBufferWrite(R_HEADER)
    foreach(R_PropSave save in propSaves) {
        DevTextBufferWrite(format("AddProp(%s, %s, %s, \"%s\")\n", save.prop.tostring(), save.location.tostring(), save.angle.tostring(), save.flag.tostring()))
    }
    DevTextBufferWrite(R_FOOTER)

    DevP4Checkout(path)
	DevTextBufferDumpToFile(path)
	DevP4Add(path)

    return true
}