local HELPERFNS = {} -- tis a required file instead of a modimported one cus i want to access it from components potentially
------------------------------------------------ Base Fns ------------------------------------------------
function HELPERFNS.InGame()
	return ThePlayer and ThePlayer.HUD and not ThePlayer.HUD:HasInputFocus()
end

function HELPERFNS.LoadConfig(name)
	mod_remiimp.config[name] = GetModConfigData(name, mod_remiimp.modname)
	assert(mod_remiimp.config[name] ~= nil, "Unknown config: "..name)
	return mod_remiimp.config[name]
end

function HELPERFNS.Bind(config, fn, _down)
	local key = mod_remiimp.config[config]
	local handler
	if key < 1000 then
		handler = _down and TheInput:AddKeyDownHandler(key, fn) or TheInput:AddKeyUpHandler(key, fn)
	else
		handler = TheInput:AddMouseButtonHandler(function(button, down, x, y)
			if button == key and down == _down then fn() end
		end)
	end
	handler.actualfn = fn
	handler._down = _down
	mod_remiimp.binds[config] = handler
end

function HELPERFNS.RefreshBinds()
	for config, bind in pairs(mod_remiimp.binds) do
		bind:Remove()
		HELPERFNS.Bind(config, bind.actualfn, bind._down)
	end
end

function HELPERFNS.CanTeleport(pos)
	local x, y, z = pos:Get()
	if (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not ThePlayer:HasTag("steeringboat") and not ThePlayer:HasTag("rotatingboat") then
		local px, py, pz = ThePlayer.Transform:GetWorldPosition()
		return IsTeleportingPermittedFromPointToPoint(x, y, z, px, py, pz)
	end
end
------------------------------------------------ Item Search ------------------------------------------------
local MAX_PRIORITY = 100
function HELPERFNS.FindItem(condition) -- inventory only cus jars (and souls) can't go in containers
	local best_prio = -1
	local best_item

	local inv = ThePlayer.HUD.controls.inv
	if inv then
		for index,slot in pairs(inv.current_list) do
			if slot.tile then
				local item = slot.tile.item
				local prio = condition(item)
				if prio > best_prio then
					best_prio = prio
					best_item = item
					if prio == MAX_PRIORITY then return item end
				end
			end
		end
	end

	return best_item
end

------------------------------------------------ RPC or action ------------------------------------------------
function HELPERFNS.BlinkActionOrRPC(pos)
	if TheWorld.ismastersim then
		ThePlayer.components.playercontroller:DoAction(BufferedAction(ThePlayer, nil, ACTIONS.BLINK, nil, pos, nil, nil, true))
	else
		TheNet:SendRPCToServer(RPC.RightClick, ACTIONS.BLINK.code, pos.x,pos.z)
		if TheInput:IsControlPressed(CONTROL_PRIMARY) then 
			ThePlayer.components.playercontroller:OnLeftUp()
			TheNet:SendRPCToServer(RPC.StopWalking) 
		end
		ThePlayer:DoTaskInTime(1, function(inst)
			if TheInput:IsControlPressed(CONTROL_PRIMARY) then
				inst.components.playercontroller:OnLeftClick(true)
			end 
		end)
	end
end

function HELPERFNS.MapBlinkActionOrRPC(pos)
	if TheWorld.ismastersim then
		ThePlayer.components.playercontroller:DoAction(BufferedAction(ThePlayer, nil, ACTIONS.BLINK_MAP, nil, pos, nil, nil, true))
	else
		TheNet:SendRPCToServer(RPC.DoActionOnMap, ACTIONS.BLINK_MAP.code, pos.x,pos.z)
		if TheInput:IsControlPressed(CONTROL_PRIMARY) then 
			ThePlayer.components.playercontroller:OnLeftUp()
			TheNet:SendRPCToServer(RPC.StopWalking) 
		end
		ThePlayer:DoTaskInTime(1, function(inst)
			if TheInput:IsControlPressed(CONTROL_PRIMARY) then
				inst.components.playercontroller:OnLeftClick(true)
			end 
		end)
	end
end

----------------------------------------------------- Misc -----------------------------------------------------
function HELPERFNS.SetPause_FA(time)
	local pl = ThePlayer
	if pl._fa_pause then pl._fa_pause:Cancel() end
	pl._fa_pause = pl:DoTaskInTime(time, function(pl) pl._fa_pause = nil end) 
end

function HELPERFNS.SetPause_MapHop(time)
	local pl = ThePlayer
	if pl._maphop_pause then pl._maphop_pause:Cancel() end
	pl._maphop_pause = pl:DoTaskInTime(time, function(pl) pl._maphop_pause = nil end) 
end

return HELPERFNS