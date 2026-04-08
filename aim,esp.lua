-- 완전 독립형 ESP + 부드러운 에임봇
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 설정
local AIMBOT_SETTINGS = {
    Enabled = true,
    TeamCheck = true,
    VisibleCheck = true,
    FOV = 300,  -- 시야 범위
    Smoothness = 0.12,  -- 부드러움 (0.05~0.2 추천)
    TargetPart = "Head",  -- "Head" or "HumanoidRootPart"
    TriggerKey = Enum.UserInputType.MouseButton2  -- 우클릭
}

local ESP_OBJECTS = {}
local TARGET = nil
local TOGGLES = {ESP = true, Aim = true}

-- 팀 확인
local function getLocalPlayerTeam()
    local folder = workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Players")
    local myFolder = folder and folder:FindFirstChild(LocalPlayer.Name)
    return myFolder and myFolder:FindFirstChild("Team") and myFolder.Team.Value
end

-- 거리 계산
local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- 최적 타겟 찾기
local function getBestTarget()
    local bestTarget = nil
    local shortestDistance = AIMBOT_SETTINGS.FOV
    
    local myTeam = getLocalPlayerTeam()
    
    for target, _ in pairs(ESP_OBJECTS) do
        if not target.Parent then continue end
        
        local humanoid = target:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local root = target:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        -- 팀 체크
        if AIMBOT_SETTINGS.TeamCheck then
            local targetTeam = target:FindFirstChild("Team")
            if targetTeam and targetTeam.Value == myTeam then continue end
        end
        
        -- 가시성 체크
        if AIMBOT_SETTINGS.VisibleCheck then
            local ray = workspace:Raycast(root.Position, (Camera.CFrame.Position - root.Position).Unit * 1000)
            if ray and ray.Instance:IsDescendantOf(target) == false then continue end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        
        if onScreen and distance < shortestDistance then
            shortestDistance = distance
            bestTarget = root
        end
    end
    
    return bestTarget
end

-- 부드러운 에임
local function aimAt(targetPos)
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    
    Camera.CFrame = currentCFrame:lerp(targetCFrame, AIMBOT_SETTINGS.Smoothness)
end

-- ESP (이전 코드 재사용 + 개선)
local ESP_CACHE = {}
local function createESP()
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        tracer = Drawing.new("Line"),
        fov = Drawing.new("Circle")
    }
    
    esp.box.Filled = false; esp.box.Thickness = 2; esp.box.Color = Color3.fromRGB(255,255,255)
    esp.name.Center = true; esp.name.Outline = true; esp.name.Font = 2; esp.name.Size = 14
    esp.name.Color = Color3.fromRGB(255,255,255); esp.name.OutlineColor = Color3.fromRGB(0,0,0)
    esp.tracer.Thickness = 1; esp.tracer.Color = Color3.fromRGB(255,255,255)
    
    esp.fov.Visible = false; esp.fov.Radius = AIMBOT_SETTINGS.FOV; esp.fov.Color = Color3.fromRGB(255,0,0)
    esp.fov.Filled = false; esp.fov.Thickness = 2; esp.fov.NumSides = 30; esp.fov.Transparency = 0.5
    
    return esp
end

-- 메인 루프
RunService.Heartbeat:Connect(function()
    -- FOV 원
    local fov = ESP_CACHE.fov
    if fov then
        fov.Position = Vector2.new(Mouse.X, Mouse.Y)
        fov.Visible = AIMBOT_SETTINGS.Enabled
    end
    
    -- 타겟 찾기
    if AIMBOT_SETTINGS.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local bestTarget = getBestTarget()
        if bestTarget then
            local targetPos = bestTarget.Position
            if AIMBOT_SETTINGS.TargetPart == "Head" then
                local head = bestTarget.Parent:FindFirstChild("Head")
                targetPos = head and head.Position or bestTarget.Position
            end
            aimAt(targetPos)
        end
    end
    
    -- ESP 업데이트
    if TOGGLES.ESP then
        local myTeam = getLocalPlayerTeam()
        for target, data in pairs(ESP_OBJECTS) do
            if target.Parent then
                local esp = data.esp
                local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("HitBox")
                if root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        -- 박스/이름/트레이서 (간략화)
                        local height = 100
                        local width = 40
                        esp.box.Size = Vector2.new(width, height)
                        esp.box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height)
                        esp.box.Visible = true
                        
                        esp.name.Text = target.Name
                        esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - height - 20)
                        esp.name.Visible = true
                        
                        esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.tracer.To = screenPos
                        esp.tracer.Visible = true
                        
                        -- 색상
                        local color = Color3.fromRGB(0, 162, 255)
                        if target:FindFirstChild("Team") and myTeam ~= target.Team.Value then
                            color = Color3.fromRGB(255, 0, 0)
                        end
                        esp.box.Color = color
                        esp.name.Color = color
                        esp.tracer.Color = color
                    else
                        for _, obj in pairs(esp) do obj.Visible = false end
                    end
                end
            end
        end
    end
end)

-- 타겟 초기화 (플레이어 + 무기)
local function initTargets()
    local function scanFolder(folder)
        if folder then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
                    ESP_OBJECTS[obj] = {esp = createESP()}
                end
            end
        end
    end
    
    scanFolder(workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Players"))
    scanFolder(workspace:FindFirstChild("DroppedWeapons"))
end

initTargets()

-- 동적 타겟 추가
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        wait(0.1)
        if obj.Parent == workspace.DroppedWeapons or 
           (obj.Parent.Name == "Players" and obj.Parent.Parent.Name == "MapFolder" and obj.Name ~= LocalPlayer.Name) then
            ESP_OBJECTS[obj] = {esp = createESP()}
        end
    end
end)

-- 토글 (F1: 에임봇, F2: ESP, F3: FOV)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then AIMBOT_SETTINGS.Enabled = not AIMBOT_SETTINGS.Enabled end
    if input.KeyCode == Enum.KeyCode.F2 then TOGGLES.ESP = not TOGGLES.ESP end
    if input.KeyCode == Enum.KeyCode.F3 then 
        AIMBOT_SETTINGS.FOV = AIMBOT_SETTINGS.FOV == 300 and 500 or 300 
        ESP_CACHE.fov.Radius = AIMBOT_SETTINGS.FOV
    end
end)

-- FOV 저장
ESP_CACHE.fov = Drawing.new("Circle")
ESP_CACHE.fov.Position = Vector2.new(Mouse.X, Mouse.Y)
ESP_CACHE.fov.Radius = AIMBOT_SETTINGS.FOV

print("🚀 ESP + 에임봇 로드됨!")
print("F1: 에임봇 토글 | F2: ESP 토글 | F3: FOV 변경 | 우클릭: 에임")
