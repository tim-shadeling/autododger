local cached_soul, last_sound_time = nil, -1
local quicksoultask
local eatingsouls, droppingsouls

local function soul_condition(item) return item.prefab == "wortox_soul" and item.replica.stackable and 101-item.replica.stackable:StackSize() or nil end

local function EatSoul(pl) -- WORTOX EXCLUSIVE
	if not (cached_soul and cached_soul:IsValid() and cached_soul.replica.inventoryitem and cached_soul.replica.inventoryitem.classified) then
		cached_soul = FindSoul(soul_condition)
	end
	if not cached_soul then
		local time = GetTime()
		if time - last_sound_time >= .7 then
			_G.TheFocalPoint.SoundEmitter:PlaySound("rifts5/generic_metal/clunk")
			last_sound_time = time
		end
		--
		return
	end

	pl.replica.inventory:UseItemFromInvTile(cached_soul)
end

local function DropSoul(pl) -- WORTOX EXCLUSIVE
	if not (cached_soul and cached_soul:IsValid() and cached_soul.replica.inventoryitem and cached_soul.replica.inventoryitem.classified) then
		cached_soul = FindSoul(soul_condition)
	end
	if not cached_soul then
		local time = GetTime()
		if time - last_sound_time >= .25 then
			_G.TheFocalPoint.SoundEmitter:PlaySound("rifts5/generic_metal/clunk")
			last_sound_time = time
		end
		--
		return
	end

	pl.replica.inventory:DropItemFromInvTile(cached_soul)
end

local function StartEatingSouls() -- WORTOX EXCLUSIVE
	if not InGame() or not TheMod.is_imp or quicksoultask then return end
	quicksoultask = _G.ThePlayer:DoPeriodicTask(.35, EatSoul, 0)
	eatingsouls = true
end

local function StartDroppingSouls() -- WORTOX EXCLUSIVE
	if not InGame() or not TheMod.is_imp or quicksoultask then return end
	quicksoultask = _G.ThePlayer:DoPeriodicTask(0, DropSoul, 0)
	droppingsouls = true
end

local function StopEatingSouls() -- WORTOX EXCLUSIVE
	if not InGame() or not TheMod.is_imp or droppingsouls or not quicksoultask then return end
	quicksoultask:Cancel()
	quicksoultask = nil
	eatingsouls = nil
	last_sound_time = -1
end

local function StopDroppingSouls() -- WORTOX EXCLUSIVE
	if not InGame() or not TheMod.is_imp or eatingsouls or not quicksoultask then return end
	quicksoultask:Cancel()
	quicksoultask = nil
	droppingsouls = nil
	last_sound_time = -1
end

Bind("EATSOUL_KEY", StartEatingSouls, true)
Bind("EATSOUL_KEY", StopEatingSouls)
Bind("DROPSOUL_KEY", StartDroppingSouls, true)
Bind("DROPSOUL_KEY", StopDroppingSouls)