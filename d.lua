local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local radius = 20

-- Aguarda o personagem e o HumanoidRootPart
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function getNearbyPrompt()
	local hrp = getHRP()
	for _, inst in pairs(workspace:GetDescendants()) do
		if inst:IsA("ProximityPrompt") and inst:IsDescendantOf(workspace) then
			local part = inst.Parent
			if part:IsA("BasePart") then
				local dist = (part.Position - hrp.Position).Magnitude
				if dist <= radius then
					return inst, dist
				end
			end
		end
	end
	return nil
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E then
		local prompt, dist = getNearbyPrompt()
		if prompt then
			print("🛰️ Detectado objeto interativo por perto!")
			print("📌 Nome:", prompt.Parent.Name)
			print("📏 Distância:", math.floor(dist) .. " studs")
			print("💲 Texto do botão:", prompt.ObjectText, prompt.ActionText)
			-- prompt:InputHoldBegin() não funciona no client, só simula
		else
			print("⚠️ Nenhum objeto interativo próximo.")
		end
	end
end)
