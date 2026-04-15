-- 🚀 완전한 TP + Credit + Layer 최상단 + Ctrl+Q 토글 + Ctrl+우클릭 지형TP
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local HACKS_ENABLED = true
local LAYER_ZINDEX = 999999
local TARGET_POSITION = Vector3.new(0, 10, 0)
local SETTING_TARGET = false

-- UI 생성 (최상단 레이어)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateHackGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 메인 프레임
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 320)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = LAYER_ZINDEX
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- 제목 (실시간 위치 표시)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🚀 HACKS v3.0 | 0, 0, 0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.ZIndex = LAYER_ZINDEX + 1
Title.Parent = MainFrame

-- TP 섹션
local TPFrame = Instance.new("Frame")
TPFrame.Size = UDim2.new(1, -20, 0, 110)
TPFrame.Position = UDim2.new(0, 10, 0, 60)
TPFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TPFrame.ZIndex = LAYER_ZINDEX
TPFrame.Parent = MainFrame

local TPCorner = Instance.new("UICorner")
TPCorner.CornerRadius = UDim.new(0, 10)
TPCorner.Parent = TPFrame

local TPTitle = Instance.new("TextLabel")
TPTitle.Size = UDim2.new(1, 0, 0, 25)
TPTitle.BackgroundTransparency = 1
TPTitle.Text = "📍 순간이동 (Ctrl+우클릭)"
TPTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
TPTitle.TextScaled = true
TPTitle.Font = Enum.Font.GothamBold
TPTitle.ZIndex = LAYER_ZINDEX + 1
TPTitle.Parent = TPFrame

local TPInput = Instance.new("TextBox")
TPInput.Size = UDim2.new(1, -70, 0, 35)
TPInput.Position = UDim2.new(0, 10, 0, 30)
TPInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
TPInput.Text = "0, 10, 0"
TPInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TPInput.PlaceholderText = "좌표 자동 설정됨"
TPInput.TextScaled = true
TPInput.Font = Enum.Font.Gotham
TPInput.ZIndex = LAYER_ZINDEX + 1
TPInput.Parent = TPFrame

local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(0, 60, 0, 35)
TPButton.Position = UDim2.new(1, -70, 0, 30)
TPButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TPButton.Text = "TP!"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.TextScaled = true
TPButton.Font = Enum.Font.GothamBold
TPButton.ZIndex = LAYER_ZINDEX + 1
TPButton.Parent = TPFrame

-- 크레딧 섹션
local CreditFrame = Instance.new("Frame")
CreditFrame.Size = UDim2.new(1, -20, 0, 90)
CreditFrame.Position = UDim2.new(0, 10, 0, 180)
CreditFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CreditFrame.ZIndex = LAYER_ZINDEX
CreditFrame.Parent = MainFrame

local CreditCorner = Instance.new("UICorner")
CreditCorner.CornerRadius = UDim.new(0, 10)
CreditCorner.Parent = CreditFrame

local CreditTitle = Instance.new("TextLabel")
CreditTitle.Size = UDim2.new(1, 0, 0, 25)
CreditTitle.BackgroundTransparency = 1
CreditTitle.Text = "💰 크레딧 변경"
CreditTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
CreditTitle.TextScaled = true
CreditTitle.Font = Enum.Font.GothamBold
CreditTitle.ZIndex = LAYER_ZINDEX + 1
CreditTitle.Parent = CreditFrame

local CreditInput = Instance.new("TextBox")
CreditInput.Size = UDim2.new(0.65, 0, 0, 35)
CreditInput.Position = UDim2.new(0, 10, 0, 30)
CreditInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
CreditInput.Text = "999999"
CreditInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditInput.PlaceholderText = "금액 입력"
CreditInput.TextScaled = true
CreditInput.Font = Enum.Font.Gotham
CreditInput.ZIndex = LAYER_ZINDEX + 1
CreditInput.Parent = CreditFrame

local CreditButton = Instance.new("TextButton")
CreditButton.Size = UDim2.new(0.33, -5, 0, 35)
CreditButton.Position = UDim2.new(0.67, 0, 0, 30)
CreditButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
CreditButton.Text = "설정"
CreditButton.TextColor3 = Color3.fromRGB(0, 0, 0)
CreditButton.TextScaled = true
CreditButton.Font = Enum.Font.GothamBold
CreditButton.ZIndex = LAYER_ZINDEX + 1
CreditButton.Parent = CreditFrame

