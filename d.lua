local function listarPastas(obj, indent)
    indent = indent or ""
    if obj:IsA("Folder") then
        print(indent .. "📁 " .. obj:GetFullName())
    end

    for _, child in ipairs(obj:GetChildren()) do
        listarPastas(child, indent .. "  ")
    end
end

-- Começa a busca a partir do Workspace
print("🔍 Listando todas as pastas no Workspace...")
listarPastas(game.Workspace)
