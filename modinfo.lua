name = "Impish Magic Pack"
description = "A few assists and exploits to help you out."
author = "Remi"
version = "0.7.1"

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"


local KeybindOptions = { 
    {description = "None", data = -1}, {description = "F1", data = 282}, {description = "F2", data = 283}, 
    {description = "F3", data = 284}, {description = "F4", data = 285}, {description = "F5", data = 286}, {description = "F6", data = 287}, 
    {description = "F7", data = 288}, {description = "F8", data = 289}, {description = "F9", data = 290}, {description = "F10", data = 291}, 
    {description = "F11", data = 292}, {description = "F12", data = 293}, {description = "Z", data = 122}, {description = "X", data = 120}, 
    {description = "C", data = 99}, {description = "V", data = 118}, {description = "B", data = 98}, {description = "N", data = 110}, 
    {description = "M", data = 109}, {description = "A", data = 97}, {description = "S", data = 115}, {description = "D", data = 100}, 
    {description = "F", data = 102}, {description = "G", data = 103}, {description = "H", data = 104}, {description = "J", data = 106}, 
    {description = "K", data = 107}, {description = "L", data = 108}, {description = "Q", data = 113}, {description = "W", data = 119}, 
    {description = "E", data = 101}, {description = "R", data = 114}, {description = "T", data = 116}, {description = "Y", data = 121}, 
    {description = "U", data = 117}, {description = "I", data = 105}, {description = "O", data = 111}, {description = "P", data = 112}, 
    {description = "1", data = 49}, {description = "2", data = 50}, {description = "3", data = 51}, {description = "4", data = 52}, 
    {description = "5", data = 53}, {description = "6", data = 54}, {description = "7", data = 55}, {description = "8", data = 56}, 
    {description = "9", data = 57}, {description = "0", data = 48}, {description = "-", data = 45}, {description = "=", data = 61}, 
    {description = "Num 1", data = 257}, {description = "Num 2", data = 258}, {description = "Num 3", data = 259}, 
    {description = "Num 4", data = 260}, {description = "Num 5", data = 261}, {description = "Num 6", data = 262}, 
    {description = "Num 7", data = 263}, {description = "Num 8", data = 264}, {description = "Num 9", data = 265}, 
    {description = "Num 0", data = 256}, {description = "Num -", data = 269}, {description = "Num +", data = 270}, 
    {description = "Num *", data = 268}, {description = "Num /", data = 267}, {description = "Num .", data = 266}, 
    {description = '\238\132\130', data = 1002, "Middle Mouse Button"}, -- Middle Mouse Button 
    {description = '\238\132\131', data = 1005, "Mouse Button 4"}, -- Mouse Button 4 
    {description = '\238\132\132', data = 1006, "Mouse Button 5"}, -- Mouse Button 5 
    {description = "Caps Lock", data = 301}, {description = "None", data = -1},
}

local BoolOptions = {
    {description = "Yes", data = true},
    {description = "No", data = false},
}

local font_option_hover = "The quick brown fox jumps over the lazy dog."
local FontOptions = {
    {description = "Bellefair", data = "bellefair", hover = font_option_hover},
    {description = "Bellefair Outlined", data = "bellefair_outline", hover = font_option_hover},
    {description = "BP 50", data = "bp50", hover = font_option_hover},
    {description = "BP 100", data = "bp100", hover = font_option_hover},
    {description = "Button font", data = "buttonfont", hover = font_option_hover},
    {description = "Hammerhead", data = "hammerhead", hover = font_option_hover},
    {description = "Opensans", data = "opensans", hover = font_option_hover},
    {description = "PTMono", data = "ptmono", hover = font_option_hover},
    {description = "Spirequal", data = "spirequal", hover = font_option_hover},
    {description = "Spirequal Outlined", data = "spirequal_outline", hover = font_option_hover},
    {description = "Stint-UCR", data = "stint-ucr", hover = font_option_hover},
    {description = "Generic Talk", data = "talkingfont", hover = font_option_hover},
    {description = "Trade-In Talk", data = "talkingfont_tradein", hover = font_option_hover},
    {description = "Hermit Talk", data = "talkingfont_hermit", hover = font_option_hover},
    {description = "Wormwood Talk", data = "talkingfont_wormwood", hover = font_option_hover},
}

local function FakeOptions(default)
    return {{description = "Need mod!", data = default, hover = "You need Configs Extended to edit this one."}}
end

local header_counter = 0
local function Header(label, hover, section_start)
    header_counter = header_counter + 1
    return {name = "HEADER"..header_counter, label = label, hover = "", options = {{description = "", data = -1, hover = ""},}, default = -1, hover = hover, section_start = section_start}
end

local function ListOption(name, label, options, default, hover)
    return {name = name, label = label, options = options, default = default, hover = hover,}
end

