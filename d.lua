for _, obj in ipairs(game:GetChildren()) do
    if obj.ClassName == "Folder" then
        print("📁 " .. obj:GetFullName())
    end
end
