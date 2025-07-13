local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Interface simples
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FolderExplorerGui"

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "Mostrar Pastas"
button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16

-- Função para listar pastas recursivamente
local function listarPastas(obj, indent)
	indent = indent or ""
	if obj:IsA("Folder") then
		print(indent .. "📁 " .. obj:GetFullName())
	end

	for _, child in ipairs(obj:GetChildren()) do
		listarPastas(child, indent .. "  ")
	end
end

-- Ação ao clicar no botão
button.MouseButton1Click:Connect(function()
	print("🔍 Listando todas as pastas...")
	listarPastas(game)
end)