local function Toggle(name, label, default, hover)
    return {name = name, label = label, options = BoolOptions, default = default, hover = hover}
end

local function Keybind(name, label, default, hover)
    return {
        name = name, label = label, options = KeybindOptions, default = default, hover = hover,
        is_keybind = true
    }
end

local function TextConfig(name, label, default, hover)
    return {
        name = name, label = label, options = FakeOptions(default), default = default, hover = hover,
        is_text_config = true
    }
end

local function ColorConfig(name, label, default, hover)
    return {
        name = name, label = label, options = FakeOptions(default), default = default, hover = hover,
        is_rgb_config = true
    }
end

local function MultipleChoices(name, label, choices, default, hover)
    return {
        name = name, label = label, options = FakeOptions(default), default = default, hover = hover,
        choices = choices
    }
end 

local function FontConfig(name, label, default, hover)
    return {
        name = name, label = label, options = FontOptions, default = default, hover = hover,
        is_font_config = true,
    }
end

local function SectionEnd(cfg)
    cfg.section_end = true
    return cfg
end

configuration_options =
{
    Header("Teleporting", "", true),
    Keybind("DODGE_KEY", "Dodge key", 120, "Select a key that will perform a stationary soul hop."),
    Keybind("SOUL_HOP_REBIND", "Soul Hop/Telepoof rebind", 1002, "Choose a new key for soul hopping or telepoofing instead of RMB."),
    Keybind("TELEPOOF_TOGGLE_KEY", "Telepoof toggle key", 1002, "Choose a key that will toggle telepoofing on and off.\nPress it while hovering the cursor over a Lazy Explorer in the hand slot."),
    Toggle("TARGETED_HOPS", "Targeted hops", false, "If enabled, your soul hops will snap to the entity under mouse.\nOnly works if the config above is not set to 'None'."),
    Toggle("AUTOHOP", "Auto-echo", true, "Move your cursor outside the lesser circle and the mod will do soul echoes for you.\nGood for exploration."),
    ListOption("AUTOHOP_DIST_MULT", "Auto-echo distance", {
            {description = "34.2 (95%)", data = .95},
            {description = "32.4 (90%)", data = .90},
            {description = "30.6 (85%)", data = .85},
            {description = "28.8 (80%)", data = .80},
            {description = "27.0 (75%)", data = .75},
            {description = "25.2 (70%)", data = .70},
            {description = "23.4 (65%)", data = .65},
            {description = "21.6 (60%)", data = .60},
            {description = "19.8 (55%)", data = .55},
            {description = "18.0 (50%)", data = .50},
    }, .90, "Select the minimal distance for auto-echoes. The percentage is based on maximum hop distance (36 units)."),

    Header("Jar accessing", "", true),
    Keybind("JAR_KEY", "Open jar key", -1, "Select a key that will open a soul jar from your inventory."),
    ListOption("JAR_CONDITION", "Jar priority", {
            {description = "Pick leftmost", data = "any"},
            {description = "Pick fullest",  data = "full"},
            {description = "Pick emptiest", data = "empty"},
    }, "any", "Select how the mod should choose the jar when using the open jar hotkey."),

    Header("Misc", "", true),
    Toggle("QUIET_TELEPOOF", "Quiet telepoof", false, "Enable this if you are tired of the jarring default telepoof sound."),
    Toggle("REMOVE_SOUL_TAILS", "Remove soul trails", false, "Did you know that every soul trail particle is a separate entity?"),

    Header("Customization", "", true),
    Toggle("SHOW_MARKER", "Show marker", true, "Choose whether to show an indicator for soul hop destination."),
    Toggle("SHOW_TIMER", "Show echo timer", true, "If enabled, a timer will appear below your character to tell how much time is left before your Soul Echo expires."),
    FontConfig("timer_font", "Timer font", "stint-ucr", "Select the font for the soul echo timer."),
    TextConfig("timer_size", "Timer text size", "25", "Must be a number above zero. Increase the value to make the text larger. Default is 25."),
    ColorConfig("timer_color_1", "Timer text color 1", {1,0,0,1}, "The timer will gradually fade from color 1 to color 2."),
    ColorConfig("timer_color_2", "Timer text color 2", {1,1,1,1}, "The timer will gradually fade from color 1 to color 2."),
    Toggle("SHOW_MAXRANGE", "Show max hop range", true, "If enabled, a red circle will indicate the maximum possible distance of soul hops."),
    Toggle("SNAP_TO_MAX_RANGE", "Snap to max range", true, "If enabled, the mod will keep your soul hop marker within maximum range (36 units)\nThis works best with the above setting enabled."),
    ColorConfig("maxrange_color", "Max hop range disp. color", {1,.2,.2,1}, "Pick the color for the maximum hop range display."),
    ColorConfig("autohop_color", "Autohop range disp. color", {1,1,.2,1}, "Pick the color for the autohop range display."),
}