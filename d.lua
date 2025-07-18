-- Palavras suspeitas a serem detectadas
local palavrasChave = {
    "owner", "dono", "brainrot", "admin", "hack", "exploit", "player"
}

-- Função para verificar se um texto contém palavras suspeitas
local function contemPalavraChave(texto)
    texto = string.lower(tostring(texto))
    for _, chave in ipairs(palavrasChave) do
        if string.find(texto, chave) then
            return true
        end
    end
    return false
end

-- Função principal
local function verificarDisplayNames()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then
        warn("❌ Pasta 'Plots' não encontrada.")
        return
    end

    print("📁 Iniciando varredura dos DisplayNames dentro dos plots...\n")

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local podiumsFolder = plot:FindFirstChild("AnimalPodiums")
        if podiumsFolder then
            for _, pod in ipairs(podiumsFolder:GetChildren()) do
                local caminho = pod:FindFirstChild("Base")
                if caminho then
                    local spawn = caminho:FindFirstChild("Spawn")
                    if spawn then
                        local attachment = spawn:FindFirstChild("Attachment")
                        if attachment then
                            local overhead = attachment:FindFirstChild("AnimalOverhead")
                            if overhead then
                                local displayName = overhead:FindFirstChild("DisplayName")
                                if displayName then
                                    local valor = nil
                                    if displayName:IsA("StringValue") then
                                        valor = displayName.Value
                                    elseif displayName:IsA("TextLabel") or displayName:IsA("TextBox") or displayName:IsA("TextButton") then
                                        valor = displayName.Text
                                    end

                                    local caminhoCompleto = plot.Name .. "/" .. pod.Name .. "/Base/Spawn/Attachment/AnimalOverhead/DisplayName"
                                    print("🔍 Encontrado:", caminhoCompleto)
                                    if valor then
                                        print("📄 Valor:", valor)
                                        if contemPalavraChave(valor) then
                                            warn("⚠️ Valor suspeito em", caminhoCompleto, "→", valor)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    print("\n✅ Varredura concluída.")
end

verificarDisplayNames()
