local BOSSES = require "autododger_boss_data"()
autododger = BOSSES

local HOP_DISTANCE = ACTIONS.BLINK.distance
local player_within_range = false

local function OnRemove(inst)
	local cmp = inst.components.mod_autododger
	if cmp then
		cmp:StopDodging()
		if cmp.toggle_bind then cmp.toggle_bind:Remove() end
	end
end

local AutoDodger = Class(function(self, inst)
	inst:ListenForEvent("onremove", OnRemove)

	self.inst = inst
	self.active_boss = nil
	self.active_params = nil
	--
	self.kite_tasks = {}
	--
	self.range_indicator = nil
end)

function AutoDodger:Init(config)
	self.config = config
	self.hopfn = config.hopfn
		
	if config.kite_key > 0 then
		self.toggle_bind = config.bindfn(config.kite_key, false, function() self:ToggleDodging() end) 
	end
end

function AutoDodger:AttachRangeIndicator(target, radius)
	if self.range_indicator then self.range_indicator:Remove() end
	
	self.range_indicator = SpawnPrefab("remi_autododger_circle")
	self.range_indicator.entity:SetParent(target.entity)
	local scale_x,scale_y,scale_z = target.Transform:GetScale()
	radius = math.sqrt(radius*300/1900)
	self.range_indicator.Transform:SetScale(radius/scale_x,radius/scale_y,radius/scale_z)
	self.range_indicator.AnimState:SetMultColour(0,0,0,0)
	self.range_indicator.AnimState:SetBrightness(4)
end

function AutoDodger:FindBoss()
	return FindEntity(self.inst, HOP_DISTANCE, function(guy) return not guy:HasTag("isdead") and BOSSES[guy.prefab] end) 
end

function AutoDodger:ToggleDodging()
	if self.active_params then self:StopDodging("Stopped dodging.") else self:StartDodging() end 
end

function AutoDodger:CheckPlayerWithinRange(boss, range)
	player_within_range = self.inst:GetPosition():DistSq(boss:GetPosition()) <= range^2
	if player_within_range then self.range_indicator.AnimState:SetMultColour(0,1,0,1) else self.range_indicator.AnimState:SetMultColour(1,0,0,1) end
end

function AutoDodger:StartDodging()
	local boss = self:FindBoss()
	if not boss then
		self.inst.components.talker:Say("No suitable bosses around.")
		return
	end

	self.active_params = BOSSES[boss.prefab]
	local range = self.active_params.range

	self:AttachRangeIndicator(boss, range)

	self.kite_tasks[0] = self.inst:DoPeriodicTask(0, function(inst)
		if not boss:IsValid() or boss:HasTag("isdead") then
			self:StopDodging("Target lost.")
			return
		end
		self:CheckPlayerWithinRange(boss, range)
	end)
	for index, anim in pairs(self.active_params.anims) do
		self.kite_tasks[index] = self.inst:DoPeriodicTask(FRAMES, function(inst)
			if player_within_range and
			boss.AnimState:IsCurrentAnimation(anim.name) and
			boss.AnimState:GetCurrentAnimationFrame() == anim.frame + (TheWorld.ismastersim and 1 or 0)
			then
				self.hopfn(anim.destinationfn(inst, boss), 5, 1, 1)
				self.range_indicator:Flash()
			end
		end)
	end

	self.inst.components.talker:Say("Now dodging: "..boss.name..".")
end

function AutoDodger:StopDodging(msg)
	for _,task in pairs(self.kite_tasks) do task:Cancel() end
	self.active_params = nil
	if self.range_indicator then self.range_indicator:Remove() end
	self.range_indicator = nil
	if msg then self.inst.components.talker:Say(msg) end
end

function AutoDodger:OnRemoveFromEntity()
	OnRemove(self.inst)
end

return AutoDodger