local JAR_CONDITIONS = {
	full  = function(item) return item.prefab == "wortox_souljar" and       item.replica.inventoryitem.classified.percentused:value() or nil end,
	empty = function(item) return item.prefab == "wortox_souljar" and 100 - item.replica.inventoryitem.classified.percentused:value() or nil end,
	any   = function(item) return item.prefab == "wortox_souljar" and 100                                                             or nil end,
}

local function OpenJar() -- WORTOX EXCLUSIVE
	if not InGame() or not TheMod.is_imp then return end

	local jar_condition = JAR_CONDITIONS[TheModConfig.JAR_CONDITION]
	local jar = jar_condition and FindJar(jar_condition)
	if jar then _G.ThePlayer.replica.inventory:UseItemFromInvTile(jar) end
end
Bind("JAR_KEY", OpenJar)