-- 상태 표시
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "✅ 활성화됨 | Ctrl+Q 토글"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.ZIndex = LAYER_ZINDEX + 1
StatusLabel.Parent = MainFrame

-- 모든 둥근 모서리 적용
for _, obj in pairs(ScreenGui:GetDescendants()) do
    if obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("Frame") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = obj
    end
end

-- 🆕 1. Ctrl + 우클릭 지형 좌표 자동 설정 (핵심!)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Ctrl + Q 전체 토글
    if input.KeyCode == Enum.KeyCode.Q and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        HACKS_ENABLED = not HACKS_ENABLED
        ScreenGui.Enabled = HACKS_ENABLED
        
        StatusLabel.Text = HACKS_ENABLED and "✅ 활성화됨 | Ctrl+Q 토글" or "❌ 비활성화됨"
        StatusLabel.TextColor3 = HACKS_ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        for _, guiObj in pairs(ScreenGui:GetDescendants()) do
            if guiObj:IsA("GuiObject") then
                guiObj.ZIndex = HACKS_ENABLED and LAYER_ZINDEX or 0
            end
        end
        return
    end
    
    -- Ctrl + 우클릭: 지형 좌표 설정 시작
    if input.UserInputType == Enum.UserInputType.MouseButton2 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        SETTING_TARGET = true
        StatusLabel.Text = "🎯 지형 위에 마우스 이동 → 우클릭 떼기"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end)

-- 마우스 이동시 Raycast로 지형 좌표 실시간 계산
UserInputService.InputChanged:Connect(function(input)
    if SETTING_TARGET and input.UserInputType == Enum.UserInputType.MouseMovement then
        local camera = workspace.CurrentCamera
        local unitRay = camera:ScreenPointToRay(Mouse.X, Mouse.Y)
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}
        
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
        
        if raycastResult then
            local hitPosition = raycastResult.Position
            TARGET_POSITION = Vector3.new(hitPosition.X, hitPosition.Y + 5, hitPosition.Z) -- Y+5 발밑 보정
            
            -- 실시간 좌표 표시
            TPInput.Text = string.format("%.0f, %.0f, %.0f", TARGET_POSITION.X, TARGET_POSITION.Y, TARGET_POSITION.Z)
        end
    end
end)

-- 우클릭 뗄 때 좌표 설정 완료
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and SETTING_TARGET then
        SETTING_TARGET = false
        StatusLabel.Text = "✅ 좌표 설정 완료! 'TP!' 클릭"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

-- 2. TP 버튼
TPButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(TARGET_POSITION)
        StatusLabel.Text = "🚀 순간이동 완료!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "❌ 캐릭터 없음"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- 3. 크레딧 변경
CreditButton.MouseButton1Click:Connect(function()
    local amount = tonumber(CreditInput.Text:gsub(",", ""))
    if amount then
        -- Leaderstats 우선
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local money = leaderstats:FindFirstChild("Credits") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
            if money then
                money.Value = amount
                StatusLabel.Text = "💰 크레딧 → " .. amount
                StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                return
            end
        end
        
        -- 플레이어 폴더 우회
        local playerFolder = workspace:FindFirstChild("MapFolder") and workspace.MapFolder:FindFirstChild("Players") and workspace.MapFolder.Players:FindFirstChild(LocalPlayer.Name)
        if playerFolder then
            local credits = playerFolder:FindFirstChild("Credits") or playerFolder:FindFirstChild("Money")
            if credits then
                credits.Value = amount
                StatusLabel.Text = "💰 크레딧 → " .. amount
                StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            end
        end
    else
        StatusLabel.Text = "❌ 숫자만 입력"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- 4. 실시간 현재 위치 표시
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local pos = character.HumanoidRootPart.Position
        Title.Text = string.format("🚀 HACKS v3.0 | %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
    end
end)

-- 5. UI 드래그
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("🎉 완전한 해킹 UI 로드 완료!")
print("📍 Ctrl+우클릭 → 지형 선택 → TP! 버튼")
print("💰 크레딧 숫자 입력 → 설정 버튼") 
print("⌨️ Ctrl+Q → 전체 숨김/표시")
print("🖱️ 드래그 → UI 이동")
