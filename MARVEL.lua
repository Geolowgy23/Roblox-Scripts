-- [[ iOS NEON GLASSMORPHIC GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local UIStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local ContentFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local MinimizeBtn = Instance.new("TextButton")
local MinimizeCorner = Instance.new("UICorner")
local MinimizeStroke = Instance.new("UIStroke")

-- Setup Parent
ScreenGui.Name = "iOS_Premium_v2"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- [[ MAIN FRAME DESIGN ]] --
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -150)
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

-- Rounded Corners & Neon Border
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
}
UIGradient.Parent = UIStroke

-- Title Design
Title.Parent = MainFrame
Title.Text = "GEO HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1

-- [[ FLOATING MINIMIZE BUTTON ]] --
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Parent = ScreenGui
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MinimizeBtn.BackgroundTransparency = 0.3
MinimizeBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
MinimizeBtn.Size = UDim2.new(0, 50, 0, 50)
MinimizeBtn.Text = "⚡"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 25

MinimizeCorner.CornerRadius = UDim.new(1, 0)
MinimizeCorner.Parent = MinimizeBtn

MinimizeStroke.Thickness = 2
MinimizeStroke.Color = Color3.fromRGB(0, 150, 255)
MinimizeStroke.Parent = MinimizeBtn

-- [[ CONTENT AREA ]] --
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 15, 0, 60)
ContentFrame.Size = UDim2.new(1, -30, 1, -75)
ContentFrame.ScrollBarThickness = 2

UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ UI COMPONENT CREATORS ]] --
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Parent = ContentFrame
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = btn
    
    local bs = Instance.new("UIStroke")
    bs.Thickness = 1
    bs.Color = Color3.fromRGB(100, 100, 100)
    bs.Parent = btn

    btn.MouseEnter:Connect(function() bs.Color = Color3.fromRGB(0, 200, 255) end)
    btn.MouseLeave:Connect(function() bs.Color = Color3.fromRGB(100, 100, 100) end)
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

local function CreateInput(placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    box.BackgroundTransparency = 0.5
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    box.Parent = ContentFrame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = box

    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end

-- [[ LOGIC & STATE VARIABLES ]] --
local hitboxEnabled = false
local currentHitboxSize = 10
local infJumpEnabled = false
local noCooldownEnabled = false
local hooksInstalled = false
local origWait
local origTaskWait

-- Function to reset hitbox to default
local function ResetHitboxes()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = false
            end
        end
    end
end

-- 1. Hitbox Controls
CreateInput("Set Hitbox Size (Default: 10)", function(val)
    local num = tonumber(val)
    if num then
        currentHitboxSize = num
        print("Hitbox Size set to: " .. currentHitboxSize)
    end
end)

CreateButton("Hitbox: [ OFF ]", function(btn)
    hitboxEnabled = not hitboxEnabled
    if hitboxEnabled then
        btn.Text = "Hitbox: [ ON ]"
        btn.TextColor3 = Color3.fromRGB(0, 255, 128)
    else
        btn.Text = "Hitbox: [ OFF ]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ResetHitboxes()
    end
end)

task.spawn(function()
    while task.wait(1) do
        if hitboxEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(currentHitboxSize, currentHitboxSize, currentHitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                        hrp.Color = Color3.fromRGB(0, 150, 255)
                    end
                end
            end
        end
    end
end)

-- 2. Infinite Jump Controls
CreateButton("Infinite Jump: [ OFF ]", function(btn)
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        btn.Text = "Infinite Jump: [ ON ]"
        btn.TextColor3 = Color3.fromRGB(0, 255, 128)
    else
        btn.Text = "Infinite Jump: [ OFF ]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled then
        local lp = game.Players.LocalPlayer
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- 3. No Cooldown Controls (ON / OFF Toggle)
CreateButton("No Cooldown: [ OFF ]", function(btn)
    if not hookfunction then
        warn("Your executor does not support hookfunction.")
        return
    end

    -- Hook kausa ra i-setup aron dili magka-memory leak o stack overflow
    if not hooksInstalled then
        hooksInstalled = true
        origWait = hookfunction(wait, function(seconds)
            if noCooldownEnabled then
                return origWait(0)
            end
            return origWait(seconds)
        end)

        if task and task.wait then
            origTaskWait = hookfunction(task.wait, function(seconds)
                if noCooldownEnabled then
                    return origTaskWait(0)
                end
                return origTaskWait(seconds)
            end)
        end
    end

    noCooldownEnabled = not noCooldownEnabled

    if noCooldownEnabled then
        btn.Text = "No Cooldown: [ ON ]"
        btn.TextColor3 = Color3.fromRGB(0, 255, 128)
        print("No Cooldown: ENABLED")
    else
        btn.Text = "No Cooldown: [ OFF ]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        print("No Cooldown: DISABLED")
    end
end)

-- [[ MINIMIZE ANIMATION ]] --
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 340), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "X"
    else
        MinimizeBtn.Text = "⚡"
    end
end)

print("Unique iOS UI Loaded!")