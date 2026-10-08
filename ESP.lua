local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local coreGui = game:GetService("CoreGui")

local isEnabled = true
local REFRESH_RATE = 3

-- Cleanup function para matangtang tanan kung i-OFF
local function clearAllChams()
    for _, player in ipairs(players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("TeamChams")
            if highlight then highlight:Destroy() end

            local head = player.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("NameTag")
                if tag then tag:Destroy() end
            end
        end
    end
end

-- Function para mag-apply og Chams & NameTags
local function applyTeamChams()
    if not isEnabled then return end

    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                -- Highlight
                local oldChams = char:FindFirstChild("TeamChams")
                if oldChams then oldChams:Destroy() end

                local highlight = Instance.new("Highlight")
                highlight.Name = "TeamChams"
                highlight.Parent = char

                local teamColor = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                highlight.FillColor = teamColor
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                -- Name Tag
                local head = char:FindFirstChild("Head")
                if head then
                    local oldName = head:FindFirstChild("NameTag")
                    if oldName then oldName:Destroy() end

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "NameTag"
                    billboard.Size = UDim2.new(0, 150, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = head

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Parent = billboard
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = teamColor
                    nameLabel.TextStrokeTransparency = 0.2
                    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    nameLabel.TextSize = 10
                    nameLabel.Font = Enum.Font.SourceSansBold
                    nameLabel.Text = player.DisplayName .. "\n(@" .. player.Name .. ")"
                end
            end
        end
    end
end

-- ================= GUI SETUP ================= --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChamsToggleGui"
screenGui.ResetOnSpawn = false

-- Gamiton ang CoreGui kung supported sa executor, kung dili sa PlayerGui ibutang
local success = pcall(function()
    screenGui.Parent = coreGui
end)
if not success then
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 130, 0, 35)
button.Position = UDim2.new(0, 20, 0.5, -17)
button.BackgroundColor3 = Color3.fromRGB(30, 180, 80) -- Green kung ON
button.Text = "Chams: ON"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16
button.Active = true
button.Draggable = true -- Pwede i-drag palayo sa screen
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Toggle button logic
button.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        button.Text = "Chams: ON"
        button.BackgroundColor3 = Color3.fromRGB(30, 180, 80)
        pcall(applyTeamChams)
    else
        button.Text = "Chams: OFF"
        button.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Red kung OFF
        clearAllChams()
    end
end)

-- Background Loop
task.spawn(function()
    while true do
        if isEnabled then
            pcall(applyTeamChams)
        end
        task.wait(REFRESH_RATE)
    end
end)