local MOB_DATA = require "autododger_mob_data"()
mod_remiimp.autododger = MOB_DATA

local TheModConfig

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
	self.active_params = nil
	self.player_in_range = false
	--
	self.kite_tasks = {}
	--
	self.range_indicator = nil
end)

function AutoDodger:Reconfigure(config)
	TheModConfig = config
end

function AutoDodger:AttachRangeIndicator(target, radius)
	if self.range_indicator then self.range_indicator:Remove() end
	
	local circle = SpawnPrefab("remiimp_circle")
	circle.Follower:FollowSymbol(target.GUID) -- gotta use follower instead of setparent in case the target changes scale (e.g. enraged klaus)
	radius = math.sqrt(radius*300/1900)
	circle.Transform:SetScale(radius,radius,radius)
	circle.AnimState:SetMultColour(0,0,0,0)
	circle.AnimState:SetBrightness(4)
	self.range_indicator = circle
end

function AutoDodger:FindTarget()
	return FindEntity(self.inst, 20, function(ent) return not ent:HasTag("isdead") and MOB_DATA[ent.prefab] end) 
end

function AutoDodger:ToggleDodging()
	if self.active_params then self:StopDodging("Stopped dodging.") else self:StartDodging() end 
end

function AutoDodger:CheckPlayerWithinRange(target, range)
	self.player_in_range = self.inst:GetPosition():DistSq(target:GetPosition()) <= range^2
	if self.player_in_range then self.range_indicator.AnimState:SetMultColour(0,1,0,1) else self.range_indicator.AnimState:SetMultColour(1,0,0,1) end
end

function AutoDodger:StartDodging()
	local target = self:FindTarget()
	if not target then
		self.inst.components.talker:Say("No suitable targets around.")
		return
	end

	self.active_params = MOB_DATA[target.prefab]
	local range = self.active_params.range

	self:AttachRangeIndicator(target, range)

	self.kite_tasks[0] = self.inst:DoPeriodicTask(0, function(inst)
		if not target:IsValid() or target:HasTag("isdead") then
			self:StopDodging("Target lost.")
			return
		end
		self:CheckPlayerWithinRange(target, range)
	end)
	for index, anim in pairs(self.active_params.anims) do
		self.kite_tasks[index] = self.inst:DoPeriodicTask(FRAMES, function(inst)
			if self.player_in_range and
			target.AnimState:IsCurrentAnimation(anim.name) and
			target.AnimState:GetCurrentAnimationFrame() == anim.frame + (TheWorld.ismastersim and 1 or 0)
			then
				mod_remiimp.Hop(anim.destinationfn(inst, target), 5, 1, 1)
				self.range_indicator:Flash()
			end
		end)
	end

	self.inst.components.talker:Say("Now dodging: "..target.name..".")
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