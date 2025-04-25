--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Core Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local LockOnEnabled = false
local LockOnActive = false
local TargetPlayer = nil
local GuiAlive = true
local CircleRadius = 100

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "LockOnGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromOffset(300, 200)
Frame.Position = UDim2.fromOffset(10, 10)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.3
Frame.Active = true
Frame.Draggable = true

local function createButton(name, position, text, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 280, 0, 50)
	btn.Position = UDim2.fromOffset(10, position)
	btn.Text = text
	btn.TextScaled = true
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = Frame
	return btn
end

local ToggleBtn = createButton("ToggleBtn", 10, "Lock-On: OFF", Color3.new(0, 0, 0))
local DestroyBtn = createButton("DestroyBtn", 70, "Destroy GUI", Color3.new(0.5, 0, 0))

local RadiusContainer = Instance.new("Frame", Frame)
RadiusContainer.Size = UDim2.new(0, 280, 0, 50)
RadiusContainer.Position = UDim2.fromOffset(10, 130)
RadiusContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local RadiusLabel = Instance.new("TextLabel", RadiusContainer)
RadiusLabel.Size = UDim2.new(1, 0, 1, 0)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.TextScaled = true
RadiusLabel.TextColor3 = Color3.new(1, 1, 1)
RadiusLabel.Text = "Circle Radius: " .. CircleRadius

local RadiusBox = Instance.new("TextBox", RadiusContainer)
RadiusBox.Size = UDim2.new(0, 100, 1, 0)
RadiusBox.Position = UDim2.new(0.5, -50, 0, 0)
RadiusBox.TextScaled = true
RadiusBox.Text = tostring(CircleRadius)
RadiusBox.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)

--// Utility: Check if screen pos inside radius
local function insideCircle(screenPos, center, radius)
	return (screenPos - center).Magnitude <= radius
end

--// Get closest enemy player within circle
local function getClosestTarget()
	local closest = nil
	local minDist = math.huge
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team then
			local char = plr.Character
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if head and hum and hum.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen and insideCircle(Vector2.new(screenPos.X, screenPos.Y), mousePos, CircleRadius) then
					local dist = (head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
					if dist < minDist then
						minDist = dist
						closest = plr
					end
				end
			end
		end
	end

	return closest
end

--// Lock-on logic
local function lockOnTarget()
	if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
		local camPos = Camera.CFrame.Position
		local targetPos = TargetPlayer.Character.Head.Position
		Camera.CFrame = CFrame.new(camPos, targetPos)
	end
end

--// Input Handlers
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		LockOnActive = true
		if LockOnEnabled then
			TargetPlayer = getClosestTarget()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		LockOnActive = false
		TargetPlayer = nil
	end
end)

--// UI Button Bindings
ToggleBtn.MouseButton1Click:Connect(function()
	LockOnEnabled = not LockOnEnabled
	ToggleBtn.Text = "Lock-On: " .. (LockOnEnabled and "ON" or "OFF")
end)

DestroyBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
	GuiAlive = false
	LockOnEnabled = false
	LockOnActive = false
	TargetPlayer = nil
end)

RadiusBox.FocusLost:Connect(function()
	local input = tonumber(RadiusBox.Text)
	if input and input >= 50 and input <= 200 then
		CircleRadius = input
		RadiusLabel.Text = "Circle Radius: " .. CircleRadius
	else
		RadiusBox.Text = tostring(CircleRadius)
	end
end)

--// Main render loop
RunService.RenderStepped:Connect(function()
	if GuiAlive and LockOnEnabled and LockOnActive and TargetPlayer then
		lockOnTarget()
	end
end)
