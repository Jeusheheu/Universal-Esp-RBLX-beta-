-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local localPlayer = Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local targetPlayer = nil
local lockOnEnabled = false
local lockOnActive = false  -- Indicates if lock-on is currently active (via RMB)

-- Create a UI container for the lock-on button (making it draggable)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local draggableFrame = Instance.new("Frame")
draggableFrame.Size = UDim2.new(0, 200, 0, 150)
draggableFrame.Position = UDim2.new(0, 10, 0, 10)
draggableFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
draggableFrame.BackgroundTransparency = 0.3
draggableFrame.Active = true  -- Allows the frame to be draggable
draggableFrame.Draggable = true  -- Makes the frame draggable
draggableFrame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 25)
toggleButton.Text = "Lock-On: OFF"
toggleButton.TextScaled = true
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = draggableFrame

local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(0, 180, 0, 50)
destroyButton.Position = UDim2.new(0, 10, 0, 85)
destroyButton.Text = "Destroy GUI"
destroyButton.TextScaled = true
destroyButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
destroyButton.TextColor3 = Color3.new(1, 1, 1)
destroyButton.Parent = draggableFrame

-- Function to find the nearest player
local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                nearestPlayer = player
                shortestDistance = distance
            end
        end
    end

    return nearestPlayer
end

-- Lock-On functionality (camera control)
local function lockOn()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        local cameraPosition = camera.CFrame.Position
        local newCFrame = CFrame.new(cameraPosition, targetPosition)
        camera.CFrame = newCFrame
    end
end

-- Function to enable/disable lock-on when RMB is pressed
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Mouse Button
        lockOnActive = true
        if lockOnEnabled then
            targetPlayer = getNearestPlayer()
        end
    end
end)

-- Function to disable lock-on when RMB is released
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Mouse Button
        lockOnActive = false
        targetPlayer = nil
    end
end)

-- Toggle button function
toggleButton.MouseButton1Click:Connect(function()
    lockOnEnabled = not lockOnEnabled
    toggleButton.Text = "Lock-On: " .. (lockOnEnabled and "ON" or "OFF")
end)

-- Destroy button function
destroyButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Update the lock-on every frame
RunService.RenderStepped:Connect(function()
    if lockOnEnabled and lockOnActive and targetPlayer then
        lockOn()
    end
end)
