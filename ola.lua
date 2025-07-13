local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui")
gui.Name = "RenderSpyGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120) -- Aumentei a altura pra caber os 2 botões
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

-- Botão "Hackear Animal"
local buttonHackear = Instance.new("TextButton")
buttonHackear.Size = UDim2.new(1, -20, 0, 40)
buttonHackear.Position = UDim2.new(0, 10, 0, 20)
buttonHackear.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
buttonHackear.TextColor3 = Color3.new(1, 1, 1)
buttonHackear.Font = Enum.Font.SourceSansBold
buttonHackear.TextSize = 20
buttonHackear.Text = "Hackear Animal"
buttonHackear.Parent = frame

-- Botão "Arquivos da Pasta"
local buttonArquivos = Instance.new("TextButton")
buttonArquivos.Size = UDim2.new(1, -20, 0, 40)
buttonArquivos.Position = UDim2.new(0, 10, 0, 70)
buttonArquivos.BackgroundColor3 = Color3.fromRGB(100, 150, 50)
buttonArquivos.TextColor3 = Color3.new(1, 1, 1)
buttonArquivos.Font = Enum.Font.SourceSansBold
buttonArquivos.TextSize = 20
buttonArquivos.Text = "Arquivos da Pasta"
buttonArquivos.Parent = frame

local pasta = workspace:FindFirstChild("RenderedMovingAnimals")

local function encontrarPrimeiroModel(pasta)
	for _, obj in ipairs(pasta:GetChildren()) do
		if obj:IsA("Model") and obj.PrimaryPart then
			return obj
		end
	end
	return nil
end

local function encontrarPrimeiroScript(pasta)
	for _, obj in ipairs(pasta:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			return obj
		end
	end
	return nil
end

buttonHackear.MouseButton1Click:Connect(function()
	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada na workspace.")
		return
	end

	local modelo = encontrarPrimeiroModel(pasta)
	local scriptAlvo = encontrarPrimeiroScript(pasta)

	if not modelo then
		warn("Nenhum modelo válido encontrado!")
		return
	end

	if not scriptAlvo then
		warn("Nenhum script válido encontrado!")
		return
	end

	local posOriginal = humanoidRootPart.Position

	local codigoOriginal
	local success, result = pcall(function()
		return scriptAlvo.Source
	end)
	if success then
		codigoOriginal = result
	else
		warn("Erro ao acessar o código original!")
		return
	end

	humanoid:MoveTo(modelo.PrimaryPart.Position)

	local chegou = false
	local conn
	conn = humanoid.MoveToFinished:Connect(function(reached)
		chegou = true
		conn:Disconnect()
	end)
	repeat task.wait() until chegou

	local msg = Instance.new("TextLabel", frame)
	msg.Size = UDim2.new(1, 0, 0, 20)
	msg.Position = UDim2.new(0, 0, 0, 0)
	msg.BackgroundTransparency = 1
	msg.TextColor3 = Color3.new(1, 1, 0)
	msg.Text = "Segurando E..."
	msg.TextScaled = true
	msg.Parent = frame

	task.wait(2)
	msg:Destroy()

	humanoid:MoveTo(posOriginal)

	chegou = false
	conn = humanoid.MoveToFinished:Connect(function(reached)
		chegou = true
		conn:Disconnect()
	end)
	repeat task.wait() until chegou

	local success2, novoCodigo = pcall(function()
		return scriptAlvo.Source
	end)

	if not success2 then
		warn("Erro ao verificar o código depois da interação.")
		return
	end

	if novoCodigo ~= codigoOriginal then
		warn("⚠️ O código do script foi ALTERADO!")
	else
		print("✅ O código do script permanece o mesmo.")
	end
end)

buttonArquivos.MouseButton1Click:Connect(function()
	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada na workspace.")
		return
	end

	print("=== Arquivos na pasta 'RenderedMovingAnimals' ===")
	for _, obj in ipairs(pasta:GetChildren()) do
		print(string.format("Nome: %s | Tipo: %s", obj.Name, obj.ClassName))
	end
	print("===============================================")
end)
