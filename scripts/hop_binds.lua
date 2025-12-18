local hoptask = nil
local prioritytask = nil
local curpriority = 0

local anims_to_check = {
	"suspended_pre", "suspended", "suspended_spit", -- ickers
	"yawn", "dozy", "sleep_loop", "wakeup", -- sleep
	"frozen", "frozen_loop_pst", -- freeze
	"jump", -- wormholes
	"empty",  -- getting vored by rask/big worm
	"knockback_high", -- knockback (duh)
	"mindcontrol_pre", "mindcontrol_loop"," mindcontrol_pst", -- fw's mind control
--	"sink", "abyss_fall", -- falling, drowning doen't work
}
local function NeedsMapHop(pl)
	local anim = pl.AnimState
	for _,v in ipairs(anims_to_check) do
		if anim:IsCurrentAnimation(v) then return true end
	end
	return false
end

function Hop(pos, attempts, pause, priority)
	SetPause_FA(pause)
	--
	local pl = _G.ThePlayer
	if not (pl:CanSoulhop() and pl:CanBlinkTo(pos) and priority >= curpriority) then return end

	if TheMod.maphop or NeedsMapHop(pl) then 
		if pl._maphop_pause then -- gotta protect the player from losing souls by spamming map hops
			return
		else
			MapBlinkActionOrRPC(pos)
			SetPause_MapHop(pause)
			return true -- NO repeats for map hop, it will eat extra souls
		end
	end
	
	BlinkActionOrRPC(pos)
	if attempts > 0 then
		local counter = 0
		if hoptask then hoptask:Cancel() end
		hoptask = pl:DoPeriodicTask(0, function()
			BlinkActionOrRPC(pos)
			counter = counter + 1
			if counter > attempts then hoptask:Cancel(); hoptask = nil end
		end)

		curpriority = priority
		if prioritytask then prioritytask:Cancel() end
		prioritytask = pl:DoTaskInTime(1, function() curpriority = 0; prioritytask = nil end)
	end

	return true
end
TheMod.Hop = Hop -- for marker cmp

Bind("SOUL_HOP_REBIND", function() 
	if not InGame() then return end
	--
	local pl = _G.ThePlayer
	local cmp = pl.components.remiimp_marker
	if pl.prefab == "wortox" and cmp and Hop(cmp.markerpos, 5, 1, 2) then cmp:FlashMarker() end
end, true)

Bind("DODGE_KEY", function() 
	if not InGame() then return end
	--
	local pl = _G.ThePlayer
	if pl.prefab == "wortox" then Hop(pl:GetPosition(), 5, 1, 2) end
end)

