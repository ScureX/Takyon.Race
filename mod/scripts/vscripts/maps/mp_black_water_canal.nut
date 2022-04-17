global function Save_mp_black_water_canal_Init

global array<R_PropSave> mp_black_water_canal_props = []

void function Save_mp_black_water_canal_Init(){
mp_black_water_canal_props.clear()
AddProp($"models/fx/xo_shield_wall.mdl", < 123.695, 4715.03, -255.969 >, < 0, 24.7203, 0 >, "start")
AddProp($"models/fx/xo_shield_wall.mdl", < -796.157, 2729.02, -152.163 >, < 0, 89.1036, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 444.112, 355.502, -0.573551 >, < 0, 89.1325, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 1488.11, -1563.77, 49.3701 >, < 0, 180.348, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 2344.93, -3218.08, -187.415 >, < 0, 62.9354, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 1644.76, -4081.6, -199.969 >, < 0, 40.2252, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 956.926, -5039.39, -199.969 >, < 0, 134.192, 0 >, "cp")
AddProp($"models/fx/xo_shield_wall.mdl", < 1917.54, -5450.59, -193.412 >, < 0, 179.439, 0 >, "end")

}

void function AddProp(asset prop, vector location, vector angle, string flag){
R_PropSave temp
temp.prop = prop
temp.location =  location
temp.angle = angle
temp.flag = flag
mp_black_water_canal_props.append(temp)
}