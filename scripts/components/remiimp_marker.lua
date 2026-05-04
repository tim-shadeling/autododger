local FollowText = require "widgets/followtext"

local TheModConfig
local HOP_DISTANCE = ACTIONS.BLINK.distance
local HOP_RADIUS = math.sqrt(HOP_DISTANCE * 300 / 1900)
local AUTO_DISTANCE-- = (LoadConfig("AUTOHOP_DIST_MULT") or .9) * HOP_DISTANCE
local AUTO_RADIUS-- = math.sqrt(AUTO_DISTANCE * 300 / 1900)

local timer_r1, timer_g1, timer_b1
local timer_r2, timer_g2, timer_b2
local maxrange_r, maxrange_g, maxrange_b
local autohop_r, autohop_g, autohop_b

local CanTeleport = require("remiimp_helperfns").CanTeleport

local function GetPointBetweenAtCertainDistance(p1, p2, dist)
	local scale = dist/p1:Dist(p2)
	return p1 + (p2 - p1)*scale
end

local function OnFreeHopsChanged(inst)
	local cmp = inst.components.remiimp_marker
	if not cmp then return end
	
	if TheModConfig.AUTOHOP then cmp.ready_to_autohop = true end
	inst:StartUpdatingComponent(cmp)
end

local function OnRemove(inst)
	local cmp = inst.components.remiimp_marker
	if not cmp then return end
	--
	inst:RemoveEventCallback("onremove", OnRemove)
	cmp.maxrange:Remove()
	cmp.marker:Remove()
	TheCamera:RemoveListener(cmp, cmp._oncameraupdate)
	--
	if not mod_remiimp.is_imp then return end
	--
	inst:RemoveEventCallback("freesoulhopschanged", OnFreeHopsChanged)
	cmp.timer:Kill()
	cmp.autohoprange:Remove()
end

local SoulHopMarker = Class(function(self, inst)
	-- GENERAL ELEMENTS
	inst:ListenForEvent("onremove", OnRemove)
	
	self.inst = inst
	self.targetpos = Vector3()
	self.markerpos = Vector3()
	self.markersvisible = true

	self.maxrange = SpawnPrefab("remiimp_circle")
	--self.maxrange.AnimState:SetAddColour(1,0,0,1)
	self.maxrange.AnimState:SetMultColour(1,1,1,.7)
	local scale_x,scale_y,scale_z = self.inst.Transform:GetScale()
	self.maxrange.Transform:SetScale(HOP_RADIUS/scale_x,HOP_RADIUS/scale_y,HOP_RADIUS/scale_z)
	self.maxrange.entity:SetParent(self.inst.entity)

	self.marker = SpawnPrefab("remiimp_marker")
	self.marker.AnimState:SetMultColour(.6,1,.6,1)

	self._oncameraupdate = function(dt) self:OnCameraUpdate(dt) end
	TheCamera:AddListener(self, self._oncameraupdate)

	--
	if not mod_remiimp.is_imp then return end
	--

	-- WORTOX-EXCLUSIVE ELEMENTS
	inst:ListenForEvent("freesoulhopschanged", OnFreeHopsChanged)

	local stu = self.inst.skilltreeupdater
	self.echocd = TUNING.WORTOX_FREEHOP_TIMELIMIT
	if stu and stu:IsActivated("wortox_liftedspirits_2") then
		self.echocd = TUNING.SKILLS.WORTOX.WORTOX_FREEHOP_TIMELIMIT_MULT*self.echocd
	else
		self.inst:ListenForEvent("onactivateskill_client", function(p, data) if data and data.skill == "wortox_liftedspirits_2" then self.echocd = TUNING.SKILLS.WORTOX.WORTOX_FREEHOP_TIMELIMIT_MULT*self.echocd end end)
	end

	self.timer = self.inst.HUD.root:AddChild(FollowText(BODYTEXTFONT,1))
	self.timer:SetHUD(self.inst.HUD.inst)
	self.timer:SetOffset(Vector3(0,70,0))
	self.timer:SetTarget(self.inst)
	self.timer.text:SetString("")

	self.autohoprange = SpawnPrefab("remiimp_circle")
	--self.autohoprange.AnimState:SetAddColour(1,1,0,1)
	self.autohoprange.AnimState:SetMultColour(1,1,1,.3)
	--local scale_x,scale_y,scale_z = self.inst.Transform:GetScale()
	--self.autohoprange.Transform:SetScale(AUTO_RADIUS/scale_x,AUTO_RADIUS/scale_y,AUTO_RADIUS/scale_z)
	self.autohoprange.entity:SetParent(self.inst.entity)

	local oldrmbfn = self.inst.components.playeractionpicker.pointspecialactionsfn
	self.inst.components.playeractionpicker.pointspecialactionsfn = function(inst, pos, useitem, right,...)
		return (TheModConfig and TheModConfig.SOUL_HOP_REBIND <= 0 or inst.checkingmapactions) and oldrmbfn(inst, pos, useitem, right, ...) or {}
	end
end)

