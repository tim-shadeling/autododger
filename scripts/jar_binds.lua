local JAR_CONDITIONS = {
	full  = function(item) return item.prefab == "wortox_souljar" and       item.replica.inventoryitem.classified.percentused:value() or -1 end,
	empty = function(item) return item.prefab == "wortox_souljar" and 100 - item.replica.inventoryitem.classified.percentused:value() or -1 end,
	any   = function(item) return item.prefab == "wortox_souljar" and 100                                                             or -1 end,
}

local function OpenJar()
	if not InGame() or _G.ThePlayer.prefab ~= "wortox" then return end

	local jar_condition = JAR_CONDITIONS[TheModConfig.JAR_CONDITION]
	local jar = jar_condition and FindItem(jar_condition)
	if jar then _G.ThePlayer.replica.inventory:UseItemFromInvTile(jar) end
end
Bind("JAR_KEY", OpenJar)