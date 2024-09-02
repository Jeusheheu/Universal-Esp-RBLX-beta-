-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- Variables
local highlightingEnabled = true
local autoReloadEnabled = false
local autoReloadInterval = 5 -- Default interval (seconds)
local autoReloadThread -- Variable to keep track of the auto-reload coroutine
local guiTitle = "Player Highlight Toggle" -- Title of the GUI

-- Create a UI container for the buttons (making it draggable)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local draggableFrame = Instance.new("Frame")
draggableFrame.Size = UDim2.new(0, 300, 0, 270)  -- Adjusted size to fit title and all buttons
draggableFrame.Position = UDim2.new(0, 10, 0, 10)
draggableFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
draggableFrame.BackgroundTransparency = 0.3
draggableFrame.Active = true  -- Allows the frame to be draggable
draggableFrame.Draggable = true  -- Makes the frame draggable
draggableFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)  -- Title takes full width of the frame
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "Universal ESP by Jeus"
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

local autoReloadButton = Instance.new("TextButton")
autoReloadButton.Size = UDim2.new(0, 280, 0, 50)
autoReloadButton.Position = UDim2.new(0, 10, 0, 110)  -- Positioned below the toggle button
autoReloadButton.Text = "Auto-Reload: OFF"
autoReloadButton.TextScaled = true
autoReloadButton.BackgroundColor3 = Color3.new(0, 0, 1)
autoReloadButton.TextColor3 = Color3.new(1, 1, 1)
autoReloadButton.Parent = draggableFrame

local intervalLabel = Instance.new("TextLabel")
intervalLabel.Size = UDim2.new(0, 280, 0, 30)
intervalLabel.Position = UDim2.new(0, 10, 0, 170)  -- Positioned below the auto-reload button
intervalLabel.Text = "Reload Interval (s):"
intervalLabel.TextScaled = true
intervalLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
intervalLabel.TextColor3 = Color3.new(1, 1, 1)
intervalLabel.Parent = draggableFrame

local intervalInput = Instance.new("TextBox")
intervalInput.Size = UDim2.new(0, 280, 0, 50)
intervalInput.Position = UDim2.new(0, 10, 0, 200)  -- Positioned below the interval label
intervalInput.Text = tostring(autoReloadInterval)
intervalInput.TextScaled = true
intervalInput.BackgroundColor3 = Color3.new(1, 1, 1)
intervalInput.TextColor3 = Color3.new(0, 0, 0)
intervalInput.Parent = draggableFrame

local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0, 280, 0, 50)
unloadButton.Position = UDim2.new(0, 10, 0, 260)  -- Positioned below the interval input
unloadButton.Text = "Unload Script"
unloadButton.TextScaled = true
unloadButton.BackgroundColor3 = Color3.new(1, 0, 0)
unloadButton.TextColor3 = Color3.new(1, 1, 1)
unloadButton.Parent = draggableFrame

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
    highlight.FillColor = Color3.new(1, 1, 0) -- Yellow color
    highlight.OutlineColor = Color3.new(0, 0, 0) -- Black outline
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0

    -- Attach the highlight to the player's character
    highlight.Adornee = character
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

-- Function to auto-reload highlights at regular intervals
local function startAutoReload()
    while autoReloadEnabled do
        -- Wait for the specified interval
        wait(autoReloadInterval)

        -- Apply highlights to all existing characters if auto-reloading is enabled
        if autoReloadEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and highlightingEnabled then
                    local highlight = player.Character:FindFirstChild("Highlight")
                    if not highlight then
                        highlightPlayer(player.Character)
                    end
                end
            end
        end
    end
end

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

-- Auto-reload button function
autoReloadButton.MouseButton1Click:Connect(function()
    autoReloadEnabled = not autoReloadEnabled
    autoReloadButton.Text = "Auto-Reload: " .. (autoReloadEnabled and "ON" or "OFF")

    -- Start or stop the auto-reload process
    if autoReloadEnabled then
        if not autoReloadThread then
            autoReloadThread = coroutine.create(startAutoReload)
            coroutine.resume(autoReloadThread)
        end
    else
        if autoReloadThread then
            autoReloadThread = nil
        end
    end
end)

-- Interval input change handler
intervalInput.FocusLost:Connect(function()
    local interval = tonumber(intervalInput.Text)
    if interval and interval > 0 then
        autoReloadInterval = interval
    else
        intervalInput.Text = tostring(autoReloadInterval)
    end
end)

-- Unload button function
unloadButton.MouseButton1Click:Connect(function()
    -- Stop auto-reloading
    autoReloadEnabled = false
    autoReloadThread = nil

    -- Remove highlights from all players
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end

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
    if autoReloadEnabled and player.Character then
        highlightPlayer(player.Character)
    end
end)
