-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Variables
local highlightingEnabled = true
local autoRehighlightEnabled = true
local autoRehighlightInterval = 10  -- Default interval in seconds
local showNamesEnabled = false
local guiTitle = "Universal ESP by Jeus" -- Title of the GUI

-- Create a UI container for the buttons (making it draggable)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local draggableFrame = Instance.new("Frame")
draggableFrame.Size = UDim2.new(0, 300, 0, 390)  -- Adjusted size to fit title and all buttons
draggableFrame.Position = UDim2.new(0, 10, 0, 10)
draggableFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
draggableFrame.BackgroundTransparency = 0.3
draggableFrame.Active = true  -- Allows the frame to be draggable
draggableFrame.Draggable = true  -- Makes the frame draggable
draggableFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)  -- Title takes full width of the frame
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = guiTitle
titleLabel.TextScaled = true
titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = draggableFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 280, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 50)  -- Positioned below the title
toggleButton.Text = "Toggle Highlight: ON"
toggleButton.TextScaled = true
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = draggableFrame

local rehighlightButton = Instance.new("TextButton")
rehighlightButton.Size = UDim2.new(0, 280, 0, 50)
rehighlightButton.Position = UDim2.new(0, 10, 0, 110)  -- Positioned below the toggle button
rehighlightButton.Text = "Re-highlight Players"
rehighlightButton.TextScaled = true
rehighlightButton.BackgroundColor3 = Color3.new(0, 0, 0)
rehighlightButton.TextColor3 = Color3.new(1, 1, 1)
rehighlightButton.Parent = draggableFrame

local autoRehighlightButton = Instance.new("TextButton")
autoRehighlightButton.Size = UDim2.new(0, 280, 0, 50)
autoRehighlightButton.Position = UDim2.new(0, 10, 0, 170)  -- Positioned below the re-highlight button
autoRehighlightButton.Text = "Auto Re-highlight: ON"
autoRehighlightButton.TextScaled = true
autoRehighlightButton.BackgroundColor3 = Color3.new(0, 0, 0)
autoRehighlightButton.TextColor3 = Color3.new(1, 1, 1)
autoRehighlightButton.Parent = draggableFrame

local intervalLabel = Instance.new("TextLabel")
intervalLabel.Size = UDim2.new(0, 280, 0, 30)
intervalLabel.Position = UDim2.new(0, 10, 0, 230)  -- Positioned above the interval textbox
intervalLabel.Text = "Re-highlight Interval (seconds):"
intervalLabel.TextScaled = true
intervalLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
intervalLabel.TextColor3 = Color3.new(1, 1, 1)
intervalLabel.Parent = draggableFrame

local intervalTextBox = Instance.new("TextBox")
intervalTextBox.Size = UDim2.new(0, 280, 0, 50)
intervalTextBox.Position = UDim2.new(0, 10, 0, 260)  -- Positioned below the interval label
intervalTextBox.Text = tostring(autoRehighlightInterval)
intervalTextBox.TextScaled = true
intervalTextBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
intervalTextBox.TextColor3 = Color3.new(1, 1, 1)
intervalTextBox.Parent = draggableFrame

local showNamesButton = Instance.new("TextButton")
showNamesButton.Size = UDim2.new(0, 280, 0, 50)
showNamesButton.Position = UDim2.new(0, 10, 0, 320)  -- Positioned below the interval textbox
showNamesButton.Text = "Show Names: OFF"
showNamesButton.TextScaled = true
showNamesButton.BackgroundColor3 = Color3.new(0, 0, 0)
showNamesButton.TextColor3 = Color3.new(1, 1, 1)
showNamesButton.Parent = draggableFrame

local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0, 280, 0, 50)
unloadButton.Position = UDim2.new(0, 10, 0, 380)  -- Positioned below the show names button
unloadButton.Text = "Unload Script"
unloadButton.TextScaled = true
unloadButton.BackgroundColor3 = Color3.new(1, 0, 0)
unloadButton.TextColor3 = Color3.new(1, 1, 1)
unloadButton.Parent = draggableFrame

-- Flag to control the rehighlight loop
local stopAutoRehighlightLoop = false

