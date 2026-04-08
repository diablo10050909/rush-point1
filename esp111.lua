-- 완전 독립형 ESP (2026 최신 버전)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_OBJECTS = {}
local TOGGLES = {Players = true, Weapons = true}

-- 팀 확인 함수
local function getLocalPlayerTeam()
    local folder = workspace:FindFirstChild("MapFolder")
    if not folder then return nil end
    local playerFolder = folder:FindFirstChild("Players")
    if not playerFolder then return nil end
    local myFolder = playerFolder:FindFirstChild(LocalPlayer.Name)
    return myFolder and myFolder:FindFirstChild("Team") and myFolder.Team.Value
end

-- 화면 좌표 변환
local function WorldToScreen(pos)
    local screen, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screen.X, screen.Y), onScreen
end

-- ESP 박스 생성
local function createESP()
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        tracer = Drawing.new("Line")
    }
    
    esp.box.Filled = false
    esp.box.Thickness = 2
    esp.box.Transparency = 1
    esp.box.Color = Color3.fromRGB(255, 255, 255)
    esp.box.Radius = 0
    
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Font = 2
    esp.name.Size = 14
    esp.name.Color = Color3.fromRGB(255, 255, 255)
    esp.name.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    esp.tracer.Thickness = 1
    esp.tracer.Color = Color3.fromRGB(255, 255, 255)
    esp.tracer.Transparency = 0.7
    
    return esp
end

-- ESP 업데이트
local function updateESP(target, esp)
    if not target.Parent then 
        for _, obj in pairs(esp) do obj.Visible = false end
        return 
    end
    
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("HitBox")
    if not root then return end
    
    local humanoid = target:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then return end
    
    local screenPos, onScreen = WorldToScreen(root.Position)
    if not onScreen then 
        for _, obj in pairs(esp) do obj.Visible = false end
        return 
    end
    
    -- 박스 사이즈 계산
    local head = target:FindFirstChild("Head")
    local foot = target:FindFirstChild("LowerTorso") or target:FindFirstChild("LeftFoot")
    
    if head and foot then
        local headPos, _ = WorldToScreen(head.Position)
        local footPos, _ = WorldToScreen(foot.Position)
        
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height * 0.4
        
        esp.box.Size = Vector2.new(width, height)
        esp.box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height)
        esp.box.Visible = true
    end
    
    -- 이름
    esp.name.Text = target.Name
    esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
    esp.name.Visible = true
    
    -- 트레이서
    esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    esp.tracer.To = screenPos
    esp.tracer.Visible = true
    
    -- 색상 설정 (플레이어일 때)
    if target:FindFirstChild("Team") then
        local myTeam = getLocalPlayerTeam()
        local theirTeam = target.Team.Value
        if myTeam and theirTeam ~= myTeam then
            esp.box.Color = Color3.fromRGB(255, 0, 0)  -- 적: 빨강
            esp.name.Color = Color3.fromRGB(255, 0, 0)
            esp.tracer.Color = Color3.fromRGB(255, 0, 0)
        else
            esp.box.Color = Color3.fromRGB(0, 255, 0)  -- 아군: 초록
            esp.name.Color = Color3.fromRGB(0, 255, 0)
            esp.tracer.Color = Color3.fromRGB(0, 255, 0)
        end
    else
        esp.box.Color = Color3.fromRGB(0, 162, 255)  -- 무기: 파랑
        esp.name.Color = Color3.fromRGB(0, 162, 255)
        esp.tracer.Color = Color3.fromRGB(0, 162, 255)
    end
end

-- 새 타겟 추가
local function addTarget(target)
    if ESP_OBJECTS[target] then return end
    
    local esp = createESP()
    ESP_OBJECTS[target] = {esp = esp, connection = nil}
    
    local connection = RunService.Heartbeat:Connect(function()
        if TOGGLES.Weapons or target:FindFirstChild("Team") then
            updateESP(target, esp)
        else
            for _, obj in pairs(esp) do obj.Visible = false end
        end
    end)
    
    ESP_OBJECTS[target].connection = connection
end

-- 초기 타겟 추가
local function initTargets()
    -- 플레이어
    local playersFolder = workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Players")
    if playersFolder then
        for _, player in pairs(playersFolder:GetChildren()) do
            if player.Name ~= LocalPlayer.Name then
                addTarget(player)
            end
        end
    end
    
    -- 무기
    local weaponsFolder = workspace:FindFirstChild("DroppedWeapons")
    if weaponsFolder then
        for _, weapon in pairs(weaponsFolder:GetChildren()) do
            addTarget(weapon)
        end
    end
end

-- 동적 추가 감지
workspace.ChildAdded:Connect(function(child)
    wait(0.1) -- 약간의 딜레이
    if child.Name == "DroppedWeapons" or child.Name == "MapFolder" then
        initTargets()
    elseif child.Parent == workspace.DroppedWeapons or 
           (child.Parent == workspace.MapFolder.Players and child.Name ~= LocalPlayer.Name) then
        addTarget(child)
    end
end)

-- 시작
initTargets()

-- 토글 명령어 (채팅으로 /esp players /esp weapons /esp off)
Players.LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "/esp players" then TOGGLES.Players = not TOGGLES.Players end
    if msg == "/esp weapons" then TOGGLES.Weapons = not TOGGLES.Weapons end
    if msg == "/esp off" then 
        TOGGLES.Players = false 
        TOGGLES.Weapons = false 
    end
    if msg == "/esp on" then 
        TOGGLES.Players = true 
        TOGGLES.Weapons = true 
    end
end)

print("ESP 로드됨! /esp players, /esp weapons, /esp on, /esp off")
