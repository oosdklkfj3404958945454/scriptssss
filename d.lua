-- Script estilo exploit: detecta qualquer modelo próximo ao jogador
-- mesmo sem PrimaryPart, e loga ao segurar a tecla "E"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local hrp = player.Character or player.CharacterAdded:Wait()
hrp = hrp:WaitForChild("HumanoidRootPart")

local tecla = Enum.KeyCode.E
local raio = 15
local segurando = false
local tempoInicio = 0

-- Função que calcula posição média dos parts de um modelo
local function getPosicaoMedia(modelo)
	local soma = Vector3.new(0, 0, 0)
	local total = 0

	for _, part in ipairs(modelo:GetDescendants()) do
		if part:IsA("BasePart") then
			soma += part.Position
			total += 1
		end
	end

	if total > 0 then
		return soma / total
	end
	return nil
end

-- Retorna o modelo mais próximo (sem precisar de PrimaryPart)
local function modeloMaisProximo()
	local maisPerto = nil
	local menorDist = raio

	for _, modelo in ipairs(workspace:GetDescendants()) do
		if modelo:IsA("Model") then
			local pos = getPosicaoMedia(modelo)
			if pos then
				local dist = (hrp.Position - pos).Magnitude
				if dist < menorDist then
					menorDist = dist
					maisPerto = modelo
				end
			end
		end
	end

	return maisPerto, menorDist
end

-- Tecla pressionada
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or input.KeyCode ~= tecla then return end
	segurando = true
	tempoInicio = tick()
end)

-- Tecla solta
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode ~= tecla or not segurando then return end
	segurando = false

	local duracao = tick() - tempoInicio
	local modelo, dist = modeloMaisProximo()

	if modelo then
		warn("[✔] Tecla 'E' segurada por " .. string.format("%.2f", duracao) ..
			"s perto do modelo: " .. modelo:GetFullName() .. " (distância: " .. math.floor(dist) .. ")")
	else
		warn("[✖] Nenhum modelo próximo. Tecla 'E' segurada por " .. string.format("%.2f", duracao) .. "s")
	end
end)
