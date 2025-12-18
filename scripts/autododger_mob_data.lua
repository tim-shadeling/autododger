local function GetPointBetweenAtCertainDistance(p1, p2, dist)
	local scale = dist/p1:Dist(p2)
	return p1 + (p2 - p1)*scale
end

local function in_place(pl, mob)
	return pl:GetPosition()
end

local function to_mob(pl, mob)
	return mob:GetPosition()
end

local function pl_to_mob(dist)
	return function(pl, mob)
		pl, mob = pl:GetPosition(), mob:GetPosition()
		return GetPointBetweenAtCertainDistance(pl, mob, dist)
	end
end 

local function mob_to_pl(dist)
	return function(pl, mob)
		pl, mob = pl:GetPosition(), mob:GetPosition()
		return GetPointBetweenAtCertainDistance(mob, pl, dist)
	end
end 

local function Anim(name, frame, destinationfn)
	return {
		name = name, -- name of anim
		destinationfn = destinationfn, -- whether you need to tp to the mob' position or yours (used to dodge shockwaves)
		frame = frame, -- the frame you need to tp at
	}
end

local function Params(range, ...) -- ... is list of anims
	return {
		range = range, -- how close you have to be
		anims = {...}, -- list of attack animations that would be desirable to dodge with souls/watch
	}
end

local bonecage
local function CreateMobDataTable(modconfig)
	bonecage = function(pl, mob)
		local cfg = mod_remiimp.config.bone_cage_handling
		return cfg == "to_mob" and to_mob(pl, mob) or (cfg == "in_place" and in_place(pl, mob) or nil)
	end

	return {
		bishop			 = Params(13,	Anim("atk",					 0, in_place)),
		bishop_nightmare = Params(13,	Anim("atk",					 0, in_place)),

		--
		dragonfly		 = Params(6,	Anim("atk",					 0, in_place)),
		deerclops		 = Params(4,	Anim("atk",					13,	in_place),
										Anim("atk2",				 0, in_place)),
		leif			 = Params(4.5,	Anim("atk",					 2, in_place)),
		leif_sparse		 = Params(4.5,	Anim("atk",					 2, in_place)),
		moose			 = Params(6,	Anim("atk",					 0, in_place)),
		bearger			 = Params(7.6,	Anim("atk",					10, in_place),	
										Anim("ground_pound",		 6,	to_mob)),
		shadow_bishop	 = Params(14,	Anim("atk_side_pre",		19, pl_to_mob(14))),
		shadow_rook		 = Params(5,	Anim("teleport_atk",		 0, in_place)),
	--	daywalker		 = Params(7,	Anim("atk_slam",			 0, in_place)),
		mutatedbearger	 = Params(5.2,	Anim("atk1",				10,	to_mob),	
										Anim("ground_pound",		 6,	to_mob),
										Anim("butt_pre_L",			20, in_place),
										Anim("butt_pre_R",			20, in_place)),
		mutateddeerclops = Params(14,	Anim("throw",				40, in_place),
										Anim("throw_2",				40, to_mob),
										Anim("atk",					13, in_place)),
		sharkboi		 = Params(5,	Anim("atk1", 				 2, to_mob),
										Anim("atk2_delay",			 0, in_place),
										Anim("torpedo_pre",			17, to_mob),
										Anim("icedive_jump", 		 0, in_place)),
		daywalker2		 = Params(4,	Anim("atk_object", 			 0, in_place),
										--Anim("tackle_pre",		 0,	to_mob), -- this attack happens too fast bruuuuh
										--Anim("tackle",			 0,	to_mob),
										Anim("laser_pre",			20, to_mob)),
		stalker			 = Params(4.5,	Anim("attack",				10, in_place),
										Anim("attack1",				 4, bonecage)),
		stalker_atrium	 = Params(4.5,	Anim("attack",				10, in_place),
										Anim("attack1",				 4, bonecage),
										Anim("spike",				31, in_place)),
		antlion			 = Params(7,	Anim("cast_pre",			11, to_mob)),

		klaus			 = Params(4,	Anim("attack_doubleclaw", 	 0, mob_to_pl(5)),
										Anim("attack_chomp", 		10, mob_to_pl(7))),

		-- shadow bishop?
	}
	-- warbot and scion are not happening, too complex
end

---[[
function testmob(pref, spawn_new)
	if spawn_new then c_remote(string.format("c_spawn('%s')", pref)) end

	ThePlayer:DoTaskInTime(1, function()
		local mob = c_find(pref)
		if mob then mob:DoPeriodicTask(FRAMES, function(mob) print(mob:GetDebugString()) end) end
	end)
end
--]]

return CreateMobDataTable