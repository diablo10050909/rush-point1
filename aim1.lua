-- 개선된 AimLock (교육용 / 개인 테스트 전용)
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 설정
local FOV_SIZE = 150            -- 원형 FOV 지름 (픽셀)
local LOCK_KEY = Enum.KeyCode.Q -- 잠금 토글 키

-- 부모 GUI 준비
local gui = player:WaitForChild("PlayerGui")
local screenGui = gui:FindFirstChild("__AimLockGui") or Instance.new("ScreenGui")
screenGui.Name = "__AimLockGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = gui

-- FOV 원형 (UI)
local fovFrame = screenGui:FindFirstChild("FOVCircle") or Instance.new("Frame")
fovFrame.Name = "FOVCircle"
fovFrame.Size = UDim2.new(0, FOV_SIZE, 0, FOV_SIZE)
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0.5, 0.5, 0) -- 화면 중앙
fovFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fovFrame.BackgroundTransparency = 0.6
fovFrame.BorderSizePixel = 0
fovFrame.Parent = screenGui

local uiCorner = fovFrame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = fovFrame

local isLockedOn = false
local targetPart = nil

-- helper: 화면 좌표가 FOV 내인지 체크
local function isInFOV(worldPos)
    local screenPos, onScreen = camera:WorldToScreenPoint(worldPos)
    if not onScreen then return false end
    local circleCenter = Vector2.new(
        fovFrame.AbsolutePosition.X + fovFrame.AbsoluteSize.X / 2,
        fovFrame.AbsolutePosition.Y + fovFrame.AbsoluteSize.Y / 2
    )
    local distance = (Vector2.new(screenPos.X, screenPos.Y) - circleCenter).Magnitude
    return distance <= fovFrame.AbsoluteSize.X / 2
end

-- target 찾기 (workspace의 MapFolder -> Players 구조를 그대로 사용)
local function findHeadTarget()
    local mapFolder = workspace:FindFirstChild("MapFolder")
    if not mapFolder then return nil end
    local playersFolder = mapFolder:FindFirstChild("Players")
    if not playersFolder then return nil end

    local closestHead = nil
    local closestDist = math.huge

    -- 직접 자식 모델들만 순회
    for _, model in pairs(playersFolder:GetChildren()) do
        if model and model:IsA("Model") then
            local head = model:FindFirstChild("Head")
            local humanoid = model:FindFirstChildWhichIsA("Humanoid")
            if head and head:IsA("BasePart") and humanoid and humanoid.Health > 0 then
                -- 자기 자신 모델이면 제외 (모델 이름 또는 토대 구조에 따라 조정 가능)
                if model:FindFirstChild("Humanoid") and model ~= player.Character then
                    if isInFOV(head.Position) then
                        local screenPos = camera:WorldToScreenPoint(head.Position)
                        local circleCenter = Vector2.new(
                            fovFrame.AbsolutePosition.X + fovFrame.AbsoluteSize.X / 2,
                            fovFrame.AbsolutePosition.Y + fovFrame.AbsoluteSize.Y / 2
                        )
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - circleCenter).Magnitude
                        if dist < closestDist then
                            closestHead = head
                            closestDist = dist
                        end
                    end
                end
            end
        end
    end

    return closestHead
end

-- 키 입력: Q로 토글
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == LOCK_KEY then
        if not isLockedOn then
            local found = findHeadTarget()
            if found then
                targetPart = found
                isLockedOn = true
                print("Locked on to: " .. (targetPart and targetPart:GetFullName() or "nil"))
            else
                print("No valid target found in FOV.")
            end
        else
            isLockedOn = false
            targetPart = nil
            print("Unlocked.")
        end
    end
end)

-- 매 프레임 카메라 보정 (주의: 탐지 가능)
game:GetService("RunService").RenderStepped:Connect(function()
    if isLockedOn and targetPart and targetPart.Parent then
        if isInFOV(targetPart.Position) then
            local camCF = camera.CFrame
            local look = (targetPart.Position - camCF.Position).Unit
            camera.CFrame = CFrame.new(camCF.Position, camCF.Position + look)
        else
            -- 대상이 FOV를 벗어나면 해제
            isLockedOn = false
            targetPart = nil
            print("Target left FOV — Unlocked")
        end
    end
end)