-- Function to highlight a player's character
local function highlightPlayer(character)
    -- Check if the character already has a highlight
    if character:FindFirstChild("Highlight") then
        return
    end

    -- Create a new Highlight object
    local highlight = Instance.new("Highlight")
    highlight.Parent = character

    -- Set properties for the highlight
    local player = Players:GetPlayerFromCharacter(character)
    local teamColor = player and player.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 0) -- Default to yellow if team color not found
    highlight.FillColor = teamColor -- Color based on team
    highlight.OutlineColor = Color3.new(0, 0, 0) -- Black outline
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0

    -- Attach the highlight to the player's character
    highlight.Adornee = character

    -- Create and display player name if enabled
    if showNamesEnabled then
        local nameTag = character:FindFirstChild("NameTag")
        if not nameTag then
            nameTag = Instance.new("BillboardGui")
            nameTag.Name = "NameTag"
            nameTag.Size = UDim2.new(0, 100, 0, 50)  -- Smaller size
            nameTag.Adornee = character:FindFirstChild("Head")
            nameTag.AlwaysOnTop = true
            nameTag.Parent = character

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = character.Name
            textLabel.TextScaled = true
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = teamColor -- Change text color based on team color
            textLabel.Parent = nameTag
        else
            -- Update the name tag if showNamesEnabled is toggled
            local textLabel = nameTag:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.TextColor3 = teamColor -- Update text color
            end
        end
    end
end

-- Function to handle player spawning and respawning
local function onCharacterAdded(character)
    if highlightingEnabled then
        highlightPlayer(character)
    end
end

-- Function to connect to all existing and future players
local function setupPlayer(player)
    -- Connect the CharacterAdded event to handle respawns
    player.CharacterAdded:Connect(onCharacterAdded)

    -- Highlight the player's character if it already exists
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Re-highlight function
local function rehighlightPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if not highlight then
                highlightPlayer(player.Character)
            end
        end
    end
end

-- Auto Re-highlight loop
local function autoRehighlightLoop()
    while not stopAutoRehighlightLoop do
        rehighlightPlayers()
        wait(autoRehighlightInterval)
    end
end

-- Auto re-highlight loop thread
local autoRehighlightThread = nil

-- Toggle button function
toggleButton.MouseButton1Click:Connect(function()
    highlightingEnabled = not highlightingEnabled
    toggleButton.Text = "Toggle Highlight: " .. (highlightingEnabled and "ON" or "OFF")

    -- Remove or add highlights based on the toggle state
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlightingEnabled and not highlight then
                highlightPlayer(player.Character)
            elseif not highlightingEnabled and highlight then
                highlight:Destroy()
            end
        end
    end
end)

-- Re-highlight button function
rehighlightButton.MouseButton1Click:Connect(rehighlightPlayers)

-- Auto Re-highlight toggle button function
autoRehighlightButton.MouseButton1Click:Connect(function()
    autoRehighlightEnabled = not autoRehighlightEnabled
    autoRehighlightButton.Text = "Auto Re-highlight: " .. (autoRehighlightEnabled and "ON" or "OFF")

    if autoRehighlightEnabled and not autoRehighlightThread then
        stopAutoRehighlightLoop = false
        autoRehighlightThread = spawn(autoRehighlightLoop)  -- Start the loop if it was turned on
    elseif not autoRehighlightEnabled and autoRehighlightThread then
        stopAutoRehighlightLoop = true
        autoRehighlightThread = nil
    end
end)

-- Interval textbox function
intervalTextBox.FocusLost:Connect(function()
    local intervalValue = tonumber(intervalTextBox.Text)
    if intervalValue and intervalValue > 0 then
        autoRehighlightInterval = intervalValue
    end
end)

-- Show names toggle button function
showNamesButton.MouseButton1Click:Connect(function()
    showNamesEnabled = not showNamesEnabled
    showNamesButton.Text = "Show Names: " .. (showNamesEnabled and "ON" or "OFF")

    -- Update existing players to show/hide names based on the toggle state
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local nameTag = player.Character:FindFirstChild("NameTag")
            if showNamesEnabled and not nameTag then
                highlightPlayer(player.Character) -- Reapply highlight to create name tag
            elseif not showNamesEnabled and nameTag then
                nameTag:Destroy()
            end
        end
    end
end)

-- Unload button function
unloadButton.MouseButton1Click:Connect(function()
    -- Remove highlights and names from all players
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
            local nameTag = player.Character:FindFirstChild("NameTag")
            if nameTag then
                nameTag:Destroy()
            end
        end
    end

    -- Stop the auto-rehighlight loop
    stopAutoRehighlightLoop = true
    autoRehighlightThread = nil

    -- Remove the GUI
    screenGui:Destroy()
end)

-- Connect to all players currently in the game
for _, player in pairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Connect to any new players that join the game
Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
end)
