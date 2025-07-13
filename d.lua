local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Interface gráfica
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FolderExplorerGui"

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "Listar Pastas do Jogo"
button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16

-- Função que lista apenas pastas de nível superior
local function listarPastasSuperficiais()
	print("📂 Pastas diretamente dentro de game:")
	for _, obj in ipairs(game:GetChildren()) do
		if obj:IsA("Folder") then
			print("📁 " .. obj.Name)
		end
	end
end

-- Ação do botão
button.MouseButton1Click:Connect(function()
	listarPastasSuperficiais()
end)
