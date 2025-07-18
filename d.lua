-- Palavras que podem indicar o dono de uma plot
local palavrasChave = {
    "owner", "dono", "user", "userid", "player", "name"
}

-- Função que verifica se um nome ou valor parece conter alguma palavra relacionada ao dono
local function contemPalavraChave(texto)
    texto = string.lower(tostring(texto))
    for _, chave in ipairs(palavrasChave) do
        if string.find(texto, chave) then
            return true
        end
    end
    return false
end

-- Varrer recursivamente objetos da plot procurando qualquer dado suspeito
local function varrerPlot(plot)
    local dadosEncontrados = {}

    local function buscar(obj, caminho)
        for _, filho in ipairs(obj:GetChildren()) do
            local novoCaminho = caminho .. "/" .. filho.Name

            -- Verifica nome suspeito
            if contemPalavraChave(filho.Name) then
                table.insert(dadosEncontrados, {
                    tipo = filho.ClassName,
                    nome = filho.Name,
                    caminho = novoCaminho,
                    valor = filho:IsA("ValueBase") and filho.Value or "?"
                })
            end

            -- Verifica valor suspeito
            if filho:IsA("ValueBase") then
                local valor = tostring(filho.Value)
                if contemPalavraChave(valor) then
                    table.insert(dadosEncontrados, {
                        tipo = filho.ClassName,
                        nome = filho.Name,
                        caminho = novoCaminho,
                        valor = valor
                    })
                end
            end

            -- Recursivamente
            buscar(filho, novoCaminho)
        end
    end

    buscar(plot, plot.Name)
    return dadosEncontrados
end

-- Início da varredura em todas as plots
local function varreduraCompletaDonos()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then
        warn("❌ Pasta 'Plots' não encontrada.")
        return
    end

    print("📋 Iniciando varredura completa em busca de donos nas plots...\n")

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        print("📦 Plot:", plot.Name)
        local resultados = varrerPlot(plot)

        if #resultados == 0 then
            print("❌ Nenhum dado de dono encontrado.\n")
        else
            for _, dado in ipairs(resultados) do
                print("🔎 Tipo:", dado.tipo)
                print("📍 Caminho:", dado.caminho)
                print("📄 Valor:", dado.valor)
                print("——————")
            end
            print("")
        end
    end

    print("✅ Varredura concluída.")
end

varreduraCompletaDonos()
