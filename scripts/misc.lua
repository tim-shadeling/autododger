AddPrefabPostInit("wortox_soul_spawn", function(inst)
	if TheModConfig.REMOVE_SOUL_TAILS then inst._tails = {} end
end)