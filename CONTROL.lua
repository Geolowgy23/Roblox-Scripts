local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local currentPart = nil
local att, lv, av
local controlSpeed = 100
local systemActive = false
local spinActive = false
local sanibEnabled = true 

local originalCFrame = nil 
local savedJoints = {} 

-- Limpyo sa karaan
if CoreGui:FindFirstChild("SanibRC_Pro") then CoreGui.SanibRC_Pro:Destroy() end

-- [ MAIN GUI ]
local sg = Instance.new("ScreenGui")
sg.Name = "SanibRC_Pro"
sg.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 330) 
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.08)
frame.Active = true
frame.Draggable = true
frame.Parent = sg

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.new(1, 0, 0)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "RC CONTROLLER PRO"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- [ BUTTONS ]
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 180, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 45)
toggleBtn.Text = "SYSTEM: OFF"
toggleBtn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
toggleBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn)

local sanibBtn = Instance.new("TextButton")
sanibBtn.Size = UDim2.new(0, 180, 0, 40)
sanibBtn.Position = UDim2.new(0, 20, 0, 90)
sanibBtn.Text = "SANIB: ON"
sanibBtn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
sanibBtn.TextColor3 = Color3.new(0, 0.8, 1)
sanibBtn.Font = Enum.Font.GothamBold
sanibBtn.Parent = frame
Instance.new("UICorner", sanibBtn)

local spinBtn = Instance.new("TextButton")
spinBtn.Size = UDim2.new(0, 180, 0, 40)
spinBtn.Position = UDim2.new(0, 20, 0, 135)
spinBtn.Text = "SPIN MODE: OFF"
spinBtn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
spinBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
spinBtn.Font = Enum.Font.GothamBold
spinBtn.Parent = frame
Instance.new("UICorner", spinBtn)

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 180, 0, 30)
speedInput.Position = UDim2.new(0, 20, 0, 180)
speedInput.Text = "100"
speedInput.PlaceholderText = "Set Speed..."
speedInput.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
speedInput.TextColor3 = Color3.new(0, 1, 1)
speedInput.Font = Enum.Font.GothamBold
speedInput.Parent = frame
Instance.new("UICorner", speedInput)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 70)
info.Position = UDim2.new(0, 0, 0, 250)
info.Text = "Q/E: Up/Down | X: Exit RC\nSanib OFF = Freeze Char"
info.TextColor3 = Color3.new(0.7, 0.7, 0.7)
info.TextSize = 10
info.BackgroundTransparency = 1
info.Parent = frame

-- [ FUNCTIONS ]

local function setCharacterFreeze(freeze)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = freeze
    end
end

local function squishCharacter(squish)
    local char = player.Character
    if not char then return end
    if squish and sanibEnabled then 
        savedJoints = {}
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then
                savedJoints[obj] = obj.C0
                obj.C0 = CFrame.new(0, 0, 0)
            elseif obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    else
        for motor, originalC0 in pairs(savedJoints) do
            if motor and motor.Parent then motor.C0 = originalC0 end
        end
        savedJoints = {}
    end
end

local function stopRC()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hum then hum.PlatformStand = false end
        setCharacterFreeze(false) -- Siguradohon nga ma-unfreeze
        squishCharacter(false)
        
        if hrp and originalCFrame and sanibEnabled then
            hrp.CFrame = originalCFrame
        end
        originalCFrame = nil
    end
    camera.CameraSubject = player.Character:WaitForChild("Humanoid")
    if att then att:Destroy() end
    if currentPart and currentPart:FindFirstChild("LinearVelocity") then currentPart.LinearVelocity:Destroy() end
    if currentPart and currentPart:FindFirstChild("AngularVelocity") then currentPart.AngularVelocity:Destroy() end
    currentPart = nil
end

toggleBtn.MouseButton1Click:Connect(function()
    systemActive = not systemActive
    if systemActive then
        toggleBtn.Text = "SYSTEM: ON"
        toggleBtn.TextColor3 = Color3.new(0, 1, 0.5)
        stroke.Color = Color3.new(0, 1, 0.5)
    else
        toggleBtn.Text = "SYSTEM: OFF"
        toggleBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
        stroke.Color = Color3.new(1, 0, 0)
        stopRC()
    end
end)

sanibBtn.MouseButton1Click:Connect(function()
    sanibEnabled = not sanibEnabled
    sanibBtn.Text = sanibEnabled and "SANIB: ON" or "SANIB: OFF"
    sanibBtn.TextColor3 = sanibEnabled and Color3.new(0, 0.8, 1) or Color3.new(1, 0.5, 0)
end)

spinBtn.MouseButton1Click:Connect(function()
    spinActive = not spinActive
    spinBtn.Text = spinActive and "SPIN MODE: ON" or "SPIN MODE: OFF"
    spinBtn.TextColor3 = spinActive and Color3.new(1, 1, 0) or Color3.new(0.8, 0.8, 0.8)
end)

speedInput:GetPropertyChangedSignal("Text"):Connect(function()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed then controlSpeed = newSpeed end
end)

mouse.Button1Down:Connect(function()
    if not systemActive then return end
    local target = mouse.Target
    if target and not target.Anchored and target:IsA("BasePart") then
        if not target:IsDescendantOf(player.Character) then
            if att then att:Destroy() end
            if currentPart and currentPart:FindFirstChild("LinearVelocity") then currentPart.LinearVelocity:Destroy() end
            if currentPart and currentPart:FindFirstChild("AngularVelocity") then currentPart.AngularVelocity:Destroy() end
            
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if not originalCFrame then originalCFrame = char.HumanoidRootPart.CFrame end
                
                if sanibEnabled then
                    char.Humanoid.PlatformStand = true
                    setCharacterFreeze(false)
                else
                    -- I-freeze ang character kung dili mu-sanib
                    setCharacterFreeze(true)
                end
            end

            squishCharacter(sanibEnabled)
            currentPart = target
            att = Instance.new("Attachment", currentPart)
            lv = Instance.new("LinearVelocity", currentPart)
            lv.MaxForce = 9e9
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            lv.Attachment0 = att
            av = Instance.new("AngularVelocity", currentPart)
            av.MaxTorque = 9e9
            av.Attachment0 = att
            camera.CameraSubject = currentPart
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if systemActive and currentPart and input.KeyCode == Enum.KeyCode.X then stopRC() end
end)

RunService.RenderStepped:Connect(function()
    if systemActive and currentPart and lv then
        local char = player.Character
        
        if sanibEnabled and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = currentPart.CFrame
            char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end

        if UserInputService:GetFocusedTextBox() then return end 

        local moveDir = Vector3.new(0, 0, 0)
        local cf = camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        lv.VectorVelocity = (moveDir.Magnitude > 0) and (moveDir.Unit * controlSpeed) or Vector3.new(0,0,0)
        
        if spinActive and av then
            av.AngularVelocity = Vector3.new(0, 50, 0) 
        elseif av then
            av.AngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)