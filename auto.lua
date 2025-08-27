local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local KEY = rawget(_G, "script_key") or getgenv().script_key or script_key
local FIREBASE_URL = "https://codenova-f5457-default-rtdb.firebaseio.com/mobile.json"

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
        return game:HttpGet(FIREBASE_URL)
    end)
    if not success or not response then
        prints("❌ Erro ao acessar o banco de dados.")
        return
    end

    local successDecode, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not successDecode or not data then
        prints("❌ Erro ao decodificar dados.")
        return
    end

    local expires, nicks = parseKeyData(data)
    if not expires then
        prints("❌ Key inválida ou não encontrada.")
        return
    end

    if isExpired(expires) then
        prints("❌ Key expirada! Validade: " .. expires)
        return
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
    else
        prints("⚠️ Key válida, mas seu nick NÃO está autorizado!")
    end
end

checkKey()
