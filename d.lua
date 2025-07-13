local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Atualiza referência do personagem em caso de morte/reset
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RenderSpyGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

-- Botão Hackear
local buttonHackear = Instance.new("TextButton")
buttonHackear.Size = UDim2.new(1, -20, 0, 40)
buttonHackear.Position = UDim2.new(0, 10, 0, 20)
buttonHackear.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
buttonHackear.TextColor3 = Color3.new(1, 1, 1)
buttonHackear.Font = Enum.Font.SourceSansBold
buttonHackear.TextSize = 20
buttonHackear.Text = "Hackear Animal"
buttonHackear.Parent = frame

-- Botão Mostrar arquivos
local buttonArquivos = Instance.new("TextButton")
buttonArquivos.Size = UDim2.new(1, -20, 0, 40)
buttonArquivos.Position = UDim2.new(0, 10, 0, 70)
buttonArquivos.BackgroundColor3 = Color3.fromRGB(100, 150, 50)
buttonArquivos.TextColor3 = Color3.new(1, 1, 1)
buttonArquivos.Font = Enum.Font.SourceSansBold
buttonArquivos.TextSize = 20
buttonArquivos.Text = "Arquivos da Pasta"
buttonArquivos.Parent = frame

-- Pasta
local pasta = workspace:FindFirstChild("RenderedMovingAnimals")

local function encontrarUltimoModel(pasta)
	if not pasta then return nil end
	local modelos = {}
	for _, obj in ipairs(pasta:GetChildren()) do
		if obj:IsA("Model") and obj.PrimaryPart then
			table.insert(modelos, obj)
		end
	end
	return modelos[#modelos]
end

local function encontrarPrompt(modelo)
	for _, descendente in ipairs(modelo:GetDescendants()) do
		if descendente:IsA("ProximityPrompt") then
			return descendente
		end
	end
	return nil
end

-- Flag para evitar múltiplas execuções
local emExecucao = false

-- Hackear (seguindo colado)
buttonHackear.MouseButton1Click:Connect(function()
	if emExecucao then return end
	emExecucao = true

	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada.")
		emExecucao = false
		return
	end

	local modelo = encontrarUltimoModel(pasta)
	if not modelo then
		warn("Nenhum modelo com PrimaryPart encontrado.")
		emExecucao = false
		return
	end

	local posOriginal = humanoidRootPart.Position

	-- Cola no modelo enquanto ele se move
	local seguir = true
	local seguirConn
	seguirConn = RunService.Heartbeat:Connect(function()
		if seguir and modelo and modelo.PrimaryPart then
			local alvoPos = modelo.PrimaryPart.Position + Vector3.new(0, 0, -2)
			humanoid:MoveTo(alvoPos)
		end
	end)

	-- Esperar colar (muito perto)
	repeat task.wait() until (humanoidRootPart.Position - modelo.PrimaryPart.Position).Magnitude <= 3

	-- Parar de seguir

	-- Interface: simulando E
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, 0, 0, 20)
	msg.Position = UDim2.new(0, 0, 0, 0)
	msg.BackgroundTransparency = 1
	msg.TextColor3 = Color3.new(1, 1, 0)
	msg.Text = "Segurando E (automático)......"
	msg.TextScaled = true
	msg.Font = Enum.Font.SourceSansBold
	msg.Parent = frame

	-- Busca recursiva por um ProximityPrompt em qualquer lugar do modelo
	local prompt = encontrarPrompt(modelo)
	if prompt then
		print("Encontrado prompt:", prompt.Name, "HoldDuration:", prompt.HoldDuration)
		prompt:InputHoldBegin()
		task.wait(prompt.HoldDuration + 0.1)
		prompt:InputHoldEnd()
	else
		task.wait(2)
	end

	msg.Text = "✅ Hack concluído!"
	task.wait(1)
	msg:Destroy()

	-- Voltar ao ponto original
	humanoid:MoveTo(posOriginal)

	emExecucao = false
end)

-- Mostrar arquivos
buttonArquivos.MouseButton1Click:Connect(function()
	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada.")
		return
	end

	print("📦 Arquivos em 'RenderedMovingAnimals':")
	for _, obj in ipairs(pasta:GetChildren()) do
		print(string.format("  🔹 Nome: %s | Tipo: %s", obj.Name, obj.ClassName))
	end
end)
