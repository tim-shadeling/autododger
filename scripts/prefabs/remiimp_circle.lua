local flashdelta = .5/6.25
local flashduration = .4

local function Flash(inst)
	inst.flashmult = 1

	local scale = inst._scale or inst.Transform:GetScale()
	inst._scale = scale

	if inst.flashtask then inst.flashtask:Cancel() end
	inst.flashtask = inst:DoPeriodicTask(FRAMES, function(inst) 
		inst.flashmult = math.max(0, inst.flashmult - FRAMES/flashduration)
		inst.AnimState:SetAddColour(inst.flashmult,inst.flashmult,inst.flashmult,0)
		local newscale = scale + inst.flashmult*flashdelta
		inst.Transform:SetScale(newscale, newscale, newscale)

		if inst.flashmult == 0 then
			inst._scale = nil
			inst.flashtask:Cancel()
		end
	end)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("placer")

	inst.AnimState:SetBank("firefighter_placement")
	inst.AnimState:SetBuild("firefighter_placement")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3.1)

	inst.flashmult = 0
	inst.Flash = Flash

	return inst
end

return Prefab("remiimp_circle", fn)