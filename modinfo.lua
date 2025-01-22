--[[ ver 0.4

All scripts, their line/char counts and expected md5 hashes:
    - modmain.lua - 63 lines/1946 chars - 3CF7CC11005FD42C34453CF5BCE42867
    - scripts
        - autododger_boss_data - 113/4223 - C280E45E4C44089F5BE67D68F0D65966
        - prefabs
            - remi_autododger_circle - 53/1395 - 15EADDB47CC20803BD0CEC86B70CA87D
            - remi_autododger_marker - 47/1208 - 5983C0C1E04BDE0706B59CAD052FDFEE
        - components
            - mod_autododger - 108/3322 - 3EEDBB23EEA63FB34C65E804FED18CD5
            - mod_autododger_marker - 223/7496 - 53644FB206770C65088D5C029DD7A59D

--]]

name = "Wortox Haxx Pack"
description = "Includes soul hop rebind, a dodge button and a tool to dodge *some* bosses automatically."
author = "Remi"
version = "0.4"

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

advertisement = "Tired of clicking through dozens of options? Get Convenient Configs!"

local KeybindOptions = {
    {description = "None", data = -1},
    {description = "F1", data = 282},
    {description = "F2", data = 283},
    {description = "F3", data = 284},
    {description = "F4", data = 285},
    {description = "F5", data = 286},
    {description = "F6", data = 287},
    {description = "F7", data = 288},
    {description = "F8", data = 289},
    {description = "F9", data = 290},
    {description = "F10", data = 291},
    {description = "F11", data = 292},
    {description = "F12", data = 293},
    {description = "Z", data = 122},
    {description = "X", data = 120},
    {description = "C", data = 99},
    {description = "V", data = 118},
    {description = "B", data = 98},
    {description = "N", data = 110},
    {description = "M", data = 109},
    {description = "A", data = 97},
    {description = "S", data = 115},
    {description = "D", data = 100},
    {description = "F", data = 102},
    {description = "G", data = 103},
    {description = "H", data = 104},
    {description = "J", data = 106},
    {description = "K", data = 107},
    {description = "L", data = 108},
    {description = "Q", data = 113},
    {description = "W", data = 119},
    {description = "E", data = 101},
    {description = "R", data = 114},
    {description = "T", data = 116},
    {description = "Y", data = 121},
    {description = "U", data = 117},
    {description = "I", data = 105},
    {description = "O", data = 111},
    {description = "P", data = 112},
    {description = "Num 1", data = 257},
    {description = "Num 2", data = 258},
    {description = "Num 3", data = 259},
    {description = "Num 4", data = 260},
    {description = "Num 5", data = 261},
    {description = "Num 6", data = 262},
    {description = "Num 7", data = 263},
    {description = "Num 8", data = 264},
    {description = "Num 9", data = 265},
    {description = "Num 0", data = 256},
    {description = "Num -", data = 269},
    {description = "Num +", data = 270},
    {description = "Num *", data = 268},
    {description = "Num /", data = 267},
    {description = "Num .", data = 266},
    {description = "Mouse Wheel", data = 1002},
    {description = "Mouse 4", data = 1005},
    {description = "Mouse 5", data = 1006},
    {description = "None", data = -1},
}

local headercounter = 0
local function MakeHeader(label)
    headercounter = headercounter + 1
    return {name = "header_"..headercounter, label = label, options = {{description = "", data = ""}}, default = ""} 
end

configuration_options =
{
    MakeHeader("Autododger"),
    {
        name = "KITE_KEY",
        label = "Autododger toggle key",
        options = KeybindOptions,
        default = 287,
        hover = "Press this near a boss to dodge its incoming attacks automatically.\n"..advertisement,
        is_keybind = true,
    },
    {
        name = "IGNORE_BONE_CAGE",
        label = "Bone cage handling",
        options = {
            {description = "Hop under boss", data = "to boss", hover = "You will take 10 damage from spikes, but avoid being trapped."},
            {description = "Hop in place", data = "in place", hover = "No damage, but you'll still need to escape the trap with another hop."},
            {description = "Ignore", data = true, hover = "In case you want to have more control of the fight."},
        },
        default = "to boss",
        hover = "Choose the preferred way of dealing with bone cage attacks.",
    },

    MakeHeader("Soul Hopping"),
    {
        name = "DODGE_KEY",
        label = "Dodge key",
        options = KeybindOptions,
        default = 120,
        hover = "Select a key that will perform a stationary soul hop.\n"..advertisement,
        is_keybind = true,
    },
    {
        name = "SOUL_HOP_REBIND",
        label = "Soul Hop rebind",
        options = KeybindOptions,
        default = 1002,
        hover = "Choose a new key for soul hopping.\n"..advertisement,
        is_keybind = true,
    },
    {
        name = "TARGETED_HOPS",
        label = "Targeted hops",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false},
        },
        default = false,
        hover = "If enabled, your soul hops will snap to the entity under mouse.\nOnly works if the config above is not set to 'None'.",
    },
    {
        name = "SHOW_MARKER",
        label = "Show marker",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
        hover = "Choose whether to show an indicator for soul hop destination.",
    },
    {
        name = "SNAP_TO_MAX_RANGE",
        label = "Snap to max range",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
        hover = "If enabled, the mod will keep your soul hop marker within maximum range (36 units)\nThis works best with the setting above enabled.",
    },
    {
        name = "SHOW_MAXRANGE",
        label = "Show max hop range",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
        hover = "If enabled, a red circle will indicate the maximum possible distance of soul hops.",
    },
    {
        name = "SHOW_TIMER",
        label = "Show echo timer",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
        hover = "If enabled, a timer will appear below your character to tell how much time is left before your Soul Echo expires.",
    },
    {
        name = "AUTOHOP",
        label = "Auto-echo",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
        hover = "Move your cursor outside the yellow circle and the mod will do soul echos for you.\nGood for exploration.",
    },

    MakeHeader("Other"),
    {
        name = "REMOVE_SOUL_TAILS",
        label = "Remove soul trails",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = false,
        hover = "If enabled, souls will no longer emit particles when they move.\nEnable this to amend performance issues caused by large amounts of souls.",
    },    
}