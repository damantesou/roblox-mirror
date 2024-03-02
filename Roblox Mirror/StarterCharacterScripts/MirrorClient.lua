local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local mirrors = workspace.Special.Mirrors:GetChildren()
local MIRROR_MODULE = require(game.ReplicatedStorage.mirrorFunctionality)

-- reflect local player only.



function isPointVisible(worldPoint, ignore : {any}) -- shoutout to roblox autocomplete!!!(i modernised it a bit.)
	local _, onScreen = camera:WorldToViewportPoint(worldPoint)

	if onScreen then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore

		local origin = camera.CFrame.p
		local ray = workspace:Raycast(origin, (worldPoint - origin).Unit * math.huge, params)
		if ray then
			return false
		end
	else
		return false
	end
	return true
end

function get_all_player_characters()
	local list_characters = {}
	for i,plr in game:GetService("Players"):GetPlayers() do
		local char = plr.Character or nil
		if char ~= nil then
			table.insert(list_characters, char)
		end
	end
	return list_characters
end

RunService.RenderStepped:Connect(function(dt)
	for i, mirror in mirrors do
		local ID = mirror.ID.Value
		local my_char = game.Players.LocalPlayer.Character
		if isPointVisible(mirror.Position, {}) then
			if my_char ~= nil then
				local plr_characters = get_all_player_characters()
				if #plr_characters > 0 then
					for i, plrchar in plr_characters do -- npc reflect loop
						local fake_plr_name = tostring(plrchar.Name.."_"..game.Players:GetPlayerFromCharacter(my_char).UserId)
						local fake_npc

						if not mirror.fakes:FindFirstChild(fake_plr_name) then
							plrchar.Archivable = true

							fake_npc = plrchar:Clone()
							fake_npc.Name = fake_plr_name

							for i, d in fake_npc:GetDescendants() do
								if d:IsA("Motor6D") then
									d:Destroy()
								end

								if d:IsA("BaseScript") then
									d:Destroy()
								end

								if d:IsA("BasePart") then
									d.Anchored = true
									d.CanCollide = false
								end
							end

							fake_npc.Parent = mirror.fakes
							local owner_tag = Instance.new("ObjectValue", fake_npc)
							owner_tag.Name = "owner"
							owner_tag.Value = plrchar
						else
							fake_npc = mirror.fakes:FindFirstChild(fake_plr_name)
						end


						if plrchar.Humanoid.Health <= 0 or plrchar == nil then
							local target = fake_npc or nil
							if target ~= nil then
								target:Destroy()
							end
						else
							MIRROR_MODULE:ReflectCharacter(fake_npc, plrchar, mirror)
						end
					end
				end
			end
		end
	end
end)

local player = game.Players.LocalPlayer
local char = player.Character or script.Parent
local clone_name = char.Name.."_"..player.UserId

char.ChildAdded:Connect(function()
	for i,mirror in mirrors do
		if mirror.fakes:FindFirstChild(clone_name) then
			MIRROR_MODULE:ClearCharacter(mirror, mirror.fakes:FindFirstChild(clone_name))
		end
	end
end)

char.ChildRemoved:Connect(function()
	for i,mirror in mirrors do
		if mirror.fakes:FindFirstChild(clone_name) then
			MIRROR_MODULE:ClearCharacter(mirror, mirror.fakes:FindFirstChild(clone_name))
		end
	end
end)