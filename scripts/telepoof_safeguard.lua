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

AddClassPostConstruct("widgets/itemtile", function(self)
	if not (self.item and self.item.prefab == "orangestaff" and self.item.replica.equippable:IsEquipped()) then return end

    self.colorcode = self:AddChild(UIAnim())
    self.colorcode:MoveToBack()
    self.colorcode:GetAnimState():SetBank("spoiled_meter")
    self.colorcode:GetAnimState():SetBuild("spoiled_meter")
    self.colorcode:GetAnimState():SetPercent("anim", 0)
    self.colorcode:GetAnimState():AnimateWhilePaused(false)
    self.colorcode:SetClickable(false)
    --
    self.colorcode:GetAnimState():SetMultColour(0,0,0,1)
    self.colorcode:GetAnimState():SetAddColour(unpack(TheMod.telepoof_enabled and TELEPOOF_ON_COLOR or TELEPOOF_OFF_COLOR))
    --
	local old_startdrag = self.StartDrag
	function self:StartDrag()
		old_startdrag(self)
	    if self.item.replica.inventoryitem ~= nil then
	    	if self.colorcode then self.colorcode:Hide() end
	    end
	end
end)

AddClassPostConstruct("widgets/equipslot", function(self)
	local oldOnMouseButton = self.OnMouseButton
	function self:OnMouseButton(button, down, x, y)
		local has_orangestaff = self.tile and self.tile.item and self.tile.item.prefab == "orangestaff"
		if has_orangestaff and down and button == _G.MOUSEBUTTON_MIDDLE then
			SwapMode()
			self.tile.colorcode:GetAnimState():SetAddColour(unpack(TheMod.telepoof_enabled and TELEPOOF_ON_COLOR or TELEPOOF_OFF_COLOR))
			return true
		else
			return oldOnMouseButton(self, button, down, x, y)
		end
	end
end)