local FollowText = require "widgets/followtext"

local HOP_DISTANCE = ACTIONS.BLINK.distance
local HOP_RADIUS = math.sqrt(HOP_DISTANCE * 300 / 1900)
local AUTO_DISTANCE = .9 * HOP_DISTANCE
local AUTO_RADIUS = math.sqrt(AUTO_DISTANCE * 300 / 1900)

local function GetPointBetweenAtCertainDistance(p1, p2, dist)
	local scale = dist/p1:Dist(p2)
	return p1 + (p2 - p1)*scale
end

local function OnRemove(inst)
	local cmp = inst.components.mod_autododger_marker
	if cmp then -- 3 billion ifs end me
		if cmp.followhandler then cmp.followhandler:Remove() end
		if cmp.hop_rebind then cmp.hop_rebind:Remove() end
		if cmp.dodge_bind then cmp.dodge_bind:Remove() end
		if cmp.marker then cmp.marker:Remove() end
		if cmp.maxrange then cmp.maxrange:Remove() end
		if cmp.autohoprange then cmp.autohoprange:Remove() end
		if cmp.timer then cmp.timer:Kill() end
		if cmp._oncameraupdate then TheCamera:RemoveListener(cmp, cmp._oncameraupdate) end
	end
end

local function OnFreeHopsChanged(inst)
	local cmp = inst.components.mod_autododger_marker
	if cmp then
		if cmp.config.autohop then cmp.ready_to_autohop = true end
		inst:StartUpdatingComponent(cmp)
	end
end

local SoulHopMarker = Class(function(self, inst)
	inst:ListenForEvent("onremove", OnRemove)
	inst:ListenForEvent("freesoulhopschanged", OnFreeHopsChanged)

	self.inst = inst
	self.targetpos = Vector3()
	self.markerpos = Vector3()

	local stu = self.inst.skilltreeupdater
	self.echocd = TUNING.WORTOX_FREEHOP_TIMELIMIT
	if stu and stu:IsActivated("wortox_liftedspirits_2") then
		self.echocd = TUNING.SKILLS.WORTOX.WORTOX_FREEHOP_TIMELIMIT_MULT*self.echocd
	else
		self.inst:ListenForEvent("onactivateskill_client", function(p, data) if data and data.skill == "wortox_liftedspirits_2" then self.echocd = TUNING.SKILLS.WORTOX.WORTOX_FREEHOP_TIMELIMIT_MULT*self.echocd end end)
	end
end)

function SoulHopMarker:Init(config)
	self.config = config
	self.hopfn = config.hopfn

	if config.show_maxrange then
		self.maxrange = SpawnPrefab("remi_autododger_circle")
		self.maxrange.AnimState:SetAddColour(1,0,0,1)
		self.maxrange.AnimState:SetMultColour(1,1,1,.7)
		local scale_x,scale_y,scale_z = self.inst.Transform:GetScale()
		self.maxrange.Transform:SetScale(HOP_RADIUS/scale_x,HOP_RADIUS/scale_y,HOP_RADIUS/scale_z)
		self.maxrange.entity:SetParent(self.inst.entity)
	end

	if config.show_timer then
		self.timer = self.inst.HUD.overlayroot:AddChild(FollowText(BODYTEXTFONT,25))
		self.timer:SetHUD(self.inst.HUD.inst)
		self.timer:SetOffset(Vector3(0,70,0))
		self.timer:SetTarget(self.inst)
		self.timer.text:SetString(" ")
		self.timer:Hide()
	end
		
	if config.show_marker then
		self.marker = SpawnPrefab("remi_autododger_marker")
		self.marker.AnimState:SetMultColour(.6,1,.6,1)
	end

	if config.autohop then
		self.autohoprange = SpawnPrefab("remi_autododger_circle")
		self.autohoprange.AnimState:SetAddColour(1,1,0,1)
		self.autohoprange.AnimState:SetMultColour(1,1,1,.3)
		local scale_x,scale_y,scale_z = self.inst.Transform:GetScale()
		self.autohoprange.Transform:SetScale(AUTO_RADIUS/scale_x,AUTO_RADIUS/scale_y,AUTO_RADIUS/scale_z)
		self.autohoprange.entity:SetParent(self.inst.entity)
	end

	self.followhandler = TheInput:AddMoveHandler(function(x, y, z)
		x, y, z = TheSim:ProjectScreenPos(x, y)
		if x and y and z then self.targetpos = Vector3(x,y,z) end
		self:UpdateMarkerPosition()
	end)
	self._oncameraupdate = function(dt) self:OnCameraUpdate(dt) end
	TheCamera:AddListener(self, self._oncameraupdate)

	if config.soul_hop_rebind > 0 then
		local oldpointspecialactionsfn = self.inst.components.playeractionpicker.pointspecialactionsfn
		self.inst.components.playeractionpicker.pointspecialactionsfn = function(inst, pos, useitem, right,...)
			return inst.checkingmapactions and (oldpointspecialactionsfn and oldpointspecialactionsfn(inst,pos,useitem,right,...)) or {}
		end
		self.hop_rebind = config.bindfn(config.soul_hop_rebind, true, function()
			if not (self.inst and self.inst.HUD and not self.inst.HUD:HasInputFocus()) then return end
			if self.hopfn(self.markerpos, 5, 1, 2) then self:FlashMarker() end
		end)
	end

	if config.dodge_key > 0 then
		self.dodge_bind = config.bindfn(config.dodge_key, false, function()
			if not (self.inst and self.inst.HUD and not self.inst.HUD:HasInputFocus()) then return end
			self.hopfn(self.inst:GetPosition(), 5, 1, 2)
		end)
	end

	self:UpdateUsedSoul()
