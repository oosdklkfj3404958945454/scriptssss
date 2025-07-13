local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Interface
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ExplorerGui"

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "Mostrar Estrutura do Jogo"
button.BackgroundColor3 = Color3.new(0.2, 0.5, 1)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16

-- Função para explorar recursivamente
local function explorar(obj, indent)
    indent = indent or ""
    print(indent .. obj:GetFullName())

    -- Se for texto (como StringValue, ou Gui com texto), mostrar conteúdo
    if obj:IsA("StringValue") then
        print(indent .. "  📄 StringValue: " .. obj.Value)
    elseif obj:IsA("TextLabel") or obj:IsA("TextBox") then
        print(indent .. "  📝 Texto: " .. obj.Text)
    elseif obj:IsA("ModuleScript") or obj:IsA("LocalScript") or obj:IsA("Script") then
        -- Tenta pegar o código
        local success, result = pcall(function()
            return obj.Source
        end)
        if success then
            print(indent .. "  📜 Código:")
            for line in result:gmatch("[^\r\n]+") do
                print(indent .. "    " .. line)
            end
        else
            print(indent .. "  ⚠️ Código inacessível.")
        end
    end

    -- Explora filhos recursivamente
    for _, child in ipairs(obj:GetChildren()) do
        explorar(child, indent .. "  ")
    end
end

-- Ao clicar no botão
button.MouseButton1Click:Connect(function()
    print("🔍 Explorando estrutura do jogo...")
    explorar(game)
end)
