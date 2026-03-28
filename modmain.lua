PrefabFiles = {
	"remiimp_circle",
	"remiimp_marker",
}

_G = GLOBAL
next = _G.next
unpack = _G.unpack
require = _G.require
tonumber = _G.tonumber
tostring = _G.tostring
TheNet, RPC, ACTIONS = _G.TheNet, _G.RPC, _G.ACTIONS
TheInput = _G.TheInput

TheMod = {
	modname = modname,
	autododger = {},
	config = {},
	binds = {},
	-- Hop = function... -- in hop_binds_lua
}
TheModConfig = TheMod.config
_G.mod_remiimp = TheMod -- it's like remibsc but remiimp 

local H = require "remiimp_helperfns"
InGame = H.InGame -- yep it's not elegant but oh well
LoadConfig = H.LoadConfig
Bind = H.Bind
ClearBinds = H.ClearBinds
RefreshBinds = H.RefreshBinds
FindItem = H.FindItem
SetPause_FA = H.SetPause_FA
SetPause_MapHop = H.SetPause_MapHop
BlinkActionOrRPC = H.BlinkActionOrRPC
MapBlinkActionOrRPC = H.MapBlinkActionOrRPC
--
LoadConfig("KITE_KEY")
LoadConfig("bone_cage_handling")
LoadConfig("DODGE_KEY")
LoadConfig("SOUL_HOP_REBIND")
LoadConfig("TARGETED_HOPS")
LoadConfig("AUTOHOP")
LoadConfig("AUTOHOP_DIST_MULT")
LoadConfig("JAR_KEY")
LoadConfig("JAR_CONDITION")
LoadConfig("REMOVE_SOUL_TAILS")
LoadConfig("SHOW_MARKER")
LoadConfig("SHOW_TIMER")
LoadConfig("timer_font")
LoadConfig("timer_size")
LoadConfig("timer_color_1")
LoadConfig("timer_color_2")
LoadConfig("SHOW_MAXRANGE")
LoadConfig("SNAP_TO_MAX_RANGE")
LoadConfig("maxrange_color")
LoadConfig("autohop_color")
--
modimport "scripts/autododger"
modimport "scripts/hop_binds"
modimport "scripts/jar_binds"
modimport "scripts/misc"

-- Add components
AddPlayerPostInit(function(pl) pl:DoTaskInTime(0, function(pl)
	if pl ~= _G.ThePlayer or pl.prefab ~= "wortox" then return end

	pl:AddComponent("remiimp_marker")
	pl.components.remiimp_marker:Reconfigure(TheModConfig)

	pl:AddComponent("remiimp_autododger")
	pl.components.remiimp_autododger:Reconfigure(TheModConfig) -- there is nothing to reconfigure tho
end) end)

local function Reconfigure(settings)
	TheMod.config = settings
	TheModConfig = settings
	--
	settings.timer_size = math.abs(tonumber(settings.timer_size) or 25)
	--
	RefreshBinds()
	--
	local pl = _G.ThePlayer
	--
		-- manual changes
	--
	if pl then
		local cmp = pl.components.remiimp_marker
		if cmp then cmp:Reconfigure(settings) end
		cmp = pl.components.remiimp_autododger
		if cmp then cmp:Reconfigure(settings) end
	end 

	if _G.TheFocalPoint then _G.TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/learn_map") end
end

_G.AddUserCommand("impcfg", {
	prettyname = "Impish Magic Pack Config",
	desc = "Reconfigure the mod without having to reload the game!",
	permission = _G.COMMAND_PERMISSION.USER,
	slash = true,
	usermenu = false,
	servermenu = false,
	params = {},
	vote = false,
	localfn = function() -- params, caller
		local success, result = _G.pcall(function() return require "widgets/remi_newmodconfigurationscreen" end)
		if success then
			_G.TheFrontEnd:PushScreen(result(modname, true, Reconfigure))
		else
			_G.ChatHistory:SendCommandResponse("Error: "..tostring(result))
		end
	end,
})
--
AddGamePostInit(function()
	local mods = _G.rawget(_G, "REMI_RECONFIGURABLE_MODS")
	if mods then mods[modname] = Reconfigure end
end)