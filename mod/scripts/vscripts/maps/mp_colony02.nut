global function Save_mp_colony02_Init

global array<R_PropSave> mp_colony02_props = []

void function Save_mp_colony02_Init(){
mp_colony02_props.clear()
AddProp($"models/fx/xo_shield_wall.mdl", < 1577.46, -1960.09, 243.868 >, < 0, 187.085, 0 >, "start")
AddProp($"models/fx/xo_shield_wall.mdl", < 2116.49, -254.203, 166.589 >, < 0, 301.586, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 1715.79, 169.38, 110.013 >, < 0, 336.199, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 411.83, 319.054, 26.9141 >, < 0, 350.58, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < -394.864, 529.009, 21.7183 >, < 0, 7.56441, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < -780.512, 691.684, 47.6548 >, < 0, 278.597, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < -1070, 1247.29, 13.0812 >, < 0, 357.708, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < -1746.42, 859.935, 26.6465 >, < 0, 91.4595, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < -1727.85, -332.313, 80.1196 >, < 0, 139.589, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < -100.871, -1842.55, 198.705 >, < 0, 170.225, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 950.952, -1925.4, 250.311 >, < 0, 178.525, 0 >, "end")

}

void function AddProp(asset prop, vector location, vector angle, string flag){
R_PropSave temp
temp.prop = prop
temp.location =  location
temp.angle = angle
temp.flag = flag
mp_colony02_props.append(temp)
}