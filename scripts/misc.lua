AddPrefabPostInit("wortox_soul_spawn", function(inst)
	if TheModConfig.REMOVE_SOUL_TAILS then inst._tails = {} end
end)

local function UpdateTelepoofSound()
	TheSim:RemapSoundEvent("dontstarve/common/staff_blink", TheModConfig.QUIET_TELEPOOF and "wanda2/characters/wanda/watch/weapon/nightmare_FX" or "dontstarve/common/staff_blink") 
end
UpdateTelepoofSound()
TheMod.UpdateTelepoofSound = UpdateTelepoofSound
