local flashduration = .4

local function sparkle_fx()
	local inst = CreateEntity()

	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")

	inst.AnimState:SetBank("hits_sparks")
	inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
	inst.AnimState:PlayAnimation("hit_3")
	inst.AnimState:SetLayer(LAYER_WORLD_DEBUG)

	inst:DoTaskInTime(.5, inst.Remove)

	return inst
end

local function Flash(inst)
	local fx = sparkle_fx()
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	local scale = 1 + 0.5*(inst.scale-1)
	fx.AnimState:SetScale(scale, scale, scale)

	inst.flashmult = 1

	if inst.flashtask then inst.flashtask:Cancel() end
	inst.flashtask = inst:DoPeriodicTask(FRAMES, function(inst) 
		inst.flashmult = math.max(0, inst.flashmult - FRAMES/flashduration)
		inst.AnimState:SetAddColour(inst.flashmult,inst.flashmult,inst.flashmult,0)

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

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")

	inst.AnimState:SetBank("pocketwatch_warp_marker")
	inst.AnimState:SetBuild("pocketwatch_warp_marker")
	inst.AnimState:PlayAnimation("mark4_loop", true)
	--inst.AnimState:SetBrightness(1)
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_WORLD_DEBUG)
	inst.AnimState:SetSortOrder(3.1)

	inst.flashmult = 0
	inst.scale = 1
	inst.Flash = Flash

	return inst
end

return Prefab("remiimp_marker", fn)