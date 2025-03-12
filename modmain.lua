local _G = GLOBAL
local TheNet, RPC, ACTIONS = _G.TheNet, _G.RPC, _G.ACTIONS
local TheInput, CONTROL_MOVE_RIGHT, CONTROL_MOVE_LEFT, CONTROL_MOVE_UP, CONTROL_MOVE_DOWN = _G.TheInput, _G.CONTROL_MOVE_RIGHT, _G.CONTROL_MOVE_LEFT, _G.CONTROL_MOVE_UP, _G.CONTROL_MOVE_DOWN
local BufferedAction = _G.BufferedAction
local CONTROL_PRIMARY = _G.CONTROL_PRIMARY

PrefabFiles = {
	"remi_autododger_circle",
	"remi_autododger_marker",
}
------------------------------- Configuration data -------------------------------
local config = {
	kite_key			= GetModConfigData("KITE_KEY"),
	dodge_key 			= GetModConfigData("DODGE_KEY"),
	soul_hop_rebind		= GetModConfigData("SOUL_HOP_REBIND"),
	targeted_hops		= GetModConfigData("TARGETED_HOPS"),
	bone_cage_dodge		= GetModConfigData("IGNORE_BONE_CAGE"),
	remove_soul_tails 	= GetModConfigData("REMOVE_SOUL_TAILS"),
	show_marker 		= GetModConfigData("SHOW_MARKER"),
	snap_to_max_range	= GetModConfigData("SNAP_TO_MAX_RANGE"),
	show_maxrange		= GetModConfigData("SHOW_MAXRANGE"),
	show_timer			= GetModConfigData("SHOW_TIMER"),
	autohop				= GetModConfigData("AUTOHOP"),
}
-------------------------------- Main variables -----------------------------------
hoptask = nil
prioritytask = nil
curpriority = 0
------------------------------- Binding function! --------------------------------
local function Bind(key, down, fn)
	if key > 0 and key < 1000 then
		if down then
			return TheInput:AddKeyDownHandler(key, fn)
		else
			return TheInput:AddKeyUpHandler(key, fn)
		end
	elseif key >= 1000 then
		return TheInput:AddMouseButtonHandler(function(button, is_down, x, y)
			if button ~= key or is_down ~= down then return end
			fn(button, is_down, x, y)
		end)
	end
end
config.bindfn = Bind
-------------------------------- Main functions! ---------------------------------
local function SetPause(time)
	local pl = _G.ThePlayer
	if pl._fa_pause then pl._fa_pause:Cancel() end
	pl._fa_pause = pl:DoTaskInTime(time, function(pl) pl._fa_pause = nil end) 
end

local function GetWalkingDirection()
    local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
    local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    local dir = _G.TheCamera:GetRightVec() * xdir - _G.TheCamera:GetDownVec() * ydir
    return dir:GetNormalized(), xdir ~= 0 or ydir ~= 0
end

function ActionOrRPC(pos)
	if _G.TheWorld.ismastersim then
		_G.ThePlayer.components.playercontroller:DoAction(BufferedAction(_G.ThePlayer, nil, ACTIONS.BLINK, nil, pos, nil, nil, true))
	else
		_G.ThePlayer.components.playercontroller:OnLeftUp()
		TheNet:SendRPCToServer(RPC.StopWalking)
		TheNet:SendRPCToServer(RPC.RightClick, ACTIONS.BLINK.code, pos.x,pos.z)
		_G.ThePlayer:DoTaskInTime(1, function(inst)
			if TheInput:IsControlPressed(CONTROL_PRIMARY) then
				inst.components.playercontroller:OnLeftClick(true)
			end 
		end)
		_G.ThePlayer:DoTaskInTime(1, function(inst) 
			local dir, walking = GetWalkingDirection()
			if not walking then return end
			TheNet:SendRPCToServer(RPC.DirectWalking, dir.x, dir.z)
		end)
	end
end

function Hop(pos, attempts, pause, priority)
	if not _G.ThePlayer:CanSoulhop() or not _G.ThePlayer.CanBlinkTo(pos) then return false end
	SetPause(pause)

	if priority >= curpriority then
		ActionOrRPC(pos)
		if attempts <= 0 then return true end
		
		local counter = 0
		if hoptask then hoptask:Cancel() end
		hoptask = _G.ThePlayer:DoPeriodicTask(0, function()
			ActionOrRPC(pos)
			counter = counter + 1
			if counter > attempts then hoptask:Cancel(); hoptask = nil end
		end)

		curpriority = priority
		if prioritytask then prioritytask:Cancel() end
		prioritytask = _G.ThePlayer:DoTaskInTime(1, function() curpriority = 0; prioritytask = nil end)
		
		return true
	end
	return false
end
config.hopfn = Hop
------------------------------- Post Inits! -------------------------------
function PostInit(player)
	if player ~= _G.ThePlayer or player.prefab ~= "wortox" then return end

	player:AddComponent("mod_autododger_marker")
	player.components.mod_autododger_marker:Init(config)

	player:AddComponent("mod_autododger")
	player.components.mod_autododger:Init(config)
end
AddPlayerPostInit(function(inst)
	inst:DoTaskInTime(0, PostInit)
end)

if config.remove_soul_tails then AddPrefabPostInit("wortox_soul_spawn", function(inst) inst._tails = {} end) end