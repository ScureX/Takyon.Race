global function Save_ColonyInit

global array<R_PropSave> props = []

void function Save_ColonyInit(){
props.clear()
AddProp($"models/fx/xo_shield_wall.mdl", <1583.98, -2000.99, 243.868>, <0, 177.746, 0>, "start")
AddProp($"models/fx/xo_shield_wall.mdl", <2113.9, -269.231, 167.109>, <0, 296.34, 0>, "cp")

}

void function AddProp(asset prop, vector location, vector angle, string flag){
R_PropSave temp
temp.prop = prop
temp.location =  location
temp.angle = angle
temp.flag = flag
props.append(temp)
}