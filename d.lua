local folder = game.Workspace:FindFirstChild("MovingAnimals")

if not folder then
    warn("❌ Pasta 'MovingAnimals' não encontrada no Workspace.")
    return
end

local textoDetectado = {}
local estruturaDetectada = {}

-- Função para processar recursivamente
local function processar(obj, indent)
    indent = indent or ""

    -- Captura texto, se aplicável
    if obj:IsA("StringValue") then
        table.insert(textoDetectado, indent .. "📝 StringValue [" .. obj.Name .. "]: " .. obj.Value)

    elseif obj:IsA("TextLabel") or obj:IsA("TextBox") then
        table.insert(textoDetectado, indent .. "📝 GUI [" .. obj.ClassName .. " - " .. obj.Name .. "]: " .. obj.Text)

    elseif obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
        local success, src = pcall(function()
            return obj.Source
        end)
        if success then
            table.insert(textoDetectado, indent .. "📜 " .. obj.ClassName .. " [" .. obj.Name .. "]:")
            for line in src:gmatch("[^\r\n]+") do
                table.insert(textoDetectado, indent .. "    " .. line)
            end
        else
            table.insert(textoDetectado, indent .. "⚠️ " .. obj.Name .. ": código inacessível")
        end
    end

    -- Registra estrutura
    table.insert(estruturaDetectada, indent .. "📦 " .. obj:GetFullName())

    -- Processa filhos
    for _, child in ipairs(obj:GetChildren()) do
        processar(child, indent .. "  ")
    end
end

-- Executa
print("🔍 Verificando conteúdo da pasta 'MovingAnimals'...")

processar(folder)

-- Primeiro mostra textos
print("===== 📄 CONTEÚDO DE TEXTO DETECTADO =====")
for _, linha in ipairs(textoDetectado) do
    print(linha)
end

-- Depois mostra estrutura
print("===== 🗂️ ESTRUTURA DA PASTA =====")
for _, linha in ipairs(estruturaDetectada) do
    print(linha)
end
