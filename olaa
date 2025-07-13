local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui")
gui.Name = "RenderSpyGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 20)
button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 20
button.Text = "Hackear Animal"
button.Parent = frame

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

button.MouseButton1Click:Connect(function()
	local modelo = encontrarPrimeiroModel(pasta)
	local scriptAlvo = encontrarPrimeiroScript(pasta)

	if not modelo or not scriptAlvo then
		warn("Nenhum modelo ou script válido encontrado!")
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
