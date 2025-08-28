local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local KEY = rawget(_G, "script_key") or getgenv().script_key or script_key
local FIREBASE_KEY_URL = "https://codenova-f5457-default-rtdb.firebaseio.com/mobile.json"
local FIREBASE_JOB_URL = "https://codenova-f5457-default-rtdb.firebaseio.com/ccc.json"

local function prints(str)
    print("[KeySystem]: " .. str)
end

if not KEY or KEY == "" then
    prints("❌ Defina a variável script_key antes de executar o script!")
    return
end

local function parseKeyData(data)
    -- data = { ["key"] = "2025-09-23T23:57:56.580Z,nick1,nick2" }
    for k, v in pairs(data) do
        if k == KEY then
            local parts = {}
            for part in string.gmatch(v, "([^,]+)") do
                table.insert(parts, part)
            end
            local expires = parts[1]
            table.remove(parts, 1)
            local nicks = parts
            return expires, nicks
        end
    end
    return nil, nil
end

local function isExpired(isoDate)
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):([%d%.]+)Z"
    local y, m, d, h, min, s = isoDate:match(pattern)
    if not y then return true end
    local now = os.time(os.date("!*t"))
    local exp = os.time({
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(h),
        min = tonumber(min),
        sec = math.floor(tonumber(s)),
    })
    return now > exp
end

local function checkKey()
    local success, response = pcall(function()
        return game:HttpGet(FIREBASE_KEY_URL)
    end)
    if not success or not response then
        prints("❌ Erro ao acessar o banco de dados de keys.")
        warn("[KeySystem][Erro HttpGet Key]:", response)
        return false
    end

    prints("[Depuração][KeySystem] Conteúdo bruto do Firebase (mobile.json):\n" .. tostring(response))

    local successDecode, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not successDecode or not data then
        prints("❌ Erro ao decodificar dados de keys.")
        warn("[KeySystem][Erro JSONDecode Key]:", data)
        return false
    end

    local expires, nicks = parseKeyData(data)
    if not expires then
        prints("❌ Key inválida ou não encontrada.")
        prints("[Depuração][KeySystem] Dados decodificados (mobile.json):")
        warn(data)
        return false
    end

    if isExpired(expires) then
        prints("❌ Key expirada! Validade: " .. expires)
        return false
    end

    local found = false
    for _, nick in ipairs(nicks) do
        if nick:lower() == LocalPlayer.Name:lower() then
            found = true
            break
        end
    end

    if found then
        prints("✅ Key válida e nick autorizado!")
        return true
    else
        prints("⚠️ Key válida, mas seu nick NÃO está autorizado!")
        prints("[Depuração][KeySystem] Lista de nicks autorizados para a key: " .. table.concat(nicks, ", "))
        return false
    end
end

local function readJobID()
    local success, response = pcall(function()
        return game:HttpGet(FIREBASE_JOB_URL)
    end)

    if not success or not response then
        prints("❌ Erro ao buscar JobID do site.")
        warn("[KeySystem][Erro HttpGet JobID]:", response)
        return nil
    end

    prints("[Depuração][KeySystem] Conteúdo bruto do Firebase (ccc.json):\n" .. tostring(response))

    local successDecode, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not successDecode or not data then
        prints("❌ Erro ao decodificar dados do JobID.")
        warn("[KeySystem][Erro JSONDecode JobID]:", data)
        return nil
    end

    -- Se for string pura, retorna direto
    if typeof(data) == "string" and data ~= "" then
        local jobID = data:gsub("%s+", "")
        prints("🔎 JobID encontrado: " .. jobID)
        return jobID
    end

    -- Se for objeto, busca o campo job_id
    if typeof(data) == "table" and data.job_id and data.job_id ~= "" then
        local jobID = data.job_id:gsub("%s+", "")
        prints("🔎 JobID encontrado: " .. jobID)
        return jobID
    end

    prints("❌ JobID não encontrado no site.")
    prints("[Depuração][KeySystem] Dados decodificados (ccc.json):")
    warn(data)
    return nil
end

-- Função para encontrar a ScreenGui com o campo "Job-ID Input"
local function findTargetGui()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end
        for _, descendant in ipairs(gui:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Text == "Job-ID Input" then
                return descendant:FindFirstAncestorOfClass("ScreenGui")
            end
        end
    end
    return nil
end

-- Função para preencher o campo de texto do JobID
local function setJobIDText(targetGui, text)
    for _, btn in ipairs(targetGui:GetDescendants()) do
        if btn:IsA("TextButton") then
            local frames = {}
            for _, child in ipairs(btn:GetChildren()) do
                if child:IsA("Frame") then
                    table.insert(frames, child)
                end
            end
            if #frames < 2 then continue end

            local foundLabel = false
            for _, descendant in ipairs(frames[1]:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Text == "Job-ID Input" then
                    foundLabel = true
                    break
                end
            end
            if not foundLabel then continue end

            for _, subFrame in ipairs(frames[2]:GetChildren()) do
                if subFrame:IsA("Frame") then
                    for _, obj in ipairs(subFrame:GetDescendants()) do
                        if obj:IsA("TextBox") then
                            obj.Text = text
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Função para clicar no botão "Join Job-ID"
local function clickJoinButton(targetGui)
    for _, btn in ipairs(targetGui:GetDescendants()) do
        if btn:IsA("TextButton") then
            for _, content in ipairs(btn:GetDescendants()) do
                if content:IsA("TextLabel") and content.Text == "Join Job-ID" then
                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                        conn:Fire()
                    end
                    prints("✅ Teleport solicitado para novo JobID.")
                    return true
                end
            end
        end
    end
    return false
end

-- Execução principal em loop
task.spawn(function()
    while true do
        if checkKey() then
            local jobID = readJobID()
            if jobID then
                local gui = findTargetGui()
                if gui then
                    if setJobIDText(gui, jobID) then
                        wait(0.1)
                        clickJoinButton(gui)
                    else
                        prints("❌ Não foi possível preencher o campo de JobID.")
                    end
                else
                    prints("❌ Interface de JobID não encontrada.")
                end
            end
        end
        wait(2) -- Aguarda 2 segundos antes de tentar novamente (ajuste se quiser)
    end
end)
