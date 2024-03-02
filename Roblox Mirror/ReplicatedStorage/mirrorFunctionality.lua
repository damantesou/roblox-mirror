local mirror_module = {}

mirror_module.range = 90

function mirror_module:dump(o) -- THANK YOU STACK OVERFLOW!!!
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. mirror_module:dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

function mirror_module:FindMirrorWithID(id)
	local found = nil
	for i,v in pairs(workspace.Special.Mirrors:GetChildren()) do
		if v:FindFirstChild("ID") then
			if v.ID.Value == id then
				found = v
			end
		end
	end
	return found
end


mirror_module.CheckSight = function(object : Part, sight_part : Part, ignore : {any})
	local rayInfo = RaycastParams.new()
	rayInfo.FilterType = Enum.RaycastFilterType.Exclude
	rayInfo.FilterDescendantsInstances = ignore
	
	local ray = workspace:Raycast(sight_part.Position, (sight_part.Position - object.Position).Unit*math.huge, rayInfo)
	
	return ray
end

mirror_module.IsCharacterVisible = function(character, mirrorPart : Part)
	for i,v in character:GetDescendants() do
		if v:IsA("BasePart") then
			local check = mirror_module.CheckSight(v, mirrorPart, {})
			if check == true then
				return true
			end
		end
	end
	
	return false
end

mirror_module.FindNonPlayerCharacters = function(mirrorPart)
	local range = mirror_module.range
	local npc_list = {}
	
	for i,v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
			table.insert(npc_list, v)
		end 
	end
	
	return npc_list
end

function mirror_module:ClearCharacter(MIRROR, FAKE_CHAR : Model)
	print("clearing character: ".. FAKE_CHAR.Name)
	FAKE_CHAR:Destroy()
end

function mirror_module:ReflectPart(FAKE_PART : BasePart, REAL_PART : BasePart, MIRROR)
	local function reflectCFrame(cframe, mirror) -- THX BADGRAPHIX ON DEVFORUM.
		--Get the CFrame relative to the mirror
		local relCF = mirror.CFrame:toObjectSpace(cframe)

		--Get the original CFrame values
		local x, y, z,
		a, b, c,
		d, e, f,
		g, h, i = relCF:components()

		--Reflecting along Z direction - negate Z axis on 
		--all vectors
		local newCF = CFrame.new(
			x, y, -z,
			a, b, c,
			d, e, f,
			-g, -h, -i
		)

		--Convert back to world space
		local finalCFrame = mirror.CFrame:toWorldSpace(newCF)
		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = finalCFrame:components()
		finalCFrame = CFrame.new(x, y, z, -r00, r01, r02, -r10, r11, r12, -r20, r21, r22)
		return finalCFrame
	end
	
	if FAKE_PART ~= nil then
		FAKE_PART.CFrame = reflectCFrame(REAL_PART.CFrame, MIRROR)
	end
end


function mirror_module:ReflectCharacter(FAKE_CHAR, REAL_CHAR, MIRROR)
	local clone_base_parts = {}
	local real_base_parts = {}
	
	for _, BasePart in FAKE_CHAR:GetDescendants() do
		if BasePart:IsA("BasePart") then
			table.insert(clone_base_parts, BasePart)
		end
	end
	
	for _, BasePart in REAL_CHAR:GetDescendants() do
		if BasePart:IsA("BasePart") then
			table.insert(real_base_parts, BasePart)
		end
	end
	
	
	for i = 1, #real_base_parts do
		mirror_module:ReflectPart(clone_base_parts[i], real_base_parts[i], MIRROR)
	end
end

return mirror_module