end

function SoulHopMarker:UpdateUsedSoul()
	if self.lastsoul == nil or not self.lastsoul:IsValid() then
		for _,item in pairs(self.inst.replica.inventory:GetItems()) do
			if item.prefab == "wortox_soul" then
				self.lastsoul = item
				self.lastnetvar = table.getfield(item, "replica.inventoryitem.classified.recharge")
				return true 
			end
		end
		return false
	end
	return true
end

function SoulHopMarker:UpdateTimer(dt)
	if not self:UpdateUsedSoul() then
		self.inst:StopUpdatingComponent(self)
		if self.timer then self.timer:Hide() end
		self.ready_to_autohop = nil
		return
	end

	local pct = self.lastnetvar and 1 - self.lastnetvar:value() / 180 or 0

	if pct <= 0 then
		self.inst:StopUpdatingComponent(self)
		if self.timer then self.timer:Hide() end
		self.ready_to_autohop = nil
	else
		local time_left = pct * self.echocd

		if self.timer then
			self.timer:Show()
			self.timer.text:SetColour(1,1-pct,1-pct,1)
			self.timer.text:SetString(string.format("Soul Echo: %0.2fs", pct * self.echocd))	
		end
		
		if self.ready_to_autohop and time_left <= .5 + .002*TheNet:GetAveragePing() then
			self.ready_to_autohop = nil
			if self.targetpos:DistSq(self.inst:GetPosition()) >= AUTO_DISTANCE^2 then
				if self.hopfn(self.markerpos, 5, 1, 1) then self:FlashMarker() end
			end
		end
	end
end

function SoulHopMarker:OnUpdate(dt)
	self:UpdateTimer(dt)
end

function SoulHopMarker:UpdateMarkerPosition(dt)
	local plpos = self.inst:GetPosition()
	local distsq = plpos:DistSq(self.targetpos)

	if self.config.snap_to_max_range and distsq >= HOP_DISTANCE^2 then
		self.markerpos = GetPointBetweenAtCertainDistance(plpos, self.targetpos, HOP_DISTANCE - .1)
		distsq = HOP_DISTANCE^2
	else
		if self.config.targeted_hops then
			local target = ConsoleWorldEntityUnderMouse()
			self.markerpos = target and target:GetPosition() or self.targetpos
		else
			self.markerpos = self.targetpos
		end
	end

	if self.marker then
		distsq = distsq/HOP_DISTANCE^2
		if self.maxrange then self.maxrange.AnimState:SetMultColour(1,1,1,math.max(0, -.15 + 1.15*distsq)) end
		if self.autohoprange then self.autohoprange.AnimState:SetMultColour(1,1,1,math.max(0, -.15 + .45*distsq)) end

		if not self:UpdateUsedSoul() then
			self.marker:Hide()
			return
		else
			self.marker:Show()
		end

		self.marker.Transform:SetPosition(self.markerpos.x,0,self.markerpos.z)

		local scale = 1 + distsq*3
		self.marker.scale = scale
		self.marker.AnimState:SetScale(scale, scale, scale)

		if self.inst.CanBlinkTo(self.markerpos) then
			if self.ready_to_autohop then self.marker.AnimState:SetMultColour(1,1,.2,1) else self.marker.AnimState:SetMultColour(.6,1,.6,1) end
		else
			self.marker.AnimState:SetMultColour(1,0,0,1)
		end
	end
end

function SoulHopMarker:OnCameraUpdate(dt)
    self.targetpos = TheInput:GetWorldPosition()
    self:UpdateMarkerPosition()
end

function SoulHopMarker:FlashMarker()
	if self.marker then self.marker:Flash() end
end

function SoulHopMarker:OnRemoveFromEntity()
	OnRemove(self.inst)
end

return SoulHopMarker