function SoulHopMarker:Reconfigure(config)
	TheModConfig = config
	local cantp = self:UpdateCanTeleport()

	-- GENERAL ELEMENTS
	if cantp and TheModConfig.SHOW_MAXRANGE then self.maxrange:Show() else self.maxrange:Hide() end
	local r, g, b = unpack(TheModConfig.maxrange_color)
	self.maxrange.AnimState:SetAddColour(r,g,b,1)

	if cantp and TheModConfig.SOUL_HOP_REBIND > 0 and TheModConfig.SHOW_MARKER then self.marker:Show() else self.marker:Hide() end

	--
	if not mod_remiimp.is_imp then return end
	--

	-- WORTOX-EXCLUSIVE ELEMENTS
	timer_r1, timer_g1, timer_b1 = unpack(TheModConfig.timer_color_1)
	timer_r2, timer_g2, timer_b2 = unpack(TheModConfig.timer_color_2)
	self.timer.text:SetFont(TheModConfig.timer_font)
	self.timer.text:SetSize(TheModConfig.timer_size)

	if cantp and TheModConfig.AUTOHOP then self.autohoprange:Show() else self.autohoprange:Hide() end
	AUTO_DISTANCE = TheModConfig.AUTOHOP_DIST_MULT * HOP_DISTANCE
	AUTO_RADIUS = math.sqrt(AUTO_DISTANCE * 300 / 1900)
	local scale_x,scale_y,scale_z = self.inst.Transform:GetScale()
	self.autohoprange.Transform:SetScale(AUTO_RADIUS/scale_x,AUTO_RADIUS/scale_y,AUTO_RADIUS/scale_z)
	r, g, b = unpack(TheModConfig.autohop_color)
	self.autohoprange.AnimState:SetAddColour(r,g,b,1)
end

function SoulHopMarker:UpdateCanTeleport()
	local helditem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if helditem and helditem.prefab == "orangestaff" and helditem.replica.inventoryitem.classified.percentused:value() > 5 and mod_remiimp.telepoof_enabled then
		return true
	end

	if not mod_remiimp.is_imp then return false end

	if self.lastsoul and self.lastsoul:IsValid() and self.lastsoul.replica.inventory.classified then
		return true
	else
		for _,item in pairs(self.inst.replica.inventory:GetItems()) do
			if item.prefab == "wortox_soul" then
				self.lastsoul = item
				self.lastnetvar = table.getfield(item, "replica.inventoryitem.classified.recharge")
				return true 
			end
		end
	end

	return false
end

function SoulHopMarker:UpdateTimer(dt) -- WORTOX EXCLUSIVE
	if not self:UpdateCanTeleport() then
		self.inst:StopUpdatingComponent(self)
		self.timer:Hide()
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

		if TheModConfig.SHOW_TIMER then self.timer:Show() else self.timer:Hide() end
		local npct = 1-pct
		self.timer.text:SetColour(timer_r1*pct+timer_r2*npct,timer_g1*pct+timer_g2*npct,timer_b1*pct+timer_b2*npct,1) -- pct is decreasing so it goes from color 1 to color 2
		self.timer.text:SetString(string.format("Soul Echo: %0.1fs", time_left))	
		
		if self.ready_to_autohop and not TheInput:GetHUDEntityUnderMouse() and time_left <= .5 + .002*TheNet:GetAveragePing() then
			self.ready_to_autohop = nil
			if self.targetpos:DistSq(self.inst:GetPosition()) >= AUTO_DISTANCE^2 then
				if mod_remiimp.Hop(self.markerpos, 5, 1, 1) then self:FlashMarker() end
			end
		end
	end
end

function SoulHopMarker:OnUpdate(dt) -- WORTOX EXCLUSIVE
	self:UpdateTimer(dt)
end

function SoulHopMarker:UpdateMarkerPosition(dt)
	local cantp = self:UpdateCanTeleport()
	local plpos = self.inst:GetPosition()
	local distsq = plpos:DistSq(self.targetpos)

	-- GENERAL ELEMENTS
	if cantp then
		if not self.markersvisible then
			if TheModConfig.SHOW_MARKER and TheModConfig.SOUL_HOP_REBIND > 0 then self.marker:Show() end
			if TheModConfig.SHOW_MAXRANGE then self.maxrange:Show() end
		end
		--
		local alpha = math.clamp(distsq/HOP_DISTANCE^2, 0, 1)
		self.maxrange.AnimState:SetMultColour(1,1,1,alpha) 
		
		if TheModConfig.SNAP_TO_MAX_RANGE and distsq >= HOP_DISTANCE^2 then
			self.markerpos = GetPointBetweenAtCertainDistance(plpos, self.targetpos, HOP_DISTANCE - .1)
			distsq = HOP_DISTANCE^2
		else
			if TheModConfig.TARGETED_HOPS then
				local target = ConsoleWorldEntityUnderMouse()
				self.markerpos = target and target:GetPosition() or self.targetpos
			else
				self.markerpos = self.targetpos
			end
		end

		local scale = 1 + alpha*3
		self.marker.scale = scale
		self.marker.AnimState:SetScale(scale, scale, scale)

		if CanTeleport(self.markerpos) then
			if self.ready_to_autohop then self.marker.AnimState:SetMultColour(1,1,0,1) else self.marker.AnimState:SetMultColour(.1,1,.6,1) end
		else
			self.marker.AnimState:SetMultColour(1,0,0,1)
		end
		
		self.marker.Transform:SetPosition(self.markerpos.x,0,self.markerpos.z)
	else
		self.marker:Hide()
		self.maxrange:Hide()
	end

	-- WORTOX-EXCLUSIVE ELEMENTS
	if mod_remiimp.is_imp then
		if cantp then
			if not self.markersvisible then
				if TheModConfig.AUTOHOP then self.autohoprange:Show() end
			end
			--
			local auto_alpha = math.clamp(distsq/AUTO_DISTANCE^2, 0, 1)
			self.autohoprange.AnimState:SetMultColour(1,1,1,auto_alpha*.5) 
		else
			self.autohoprange:Hide()
		end
	end

	--
	self.markersvisible = cantp
end

function SoulHopMarker:OnCameraUpdate(dt)
    self.targetpos = TheInput:GetWorldPosition() or self.targetpos
    self:UpdateMarkerPosition()
end

function SoulHopMarker:FlashMarker()
	self.marker:Flash()
end

function SoulHopMarker:OnRemoveFromEntity()
	OnRemove(self)
end

return SoulHopMarker