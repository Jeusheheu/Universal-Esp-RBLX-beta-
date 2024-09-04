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
local guiExists = true  -- Indicates if the GUI is still present
local mouse = localPlayer:GetMouse()
local circleRadius = 100  -- Default radius of the circle around the mouse

-- Create a UI container for the lock-on button (making it draggable)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local draggableFrame = Instance.new("Frame")
draggableFrame.Size = UDim2.new(0, 300, 0, 200)
draggableFrame.Position = UDim2.new(0, 10, 0, 10)
draggableFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
draggableFrame.BackgroundTransparency = 0.3
draggableFrame.Active = true  -- Allows the frame to be draggable
draggableFrame.Draggable = true  -- Makes the frame draggable
draggableFrame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 280, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Lock-On: OFF"
toggleButton.TextScaled = true
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = draggableFrame

local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(0, 280, 0, 50)
destroyButton.Position = UDim2.new(0, 10, 0, 70)
destroyButton.Text = "Destroy GUI"
destroyButton.TextScaled = true
destroyButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
destroyButton.TextColor3 = Color3.new(1, 1, 1)
destroyButton.Parent = draggableFrame

local radiusSlider = Instance.new("Frame")
radiusSlider.Size = UDim2.new(0, 280, 0, 50)
radiusSlider.Position = UDim2.new(0, 10, 0, 130)
radiusSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
radiusSlider.Parent = draggableFrame

local radiusText = Instance.new("TextLabel")
radiusText.Size = UDim2.new(1, 0, 1, 0)
radiusText.Text = "Circle Radius: " .. circleRadius
radiusText.TextScaled = true
radiusText.TextColor3 = Color3.new(1, 1, 1)
radiusText.BackgroundTransparency = 1
radiusText.Parent = radiusSlider

local radiusInput = Instance.new("TextBox")
radiusInput.Size = UDim2.new(0, 100, 1, 0)
radiusInput.Position = UDim2.new(0.5, -50, 0, 0)
radiusInput.Text = tostring(circleRadius)
radiusInput.TextScaled = true
radiusInput.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
radiusInput.TextColor3 = Color3.new(1, 1, 1)
radiusInput.Parent = radiusSlider

-- Function to check if a position is within the circle
local function isWithinCircle(position, center, radius)
    return (position - center).Magnitude <= radius
end

-- Function to find the nearest player within the circle, that is not on the same team and is not dead
local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = Vector2.new(mouse.X, mouse.Y)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local headPosition = camera:WorldToScreenPoint(player.Character.Head.Position)
                local screenHeadPosition = Vector2.new(headPosition.X, headPosition.Y)
                
                if isWithinCircle(screenHeadPosition, mousePosition, circleRadius) then
                    local distance = (player.Character.Head.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        nearestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    return nearestPlayer
end

-- Lock-On functionality (camera control)
local function lockOn()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local targetPosition = targetPlayer.Character.Head.Position
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
    guiExists = false  -- Mark GUI as destroyed
end)

-- Slider function to update circle radius
radiusInput.FocusLost:Connect(function()
    local newRadius = tonumber(radiusInput.Text)
    if newRadius and newRadius >= 50 and newRadius <= 200 then
        circleRadius = newRadius
        radiusText.Text = "Circle Radius: " .. circleRadius
    else
        radiusInput.Text = tostring(circleRadius)  -- Reset to current radius if input is invalid
    end
end)

-- Update the lock-on every frame
RunService.RenderStepped:Connect(function()
    if guiExists and lockOnEnabled and lockOnActive and targetPlayer then
        lockOn()
    elseif not guiExists then
        lockOnEnabled = false
        lockOnActive = false
        targetPlayer = nil
    end
end)
