-- Roblox ESP Hack for RUSH POINT (Universal Wallhack/ESP)
-- Inject this via your executor (Synapse, Krnl, etc.)
-- Works by highlighting players through walls with boxes, names, distance, and health.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
local ESP_ENABLED = true
local BOX_COLOR = Color3.fromRGB(255, 0, 0)  -- Red boxes
local TEAM_CHECK = false  -- Set to true to ignore teammates
local MAX_DISTANCE = 5000  -- Max render distance

-- Table to store ESP objects
local ESPObjects = {}

-- Function to create BillboardGui for ESP
local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = player.Character and player.Character:FindFirstChild("Head") or nil
    billboard.AlwaysOnTop = true
    
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = billboard
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = boxFrame
    
    -- Distance label
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distLabel.Position = UDim2.new(0, 0, 0.3, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "Loading..."
    distLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Parent = boxFrame
    
    -- Health label
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0.4, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.6, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "Health: 100"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = 12
    healthLabel.Parent = boxFrame
    
    ESPObjects[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        distLabel = distLabel,
        healthLabel = healthLabel
    }
end

-- Function to update ESP
local function updateESP()
    for player, esp in pairs(ESPObjects) do
        if player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            -- Distance calculation
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            esp.distLabel.Text = math.floor(distance) .. "m"
            
            -- Health update
            if humanoid then
                local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                esp.healthLabel.Text = "HP: " .. healthPercent .. "%"
                esp.healthLabel.TextColor3 = Color3.fromRGB(255 - healthPercent * 2.55, healthPercent * 2.55, 0)
            end
            
            -- Team check
            if TEAM_CHECK and player.Team == LocalPlayer.Team then
                esp.billboard.Enabled = false
            else
                esp.billboard.Enabled = distance <= MAX_DISTANCE
            end
        else
            -- Clean up dead/disconnected players
            esp.billboard:Destroy()
            ESPObjects[player] = nil
        end
    end
end

-- Function to add 3D Box ESP (more advanced)
local function createBoxESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = BOX_COLOR
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = player.Character and player.Character.HumanoidRootPart or nil
    
    ESPObjects[player] = box
end

-- Main ESP loop
local function startESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
            createBoxESP(player)
        end
    end
    
    -- Connect events
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(1)  -- Wait for character to fully load
            createESP(player)
            createBoxESP(player)
        end)
    end)
    
    -- Update loop
    RunService.Heartbeat:Connect(updateESP)
end

-- Toggle command (optional)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        ESP_ENABLED = not ESP_ENABLED
        for player, esp in pairs(ESPObjects) do
            if esp.billboard then
                esp.billboard.Enabled = ESP_ENABLED
            elseif esp:IsA("BoxHandleAdornment") then
                esp.Transparency = ESP_ENABLED and 0.5 or 1
            end
        end
        print("ESP Toggled:", ESP_ENABLED)
    end
end)

-- Start the ESP
startESP()
print("RUSH POINT ESP loaded! Press INSERT to toggle.")
