-- LocalScript
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AltManagerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(360, 360)
frame.Position = UDim2.fromOffset(20, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.Text = "Alt Manager"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function makeTextBox(placeholder, position)
	local textBox = Instance.new("TextBox")
	textBox.Position = position
	textBox.Size = UDim2.fromOffset(230, 32)
	textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
	textBox.BorderSizePixel = 0
	textBox.PlaceholderText = placeholder
	textBox.PlaceholderColor3 = Color3.fromRGB(170, 170, 175)
	textBox.Text = ""
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 14
	textBox.ClearTextOnFocus = false
	textBox.Parent = frame
	return textBox
end

local function makeButton(text, position, size)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = size or UDim2.fromOffset(90, 32)
	button.BackgroundColor3 = Color3.fromRGB(75, 110, 170)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = frame
	return button
end

local mainInput = makeTextBox("Main username", UDim2.fromOffset(10, 52))
local addMainButton = makeButton("Add Main", UDim2.fromOffset(250, 52))
local altInput = makeTextBox("Alt username", UDim2.fromOffset(10, 92))
local addAltButton = makeButton("Add Alt", UDim2.fromOffset(250, 92))

local commandEnabled = false
local commandToggle = makeButton("Command Toggle: OFF", UDim2.fromOffset(10, 132), UDim2.new(1, -20, 0, 32))
commandToggle.BackgroundColor3 = Color3.fromRGB(110, 65, 65)

local list = Instance.new("TextLabel")
list.Position = UDim2.fromOffset(10, 174)
list.Size = UDim2.new(1, -20, 1, -184)
list.BackgroundTransparency = 1
list.TextXAlignment = Enum.TextXAlignment.Left
list.TextYAlignment = Enum.TextYAlignment.Top
list.TextWrapped = true
list.TextColor3 = Color3.fromRGB(220, 220, 220)
list.Font = Enum.Font.Gotham
list.TextSize = 14
list.Parent = frame

-- Names are kept in this local table for this session only.
local Accounts = {}

local function refresh()
	local lines = {}
	for i, account in ipairs(Accounts) do
		table.insert(lines, string.format("%d. [%s] %s", i, account.Role, account.Name))
	end
	list.Text = #lines > 0 and table.concat(lines, "\n") or "No usernames added yet."
end

local function addAccount(textBox, role)
	local username = textBox.Text:match("^%s*(.-)%s*$")
	if username == "" then
		return
	end

	table.insert(Accounts, {
		Name = username,
		Role = role,
	})
	textBox.Text = ""
	refresh()
end

addMainButton.Activated:Connect(function()
	addAccount(mainInput, "Main")
end)

addAltButton.Activated:Connect(function()
	addAccount(altInput, "Alt")
end)

commandToggle.Activated:Connect(function()
	commandEnabled = not commandEnabled
	commandToggle.Text = commandEnabled and "Command Toggle: ON" or "Command Toggle: OFF"
	commandToggle.BackgroundColor3 = commandEnabled
		and Color3.fromRGB(65, 125, 75)
		or Color3.fromRGB(110, 65, 65)
end)

refresh()
