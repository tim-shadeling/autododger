local function GetPointBetweenAtCertainDistance(p1, p2, dist)
	local scale = dist/p1:Dist(p2)
	return p1 + (p2 - p1)*scale
end

local function in_place(player, boss)
	return player:GetPosition()
end

local function to_boss(player, boss)
	return boss:GetPosition()
end

local function mirror_ctor(dist)
	return function(player, boss)
		player, boss = player:GetPosition(), boss:GetPosition()
		return GetPointBetweenAtCertainDistance(boss, boss + (boss - player), dist)
	end
end

local function backaway_ctor(dist)
	return function(player, boss)
		player, boss = player:GetPosition(), boss:GetPosition()
		return GetPointBetweenAtCertainDistance(boss, boss + (player - boss), dist)
	end
end

local function Anim(name, frame, destinationfn)
	return {
		name = name, -- name of anim
		destinationfn = destinationfn, -- whether you need to tp to the boss' position or yours (used to dodge shockwaves)
		frame = frame, -- the frame you need to tp at
	}
end

local function Params(range, ...) -- ... is list of anims
	return {
		range = range, -- how close you have to be
		anims = {...}, -- list of attack animations that would be desirable to dodge with souls/watch
	}
end

local function CreateBossDataTable()
	local bone_cage_dodge = GetModConfigData("IGNORE_BONE_CAGE", KnownModIndex:GetModActualName("Wortox Haxx Pack"))
	local dodge_cage = type(bone_cage_dodge) == "string"

	return {
		-- Works great for both wortox and wandus
		dragonfly		 = Params(6,	Anim("atk",					 0, in_place)),
		-- Keep your warp marker outside of incoming attack's hitbox!
		deerclops		 = Params(4,	Anim("atk",					13,	in_place),
										Anim("atk2",				 0, in_place)),
		-- Works just fine
		leif			 = Params(4.5,	Anim("atk",					 2, in_place)),
		-- Works just fine
		leif_sparse		 = Params(4.5,	Anim("atk",					 2, in_place)),
		-- Works just fine
		moose			 = Params(6,	Anim("atk",					 0, in_place)),
		-- Works just fine
		bearger			 = Params(7.6,	Anim("atk",					10, in_place),	
										Anim("ground_pound",		 6,	to_boss)),
		-- Works just fine
		shadow_rook		 = Params(5,	Anim("teleport_atk",		 0, in_place)),
		-- Not supported until I find a way to detect lunges
	--	daywalker		 = Params(7,	Anim("atk_slam",			 0, in_place)),
		-- WANDA NOT SUPPORTED!
		mutatedbearger	 = Params(5.2,	Anim("atk1",				10,	to_boss),	
										Anim("ground_pound",		 6,	to_boss),
										Anim("butt_pre_L",			20, in_place),
										Anim("butt_pre_R",			20, in_place)),
		-- WANDA NOT SUPPORTED!
		mutateddeerclops = Params(14,	Anim("throw",				40, in_place),
										Anim("throw_2",				40, to_boss),
										Anim("atk",					13, in_place)),
		-- works okay
		sharkboi		 = Params(5,	Anim("atk1", 				 2, to_boss),
										Anim("atk2_delay",			 0, in_place),
										Anim("torpedo_pre",			17, to_boss),
										Anim("icedive_jump", 		 0, in_place)),
		-- why klei why
		daywalker2		 = Params(4,	Anim("atk_object", 			 0, in_place),
										--Anim("tackle_pre",		 0,	to_boss), -- this attack happens too fast bruuuuh
										--Anim("tackle",			 0,	to_boss),
										Anim("laser_pre",			20, to_boss)),
		-- bone cage sucks!
		stalker			 = Params(4.5,	Anim("attack",				10, in_place),
						dodge_cage and 	Anim("attack1",				 4, bone_cage_dodge == "to boss" and to_boss or in_place) or nil),
		-- bone cage sucks ass!!!!
		stalker_atrium	 = Params(4.5,	Anim("attack",				10, in_place),
						dodge_cage and 	Anim("attack1",				 4, bone_cage_dodge == "to boss" and to_boss or in_place) or nil,
										Anim("spike",				31, in_place)),
		-- if it works it works
		antlion			 = Params(7,	Anim("cast_pre",			11, to_boss)),

		-- players will have to deal with spells on their own, it's not hard :D
		klaus			 = Params(4,	Anim("attack_doubleclaw", 	 0, backaway_ctor(5)),
										Anim("attack_chomp", 		10, backaway_ctor(7))),
	}
end

--[[
function testboss(pref, spawn_new)
	if spawn_new then c_remote(string.format("c_spawn('%s')", pref)) end

	ThePlayer:DoTaskInTime(1, function()
		local boss = c_find(pref)
		if boss then boss:DoPeriodicTask(FRAMES, function(boss) print(boss:GetDebugString()) end) end
	end)
end
--]]

return CreateBossDataTable