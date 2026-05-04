local hoptask = nil
local prioritytask = nil
local curpriority = 0

local STUCK_ANIMS = {
	suspended_pre = true, -- ickers
	suspended = true, -- ickers-- ickers
	suspended_spit = true, -- ickers
	yawn = true, -- sleeping
	dozy = true, -- sleeping
	sleep_loop = true, -- sleeping
	wakeup = true, -- sleeping
	frozen = true, -- getting frozen (duh)
	frozen_loop_pst = true, -- getting frozen
	jump = true, -- wormholes
	empty = true,  -- getting vored by raspy/big worm
	knockback_high = true, -- knockback (duh)
	mindcontrol_pre = true, -- fw's mind control
	mindcontrol_loop = true, -- fw's mind control
	mindcontrol_pst = true, -- fw's mind control
	distress_loop = true, -- ewecus' spit
}

local function NeedsMapHop(pl)
	if not TheMod.is_imp then return end
	local _, anim = pl.AnimState:GetHistoryData()
	return STUCK_ANIMS[anim] ~= nil
end

function Hop(pos, attempts, pause, priority)
	SetPause_FA(pause)
	--
	local pl = _G.ThePlayer
	if not (CanTeleport(pos) and priority >= curpriority) then return end

	if TheMod.maphop or NeedsMapHop(pl) then -- WORTOX EXCLUSIVE
		if pl._maphop_pause then -- gotta protect the player from losing souls by spamming map hops
			return
		else
			MapBlinkActionOrRPC(pos)
			SetPause_MapHop(pause)
			return true -- NO repeats for map hop, it will eat extra souls
		end
	end
	
	if TheInput:GetHUDEntityUnderMouse() then return end

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
	if cmp and cmp:UpdateCanTeleport() and Hop(cmp.markerpos, 5, 1, 2) then cmp:FlashMarker() end
end, true)

Bind("DODGE_KEY", function() -- WORTOX ESCLUSIVE
	if not InGame() then return end
	--
	local pl = _G.ThePlayer
	if TheMod.is_imp then Hop(pl:GetPosition(), 5, 1, 2) end
end)

