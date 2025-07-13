local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Interface
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
	if not pasta then return nil end
	for _, obj in ipairs(pasta:GetChildren()) do
		if obj:IsA("Model") and obj.PrimaryPart then
			return obj
		end
	end
	return nil
end

-- "Pressionar e segurar E"
local function esperarSegurarTecla(tecla, tempoSegurar)
	local tempoPressionado = 0
	local segurando = false
	local interrompido = false

	local function reset()
		tempoPressionado = 0
		segurando = false
	end

	local inputBegin, inputEnd

	local done = Instance.new("BindableEvent")

	inputBegin = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == tecla then
			segurando = true
		end
	end)

	inputEnd = UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == tecla then
			segurando = false
			interrompido = true
			done:Fire(false)
		end
	end)

	task.spawn(function()
		while tempoPressionado < tempoSegurar do
			if not segurando then
				break
			end
			task.wait(0.05)
			tempoPressionado += 0.05
		end
		if segurando and not interrompido then
			done:Fire(true)
		end
	end)

	local sucesso = done.Event:Wait()

	inputBegin:Disconnect()
	inputEnd:Disconnect()

	return sucesso
end

-- Hackear
buttonHackear.MouseButton1Click:Connect(function()
	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada na workspace.")
		return
	end

	local modelo = encontrarPrimeiroModel(pasta)
	if not modelo then
		warn("Nenhum modelo válido com PrimaryPart encontrado!")
		return
	end

	local posOriginal = humanoidRootPart.Position
	local destino = modelo.PrimaryPart.Position

	print("Indo até o modelo:", modelo.Name)
	humanoid:MoveTo(destino)

	local chegou = false
	local conn
	conn = humanoid.MoveToFinished:Connect(function(reached)
		chegou = true
		conn:Disconnect()
	end)
	repeat task.wait() until chegou

	-- Interface de instrução
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, 0, 0, 20)
	msg.Position = UDim2.new(0, 0, 0, 0)
	msg.BackgroundTransparency = 1
	msg.TextColor3 = Color3.new(1, 1, 0)
	msg.Text = "Segure E para hackear..."
	msg.TextScaled = true
	msg.Font = Enum.Font.SourceSansBold
	msg.Parent = frame

	local sucesso = esperarSegurarTecla(Enum.KeyCode.E, 2)

	msg:Destroy()

	if sucesso then
		print("✅ Hack concluído com sucesso!")
	else
		warn("❌ Hack cancelado! Tecla solta antes do tempo.")
	end

	-- Voltar
	humanoid:MoveTo(posOriginal)
	local voltou = false
	local conn2
	conn2 = humanoid.MoveToFinished:Connect(function()
		voltou = true
		conn2:Disconnect()
	end)
	repeat task.wait() until voltou
end)

-- Mostrar arquivos da pasta
buttonArquivos.MouseButton1Click:Connect(function()
	if not pasta then
		warn("Pasta 'RenderedMovingAnimals' não encontrada na workspace.")
		return
	end

	print("📦 Arquivos em 'RenderedMovingAnimals':")
	for _, obj in ipairs(pasta:GetChildren()) do
		print(string.format("  🔹 Nome: %s | Tipo: %s", obj.Name, obj.ClassName))
	end
end)
