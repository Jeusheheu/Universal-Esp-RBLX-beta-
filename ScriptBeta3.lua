-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local highlightingEnabled = true
local autoRehighlightEnabled = true
local autoRehighlightInterval = 10
local showNamesEnabled = false
local guiTitle = "Universal ESP by Jeus"

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create Draggable Frame
local draggableFrame = Instance.new("Frame")
draggableFrame.Size = UDim2.new(0, 300, 0, 430)
draggableFrame.Position = UDim2.new(0, 10, 0, 10)
draggableFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
draggableFrame.BackgroundTransparency = 0.3
draggableFrame.Active = true
draggableFrame.Parent = screenGui

-- Add UIDragDetector for dragging functionality
local dragDetector = Instance.new("UIDragDetector")
dragDetector.Parent = draggableFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = guiTitle
titleLabel.TextScaled = true
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = draggableFrame

-- Function to create buttons
local function createButton(name, positionY, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 280, 0, 40)
    button.Position = UDim2.new(0, 10, 0, positionY)
    button.Text = text
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = draggableFrame
    return button
end

-- Create Buttons
local toggleButton = createButton("ToggleButton", 50, "Toggle Highlight: ON")
local rehighlightButton = createButton("RehighlightButton", 100, "Re-highlight Players")
local autoRehighlightButton = createButton("AutoRehighlightButton", 150, "Auto Re-highlight: ON")

-- Interval Label
local intervalLabel = Instance.new("TextLabel")
intervalLabel.Size = UDim2.new(0, 280, 0, 30)
intervalLabel.Position = UDim2.new(0, 10, 0, 200)
intervalLabel.Text = "Re-highlight Interval (seconds):"
intervalLabel.TextScaled = true
intervalLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
intervalLabel.TextColor3 = Color3.new(1, 1, 1)
intervalLabel.Parent = draggableFrame

-- Interval TextBox
local intervalTextBox = Instance.new("TextBox")
intervalTextBox.Size = UDim2.new(0, 280, 0, 40)
intervalTextBox.Position = UDim2.new(0, 10, 0, 230)
intervalTextBox.Text = tostring(autoRehighlightInterval)
intervalTextBox.TextScaled = true
intervalTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
intervalTextBox.TextColor3 = Color3.new(1, 1, 1)
intervalTextBox.Parent = draggableFrame

-- Show Names Button
local showNamesButton = createButton("ShowNamesButton", 280, "Show Names: OFF")

-- Unload Button
local unloadButton = createButton("UnloadButton", 330, "Unload Script")
unloadButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Function to highlight a player's character
local function highlightPlayer(character)
    if character:FindFirstChild("Highlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    if showNamesEnabled and not character:FindFirstChild("NameTag") then
        local head = character:FindFirstChild("Head")
        if head then
            local nameTag = Instance.new("BillboardGui")
            nameTag.Name = "NameTag"
            nameTag.Size = UDim2.new(0, 100, 0, 50)
            nameTag.Adornee = head
            nameTag.AlwaysOnTop = true
            nameTag.Parent = character

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = character.Name
            textLabel.TextScaled = true
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            textLabel.Parent = nameTag
        end
    end
end

-- Function to remove name tags from a player's character
local function removeNameTag(character)
    if character:FindFirstChild("NameTag") then
        character.NameTag:Destroy()
    end
end

-- Function to handle character addition
local function onCharacterAdded(character)
    if highlightingEnabled then
        highlightPlayer(character)
    end
end

-- Function to setup player
local function setupPlayer(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Function to rehighlight all players
local function rehighlightPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            highlightPlayer(player.Character)
        end
    end
end

-- Auto Re-highlight loop
local autoRehighlightConnection
local function startAutoRehighlight()
    if autoRehighlightConnection then
        autoRehighlightConnection:Disconnect()
    end

    autoRehighlightConnection = RunService.Heartbeat:Connect(function()
        if autoRehighlightEnabled then
            rehighlightPlayers()
        end
    end)
end

-- Toggle highlight feature
toggleButton.MouseButton1Click:Connect(function()
    highlightingEnabled = not highlightingEnabled
    toggleButton.Text = highlightingEnabled and "Toggle Highlight: ON" or "Toggle Highlight: OFF"
    if not highlightingEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end
end)

-- Rehighlight all players
rehighlightButton.MouseButton1Click:Connect(function()
    rehighlightPlayers()
end)

-- Auto Rehighlight Toggle
autoRehighlightButton.MouseButton1Click:Connect(function()
    autoRehighlightEnabled = not autoRehighlightEnabled
    autoRehighlightButton.Text = autoRehighlightEnabled and "Auto Re-highlight: ON" or "Auto Re-highlight: OFF"
    if autoRehighlightEnabled then
        startAutoRehighlight()
    else
        if autoRehighlightConnection then
            autoRehighlightConnection:Disconnect()
        end
    end
end)

-- Show Names Toggle
showNamesButton.MouseButton1Click:Connect(function()
    showNamesEnabled = not showNamesEnabled
    showNamesButton.Text = showNamesEnabled and "Show Names: ON" or "Show Names: OFF"

    -- Add or remove NameTags for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            if showNamesEnabled then
                highlightPlayer(player.Character) -- This will add the name tag if not already present
            else
                removeNameTag(player.Character) -- Remove the name tag if showNames is off
            end
        end
    end
end)

-- Unload Script (Ensure highlights and name tags are removed)
unloadButton.MouseButton1Click:Connect(function()
    -- Destroy all highlights and name tags before unloading the script
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            if player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
            removeNameTag(player.Character)
        end
    end
    screenGui:Destroy()
end)

-- Setup Players
for _, player in pairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
