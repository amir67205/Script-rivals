-- Servicios necesarios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuración del Aimbot
local AimbotEnabled = true
local AimKey = Enum.UserInputType.MouseButton2 -- Click derecho del ratón
local Sensitivity = 0.25 -- Suavizado de movimiento (menor = más rápido, mayor = más suave)

-- Función para encontrar al jugador enemigo más cercano al centro de la pantalla
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            
            -- Opcional: Verificar equipo (Team Check) si el juego usa equipos
            local sameTeam = false
            if localPlayer.Team and player.Team and localPlayer.Team == player.Team then
                sameTeam = true
            end

            if head and not sameTeam then
                -- Convertir la posición 3D de la cabeza a coordenadas en pantalla 2D
                local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Calcular la distancia desde el centro de la pantalla hasta la cabeza del jugador
                    local mouseLocation = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude

                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = character
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Bucle principal que ejecuta el aimbot en cada fotograma
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end

    -- Comprueba si se está presionando la tecla asignada (Click Derecho)
    if UserInputService:IsMouseButtonPressed(AimKey) then
        local targetCharacter = getClosestPlayer()
        
        if targetCharacter and targetCharacter:FindFirstChild("Head") then
            local targetHead = targetCharacter.Head
            
            -- Obtener la orientación actual de la cámara y calcular la rotación hacia la cabeza
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetHead.Position)
            
            -- Aplicar el movimiento con suavizado (Lerp)
            camera.CFrame = currentCFrame:Lerp(targetCFrame, Sensitivity)
        end
    end
end)
