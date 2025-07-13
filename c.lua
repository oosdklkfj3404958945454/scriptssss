local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

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

-- Pasta com animais
local pasta = workspace:FindFirstChild("RenderedMovingAnimals")

-- Pega o último modelo com PrimaryPart
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

-- Hackear (simulação automática)
buttonHackear.MouseButton1Click:Connect(function()
	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada.")
		return
	end

	local modelo = encontrarUltimoModel(pasta)
	if not modelo then
		warn("Nenhum modelo com PrimaryPart encontrado.")
		return
	end

	local posOriginal = humanoidRootPart.Position
	local seguindo = true

	print("Acompanhando modelo:", modelo.Name)

	-- Seguir o modelo enquanto ele se move
	local seguirConn = RunService.Heartbeat:Connect(function()
		if seguindo and modelo and modelo.PrimaryPart then
			local dist = (humanoidRootPart.Position - modelo.PrimaryPart.Position).Magnitude
			if dist > 5 then
				humanoid:MoveTo(modelo.PrimaryPart.Position)
			end
		end
	end)

	-- Esperar ficar perto
	repeat task.wait() until (humanoidRootPart.Position - modelo.PrimaryPart.Position).Magnitude <= 5

	-- Parar de seguir
	seguindo = false
	seguirConn:Disconnect()

	-- Simular "Segurando E" por 2 segundos
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, 0, 0, 20)
	msg.Position = UDim2.new(0, 0, 0, 0)
	msg.BackgroundTransparency = 1
	msg.TextColor3 = Color3.new(1, 1, 0)
	msg.Text = "Segurando E..."
	msg.TextScaled = true
	msg.Font = Enum.Font.SourceSansBold
	msg.Parent = frame

	task.wait(2)
	msg.Text = "✅ Hack concluído!"
	task.wait(1)
	msg:Destroy()

	-- Voltar para onde estava
	humanoid:MoveTo(posOriginal)
	local voltou = false
	local connVolta = humanoid.MoveToFinished:Connect(function()
		voltou = true
		connVolta:Disconnect()
	end)
	repeat task.wait() until voltou

	print("Hack em", modelo.Name, "concluído com sucesso.")
end)

-- Mostrar arquivos da pasta
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
