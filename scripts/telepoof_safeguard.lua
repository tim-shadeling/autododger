local UIAnim = require "widgets/uianim"

-- Digging to the right function...
local EntityScript = _G.EntityScript

local function getupvalue(fn, target_name)
	local i = 1
	local name, val = debug.getupvalue(fn, i)
	while name and name ~= target_name do
		i = i+1
		name, val = debug.getupvalue(fn, i)
	end
	return val, i
end

local COMPONENT_ACTIONS = getupvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local old_blinkstaff_fn
if COMPONENT_ACTIONS and COMPONENT_ACTIONS.POINT and COMPONENT_ACTIONS.POINT.blinkstaff then
	old_blinkstaff_fn = COMPONENT_ACTIONS.POINT.blinkstaff -- there it is!
else
	return
end

-- Now let's do the thing!
TheMod.telepoof_enabled = false

COMPONENT_ACTIONS.POINT.blinkstaff = function(...)
	if TheMod.telepoof_enabled and TheMod.config.SOUL_HOP_REBIND and TheMod.config.SOUL_HOP_REBIND <= 0 then old_blinkstaff_fn(...) end
end

-- Visuals!
local TELEPOOF_ON_COLOR = {1,.5,.1,1}
local TELEPOOF_OFF_COLOR = {.4,.4,.4,1}

local function SwapMode()
	_G.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_object")
	TheMod.telepoof_enabled = not TheMod.telepoof_enabled
end

local function UpdateTileColor(tile)
	if not tile.colorcode then -- REALLY shouldn't happen
		print("ITEMTILE WITH BLINKSTAFF ITEM:", tile.item, "DIDN'T HAVE COLORCODE FOR SOME REASON!!!!! end me")
		return
	end
	tile.colorcode:GetAnimState():SetAddColour(unpack(TheMod.telepoof_enabled and TELEPOOF_ON_COLOR or TELEPOOF_OFF_COLOR))
end

local function TryAddColorCode(tile)
	if tile.colorcode then return end
	--
	tile.colorcode = tile:AddChild(UIAnim())
	tile.colorcode:MoveToBack()
	tile.colorcode:GetAnimState():SetBank("spoiled_meter")
	tile.colorcode:GetAnimState():SetBuild("spoiled_meter")
	tile.colorcode:GetAnimState():SetPercent("anim", 0)
	tile.colorcode:GetAnimState():AnimateWhilePaused(false)
	tile.colorcode:SetClickable(false)
	tile.colorcode:GetAnimState():SetMultColour(0,0,0,1)
	--
	local old_startdrag = tile.StartDrag
	function tile:StartDrag()
		old_startdrag(self)
		if self.item.replica.inventoryitem ~= nil then
			if self.colorcode then 
				self.colorcode:Kill() 
				self.colorcode = nil
			end
		end
	end
end

local function ToggleColorCode(item, tile)
	print("ToggleColorCode", item)
	tile = tile or table.getfield(_G.ThePlayer, "HUD.controls.inv.equip.hands.tile")
	print(tile, tile and tile.item)
	if tile == nil then return end

	if tile.item == item then
		print("blinkstaff:", item:HasActionComponent("blinkstaff"))
		if item:HasActionComponent("blinkstaff") then 
			TryAddColorCode(tile)
			UpdateTileColor(tile)
		elseif tile.colorcode then
			tile.colorcode:Kill()
			tile.colorcode = nil
		end
	end
end

AddClassPostConstruct("widgets/itemtile", function(self)
	local item = self.item
	local equippable = item and item.replica.equippable
	if not equippable or equippable:EquipSlot() ~= _G.EQUIPSLOTS.HANDS then return end
	--
	if equippable:IsEquipped() then 
		ToggleColorCode(item, self)
		--
		item.has_remiimp_listener = true
		item:ListenForEvent("actioncomponentsdirty", ToggleColorCode)
		print("added remiimp listener to", item)
	elseif item.has_remiimp_listener then  -- clean up!
		item.has_remiimp_listener = nil
		item:RemoveEventCallback("actioncomponentsdirty", ToggleColorCode)
		print("removed remiimp listener from", item)
	end
end)

AddClassPostConstruct("widgets/equipslot", function(self)
	-- override both key and mouse btn functions since the keybind is configurable now and can be either a keyboard button or a mouse button
	local oldOnRawKey = self.OnRawKey
	function self:OnRawKey(button, down)
		local has_blinkstaff = self.tile and self.tile.item and self.tile.item:HasActionComponent("blinkstaff")
		if has_blinkstaff and down and button == TheModConfig.TELEPOOF_TOGGLE_KEY then
			SwapMode()
			UpdateTileColor(self.tile)
			return true
		else
			return oldOnRawKey(self, button, down, x, y)
		end
	end

	local oldOnMouseButton = self.OnMouseButton
	function self:OnMouseButton(button, down, x, y)
		local has_blinkstaff = self.tile and self.tile.item and self.tile.item:HasActionComponent("blinkstaff")
		if has_blinkstaff and down and button == TheModConfig.TELEPOOF_TOGGLE_KEY then
			SwapMode()
			UpdateTileColor(self.tile)
			return true
		else
			return oldOnMouseButton(self, button, down, x, y)
		end
	end
end)