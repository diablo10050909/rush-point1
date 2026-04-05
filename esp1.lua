-- Xeno 호환 RUSH POINT ESP (2026 최신 버전)
-- gethui/getgenv 우회 + error handling 추가

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().ESP_ENABLED = getgenv().ESP_ENABLED or true
local ESPObjects = {}

-- 안전한 GUI 생성 함수 (Xeno 호환)
local function createBillboardESP(player)
    pcall(function()
        if player == LocalPlayer or ESPObjects[player] then return end
        
        local char = player.Character or player.CharacterAdded:Wait()
        local head = char:WaitForChild("Head", 5)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        
        if not head or not root then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RUSH_ESP_" .. player.Name
        billboard.Parent = head
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 250, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        
        -- 박스 프레임
        local box = Instance.new("Frame")
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 2
        box.BorderColor3 = Color3.fromRGB(255, 0, 0)
        box.Parent = billboard
        
        -- 코너 라인 (더 선명한 박스)
        for i = 1, 4 do
            local line = Instance.new("Frame")
            line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            line.BorderSizePixel = 0
            line.Parent = box
            if i == 1 then
                line.Size = UDim2.new(0, 3, 0, 20)
                line.Position = UDim2.new(0, 0, 0, 0)
            elseif i == 2 then
                line.Size = UDim2.new(0, 20, 0, 3)
                line.Position = UDim2.new(1, -20, 0, 0)
            elseif i == 3 then
                line.Size = UDim2.new(0, 3, 0, 20)
                line.Position = UDim2.new(1, -3, 1, -20)
            else
                line.Size = UDim2.new(0, 20, 0, 3)
                line.Position = UDim2.new(0, 0, 1, -3)
            end
        end
        
        -- 이름
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.Parent = box
        
        -- 거리 + HP
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0.65, 0)
        infoLabel.Position = UDim2.new(0, 0, 0.35, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "0m | 100HP"
        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        infoLabel.TextStrokeTransparency = 0
        infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 13
        infoLabel.Parent = box
        
        ESPObjects[player] = {
            billboard = billboard,
            infoLabel = infoLabel,
            root = root,
            humanoid = humanoid
        }
    end)
end

-- 3D 박스 ESP (추가 안티치트 우회)
local function createBoxESP(player)
    pcall(function()
        local char = player.Character
        if not char or char:FindFirstChild("ESPBox") then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = root
        box.Size = Vector3.new(4.5, 7, 1.5)
        box.Color3 = Color3.fromRGB(255, 50, 50)
        box.Transparency = 0.7
        box.AlwaysOnTop = true
        box.ZIndex = 0
        box.Parent = root
    end)
end

-- 업데이트 루프
local updateConnection
local function startUpdateLoop()
    if updateConnection then updateConnection:Disconnect() end
    
    updateConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().ESP_ENABLED then return end
        
        for player, data in pairs(ESPObjects) do
            pcall(function()
                if not player.Parent or not player.Character or not data.root then
                    if data.billboard then data.billboard:Destroy() end
                    ESPObjects[player] = nil
                    return
                end
                
                local rootPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not rootPos then return end
                
                local distance = (rootPos.Position - data.root.Position).Magnitude
                local health = data.humanoid.Health
                local maxHealth = data.humanoid.MaxHealth
                
                data.infoLabel.Text = math.floor(distance) .. "m | " .. math.floor(health) .. "HP"
                
                -- 색상 변경 (저HP 빨강)
                if health / maxHealth < 0.3 then
                    data.infoLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                else
                    data.infoLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                end
                
                data.billboard.Enabled = distance < 3000
            end)
        end
    end)
end

-- 초기화
local function init()
    print("🚀 RUSH POINT ESP 초기화 중...")
    
    -- 기존 ESP 정리
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("RUSH_ESP_") or obj.Name == "ESPBox" then
            obj:Destroy()
        end
    end
    
    -- 모든 플레이어 적용
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            spawn(function()
                createBillboardESP(player)
                createBoxESP(player)
            end)
        end
    end
    
    -- 새 플레이어 감지
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(2)
            createBillboardESP(player)
            createBoxESP(player)
        end)
    end)
    
    startUpdateLoop()
    print("✅ ESP 활성화 완료! INSERT로 토글")
end

-- 토글 핫키
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        getgenv().ESP_ENABLED = not getgenv().ESP_ENABLED
        print("ESP 토글:", getgenv().ESP_ENABLED and "ON" or "OFF")
    end
end)

-- 실행
pcall(init)
