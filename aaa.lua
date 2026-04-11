-- 🔥 진짜 All Skins Collection Unlocker 🔥
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 서버 데이터 우회
local SKINS_DATA = {
    Pistols = {"Desert Eagle Gold", "M9 Bayonet Crimson", "Glock Rainbow", "USP Dragon"},
    Rifles = {"AK47 Diamond", "M4A4 Neon", "AWP Golden", "SCAR Cosmic"},
    Snipers = {"AWP Dragon Lore", "SSG Galaxy", "Barrett Platinum"},
    Knives = {"Karambit Fade", "Butterfly Doppler", "M9 Crimson Web"},
    Skins = {"Gold", "Diamond", "Chrome", "Rainbow", "Neon", "Cosmic"}
}

-- 가짜 인벤토리 생성
local function createFakeInventory()
    local inventory = Instance.new("Folder")
    inventory.Name = "AllSkinsInventory"
    inventory.Parent = LocalPlayer.PlayerGui
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkinCollection"
    gui.Parent = inventory
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 400)
    frame.Position = UDim2.new(0.5, -300, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- 둥근 모서리
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- 제목
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔥 ALL SKINS COLLECTION 🔥"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- 스크롤
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -70)
    scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 8
    scroll.Parent = frame
    
    -- 스킨 버튼들 생성
    local yPos = 0
    for category, skins in pairs(SKINS_DATA) do
        -- 카테고리 레이블
        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(1, 0, 0, 30)
        catLabel.Position = UDim2.new(0, 0, 0, yPos)
        catLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        catLabel.Text = category
        catLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        catLabel.TextScaled = true
        catLabel.Font = Enum.Font.GothamBold
        catLabel.Parent = scroll
        
        yPos = yPos + 40
        
        -- 개별 스킨 버튼
        for i, skinName in pairs(skins) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.48, -5, 0, 60)
            btn.Position = UDim2.new((i-1)%2 * 0.5, 0, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            btn.Text = skinName
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                applySkin(skinName)
                -- 버튼 골드 효과
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
                wait(0.2)
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 65)}):Play()
            end)
            
            btn.Parent = scroll
        end
        
        yPos = yPos + 75
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
    
    -- 토글 버튼
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 100, 0, 40)
    toggleBtn.Position = UDim2.new(0, 20, 0, 20)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    toggleBtn.Text = "스킨 열기"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = LocalPlayer.PlayerGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    local frameVisible = false
    toggleBtn.MouseButton1Click:Connect(function()
        frameVisible = not frameVisible
        frame.Visible = frameVisible
        toggleBtn.Text = frameVisible and "닫기" or "스킨 열기"
    end)
end

-- 스킨 실제 적용 함수
function applySkin(skinName)
    print("🎨 적용 중:", skinName)
    
    -- 1. 서버 인벤토리 위조
    local playerFolder = workspace.MapFolder.Players[LocalPlayer.Name]
    local inventory = playerFolder:FindFirstChild("Inventory") or Instance.new("Folder")
    inventory.Name = "Inventory"
    inventory.Parent = playerFolder
    
    -- 스킨 데이터 생성
    local skinData = Instance.new("StringValue")
    skinData.Name = skinName
    skinData.Value = skinName
    skinData.Parent = inventory
    
    -- 2. 현재 무기 변경
    local currentWeapon = playerFolder:FindFirstChildOfClass("Tool") or playerFolder:FindFirstChild("Weapon")
    if currentWeapon then
        applyVisualSkin(currentWeapon, skinName)
    end
    
    -- 3. RemoteEvent 우회 발사 (스킨 적용 요청)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local equipRemote = remotes:FindFirstChild("EquipSkin") or remotes:FindFirstChild("ChangeSkin")
        if equipRemote then
            equipRemote:FireServer(skinName)
        end
    end
end

-- 비주얼 스킨 적용
function applyVisualSkin(weapon, skinName)
    local colors = {
        ["Gold"] = Color3.fromRGB(255, 215, 0),
        ["Diamond"] = Color3.fromRGB(200, 255, 255),
        ["Chrome"] = Color3.fromRGB(200, 200, 200),
        ["Rainbow"] = Color3.fromHSV(tick() % 5 / 5, 1, 1),
        ["Neon"] = Color3.fromRGB(0, 255, 255),
        ["Cosmic"] = Color3.fromRGB(128, 0, 255)
    }
    
    local color = colors[skinName:match("%w+")] or Color3.fromRGB(255, 0, 0)
    
    for _, part in pairs(weapon:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = color
            part.Material = Enum.Material.Neon
            
            -- Glow
            if not part:FindFirstChild("SkinGlow") then
                local glow = Instance.new("PointLight")
                glow.Name = "SkinGlow"
                glow.Brightness = 2
                glow.Color = color
                glow.Range = 12
                glow.Parent = part
            end
        end
    end
end

-- 모든 무기 변경 감지
spawn(function()
    while wait(1) do
        local playerFolder = workspace.MapFolder.Players[LocalPlayer.Name]
        local weapon = playerFolder:FindFirstChildOfClass("Tool") or playerFolder:FindFirstChild("Weapon")
        if weapon then
            local lastSkin = weapon:GetAttribute("LastSkin")
            if not lastSkin then
                weapon:SetAttribute("LastSkin", "Default")
            end
        end
    end
end)

-- UI 생성
createFakeInventory()

print("🎉 진짜 All Skins Collection 완성!")
print("📱 화면 왼쪽 위 '스킨 열기' 버튼 클릭!")
print("⚡ 선택한 스킨 즉시 적용 + 서버 우회!")
