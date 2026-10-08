local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Parent Target Setup
local targetGuiParent = (RunService:IsStudio() and localPlayer:WaitForChild("PlayerGui")) or (pcall(function() return CoreGui end) and CoreGui or localPlayer:WaitForChild("PlayerGui"))

if targetGuiParent:FindFirstChild("NPCControllerGui") then
    targetGuiParent.NPCControllerGui:Destroy()
end

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NPCControllerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGuiParent

-- Main Window
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "NPC Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Controls Header
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Controlling: [None / Self]"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 30)
btnContainer.Position = UDim2.new(0, 10, 0, 65)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = mainFrame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.48, 0, 1, 0)
scanBtn.Position = UDim2.new(0, 0, 0, 0)
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
scanBtn.Text = "Scan NPCs"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 12
scanBtn.Parent = btnContainer
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 4)

local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(0.48, 0, 1, 0)
releaseBtn.Position = UDim2.new(0.52, 0, 0, 0)
releaseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
releaseBtn.Text = "Release Control"
releaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
releaseBtn.Font = Enum.Font.GothamBold
releaseBtn.TextSize = 12
releaseBtn.Parent = btnContainer
Instance.new("UICorner", releaseBtn).CornerRadius = UDim.new(0, 4)

-- Scrolling NPC List
local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, -20, 1, -110)
scrollList.Position = UDim2.new(0, 10, 0, 102)
scrollList.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
scrollList.BorderSizePixel = 0
scrollList.ScrollBarThickness = 4
scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollList.Parent = mainFrame
Instance.new("UICorner", scrollList).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scrollList

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
end)

-- State Variables
local targetModel = nil
local targetHumanoid = nil
local targetHRP = nil
local controlConnection = nil

local function releaseControl()
    if controlConnection then
        controlConnection:Disconnect()
        controlConnection = nil
    end

    if targetHumanoid then
        targetHumanoid:Move(Vector3.zero, false)
    end

    targetModel = nil
    targetHumanoid = nil
    targetHRP = nil
    statusLabel.Text = "Controlling: [None / Self]"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

    local myChar = localPlayer.Character
    if myChar and myChar:FindFirstChild("Humanoid") then
        camera.CameraSubject = myChar.Humanoid
        myChar.Humanoid.WalkSpeed = 16
    end
end

local function controlNPC(npcModel)
    releaseControl()

    local hum = npcModel:FindFirstChildOfClass("Humanoid")
    local hrp = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Torso") or npcModel:FindFirstChild("UpperTorso")

    if not hum or not hrp then return end

    targetModel = npcModel
    targetHumanoid = hum
    targetHRP = hrp

    statusLabel.Text = "Controlling: " .. npcModel.Name
    statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)

    -- Lock Camera sa NPC
    camera.CameraSubject = hum

    -- I-freeze ang real character aron dili magdungan og dagan
    local myChar = localPlayer.Character
    if myChar and myChar:FindFirstChild("Humanoid") then
        myChar.Humanoid.WalkSpeed = 0
    end

    -- Movement Direction Calculation loop
    controlConnection = RunService.RenderStepped:Connect(function()
        if not targetHumanoid or not targetHumanoid.Parent or targetHumanoid.Health <= 0 then
            releaseControl()
            return
        end

        local moveDir = Vector3.zero
        local camCFrame = camera.CFrame
        local forward = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
        local right = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + right
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        -- Move NPC relative to camera direction
        targetHumanoid:Move(moveDir, false)

        -- Handle NPC Jump
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetHumanoid.Jump = true
        end
    end)
end

local function scanNPCs()
    for _, child in ipairs(scrollList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local myChar = localPlayer.Character
    local found = 0

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= myChar then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")

            -- Filter: Kinahanglan dunay Humanoid, unanchored HRP, ug buhi
            if hum and hrp and not hrp.Anchored and hum.Health > 0 then
                -- Likayan ang ubang online players
                if not Players:GetPlayerFromCharacter(model) then
                    found = found + 1
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, -8, 0, 32)
                    row.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
                    row.BorderSizePixel = 0
                    row.Parent = scrollList
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(0.65, 0, 1, 0)
                    nameLabel.Position = UDim2.new(0, 8, 0, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = model.Name
                    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    nameLabel.TextSize = 12
                    nameLabel.Font = Enum.Font.Gotham
                    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    nameLabel.Parent = row

                    local takeBtn = Instance.new("TextButton")
                    takeBtn.Size = UDim2.new(0.3, -4, 0, 22)
                    takeBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
                    takeBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 90)
                    takeBtn.Text = "Control"
                    takeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    takeBtn.Font = Enum.Font.GothamBold
                    takeBtn.TextSize = 11
                    takeBtn.Parent = row
                    Instance.new("UICorner", takeBtn).CornerRadius = UDim.new(0, 4)

                    takeBtn.MouseButton1Click:Connect(function()
                        controlNPC(model)
                    end)
                end
            end
        end
    end

    title.Text = string.format("NPC Controller (%d Found)", found)
end

scanBtn.MouseButton1Click:Connect(scanNPCs)
releaseBtn.MouseButton1Click:Connect(releaseControl)

scanNPCs()