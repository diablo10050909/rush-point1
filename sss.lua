-- 완벽 ESP (모든 적 100% 표시)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_OBJECTS = {}
local SHOW_ESP = true

-- 로컬 팀 캐시 (안정적)
local LOCAL_TEAM = nil
local function updateLocalTeam()
    local success, result = pcall(function()
        return workspace.MapFolder.Players[LocalPlayer.Name].Team.Value
    end)
    LOCAL_TEAM = success and result or nil
end

updateLocalTeam() -- 초기 팀 설정

-- Drawing 객체 생성
local function createESP()
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Line")
    }
    
    -- 박스
    esp.box.Filled = false
    esp.box.Thickness = 3
    esp.box.Transparency = 1
    esp.box.Color = Color3.fromRGB(255, 0, 0)
    esp.box.Radius = 0
    
    -- 이름
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Font = 2
    esp.name.Size = 16
    esp.name.Color = Color3.fromRGB(255, 255, 255)
    esp.name.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    -- 체력바
    esp.health.Thickness = 3
    esp.health.Color = Color3.fromRGB(0, 255, 0)
    
    return esp
end

-- 월드 -> 화면
local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- ESP 업데이트 (핵심 로직)
local function updateESP(target, esp)
    local character = target
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not rootPart or not humanoid or humanoid.Health <= 0 then
        esp.box.Visible = false
        esp.name.Visible = false
        esp.health.Visible = false
        return
    end
    
    -- 팀 체크 (간단하고 확실함)
    local isEnemy = true
    local targetTeamObj = character:FindFirstChild("Team")
    if targetTeamObj and LOCAL_TEAM then
        isEnemy = targetTeamObj.Value ~= LOCAL_TEAM
    end
    
    if not isEnemy then  -- 아군이면 숨김
        esp.box.Visible = false
        esp.name.Visible = false
        esp.health.Visible = false
        return
    end
    
    -- 화면 변환
    local rootScreen, onScreen = WorldToScreen(rootPart.Position)
    if not onScreen then
        esp.box.Visible = false
        esp.name.Visible = false
        esp.health.Visible = false
        return
    end
    
    -- 머리/발 위치
    local head = character.Head
    local leg = character:FindFirstChild("LowerTorso") or character.LeftFoot
    local headScreen, _ = WorldToScreen(head.Position)
    local legScreen, _ = WorldToScreen(leg.Position)
    
    local boxHeight = math.abs(legScreen.Y - headScreen.Y)
    local boxWidth = boxHeight * 0.5
    
    -- 박스 위치/크기
    esp.box.Size = Vector2.new(boxWidth, boxHeight)
    esp.box.Position = Vector2.new(rootScreen.X - boxWidth/2, rootScreen.Y - boxHeight)
    esp.box.Visible = SHOW_ESP
    
    -- 이름
    esp.name.Text = character.Name .. " [" .. math.floor(humanoid.Health) .. "]"
    esp.name.Position = Vector2.new(rootScreen.X, rootScreen.Y - boxHeight - 25)
    esp.name.Visible = SHOW_ESP
    
    -- 체력바
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    esp.health.From = Vector2.new(rootScreen.X - boxWidth/2 - 5, rootScreen.Y - boxHeight)
    esp.health.To = Vector2.new(rootScreen.X - boxWidth/2 - 5, rootScreen.Y - boxHeight + (boxHeight * healthPercent))
    esp.health.Color = Color3.fromRGB(255 * (1-healthPercent), 255 * healthPercent, 0)
    esp.health.Visible = SHOW_ESP
end

-- 모든 플레이어 스캔 (핵심!)
local function scanAllPlayers()
    ESP_OBJECTS = {}  -- 리셋
    
    local playersFolder = workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Players")
    if playersFolder then
        for _, playerModel in pairs(playersFolder:GetChildren()) do
            if playerModel.Name ~= LocalPlayer.Name and playerModel:FindFirstChild("HumanoidRootPart") then
                local esp = createESP()
                ESP_OBJECTS[playerModel] = esp
            end
        end
    end
end

-- 메인 루프
local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
    updateLocalTeam()  -- 팀 실시간 업데이트
    
    for target, esp in pairs(ESP_OBJECTS) do
        if target.Parent then
            updateESP(target, esp)
        else
            -- 삭제된 오브젝트 정리
            for _, drawing in pairs(esp) do
                drawing:Remove()
            end
            ESP_OBJECTS[target] = nil
        end
    end
end)

-- 새 플레이어 자동 추가
workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "Players" and descendant.Parent.Name == "MapFolder" then
        wait(0.5)
        scanAllPlayers()
    end
end)

-- 토글 (Insert 키)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        SHOW_ESP = not SHOW_ESP
        print("ESP:", SHOW_ESP and "ON" or "OFF")
    end
end)

-- 초기 스캔
scanAllPlayers()

print("✅ 완벽 ESP 로드됨! (Insert로 토글)")
print("모든 적 100% 표시됩니다!")
