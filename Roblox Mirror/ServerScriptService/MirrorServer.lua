local MIRROR_MODULE = require(game.ReplicatedStorage.mirrorFunctionality)
local mirrors = workspace.Special.Mirrors:GetChildren()

--dont forget to set all player character's network onwer to the players

game["Run Service"].Heartbeat:Connect(function()
	for i,mirror in mirrors do
		local _npcs = MIRROR_MODULE.FindNonPlayerCharacters(mirror)
		if _npcs ~= nil then
			for i, npc in _npcs do -- npc reflect loop
				
				local fake_npc

				if not mirror.fakes:FindFirstChild(npc.Name) then
					npc.Archivable = true
					
					fake_npc = npc:Clone()
					fake_npc.Name = npc.Name
					
					for i, d in fake_npc:GetDescendants() do
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
					owner_tag.Value = npc
				else
					fake_npc = mirror.fakes:FindFirstChild(npc.Name)
				end


				if npc.Humanoid.Health <= 0 or npc == nil then
					local target = fake_npc or nil
					if target ~= nil then
						target:Destroy()
					end
				else
					MIRROR_MODULE:ReflectCharacter(fake_npc, npc, mirror)
				end
			end
		end

		if #mirror.fakes:GetChildren() > 0 then
			for i, fake in mirror.fakes:GetChildren() do -- remove character clones whose owners no longer belong on workspace.
				if not game.Players:GetPlayerFromCharacter(fake.owner.Value) then
					if not workspace:FindFirstChild(fake.Name) then
						fake:Destroy()
					end
				end
			end
		end
	end
end)