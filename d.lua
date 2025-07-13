local services = {
    game.ReplicatedStorage,
    game.ServerStorage,
    game.ServerScriptService,
    game.Workspace,
    game.StarterGui,
    game.Players
}

for _, service in ipairs(services) do
    for _, obj in ipairs(service:GetChildren()) do
        if obj:IsA("Folder") then
            print("📁 " .. obj:GetFullName())
        end
    end
end
