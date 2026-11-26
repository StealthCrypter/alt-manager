local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- Clean up old GUI
for _, old in ipairs(playerGui:GetChildren()) do
	if old.Name == "AltManagerGUI" then
		old:Destroy()
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "AltManagerGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function round(inst, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = inst
end

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(600, 500)
frame.Position = UDim2.fromOffset(20, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = gui
round(frame, 12)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
header.BorderSizePixel = 0
header.Parent = frame
round(header, 12)

-- Masks the bottom corners of the header so it reads as a flat top bar, not a floating rounded pill
local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 0, 12)
headerMask.Position = UDim2.new(0, 0, 1, -12)
headerMask.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
headerMask.BorderSizePixel = 0
headerMask.ZIndex = header.ZIndex
headerMask.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "Cortege Manager"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = header

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Position = UDim2.new(1, -41, 0.5, -16)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
closeButton.BorderSizePixel = 0
closeButton.Text = "x"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.ZIndex = 2
closeButton.Parent = header
round(closeButton, 16)

closeButton.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

-- Scrollable Content Area
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, -20, 1, -70)
scrollContainer.Position = UDim2.fromOffset(10, 60)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 6
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollContainer.CanvasSize = UDim2.new()
scrollContainer.Parent = frame
round(scrollContainer, 8)

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 15)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = scrollContainer

local layoutPadding = Instance.new("UIPadding")
layoutPadding.PaddingBottom = UDim.new(0, 15)
layoutPadding.Parent = scrollContainer

-- A "section" is its own Frame with auto height, so rows inside it
-- lay out independently of the page-level UIListLayout above.
local function makeSection(height)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, height)
	section.BackgroundTransparency = 1
	section.LayoutOrder = (makeSection.count or 0)
	makeSection.count = (makeSection.count or 0) + 1
	section.Parent = scrollContainer
	return section
end

local function makeTextBox(parent, placeholder, position, width)
	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(width or 200, 36)
	box.Position = position
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	box.BorderSizePixel = 0
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
	box.Text = ""
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = parent
	round(box, 6)
	return box
end

local function makeButton(parent, text, position, size, color)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color or Color3.fromRGB(60, 80, 120)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.AutoButtonColor = true
	button.Parent = parent
	round(button, 6)
	return button
end

local function makeLabel(parent, text, position)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(180, 180, 190)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

-- --- SECTION 1: ACCOUNT MANAGEMENT ---

local accountsSection = makeSection(160)
makeLabel(accountsSection, "Account Management", UDim2.fromOffset(10, 0))

local mainInput = makeTextBox(accountsSection, "Main username", UDim2.fromOffset(10, 30), 200)
local addMain = makeButton(accountsSection, "Add Main", UDim2.fromOffset(220, 30), UDim2.fromOffset(100, 36), Color3.fromRGB(50, 100, 150))

local altInput = makeTextBox(accountsSection, "Alt username", UDim2.fromOffset(10, 70), 200)
local addAlt = makeButton(accountsSection, "Add Alt", UDim2.fromOffset(220, 70), UDim2.fromOffset(100, 36), Color3.fromRGB(50, 100, 150))

local accountListLabel = makeLabel(accountsSection, "Saved Accounts", UDim2.fromOffset(10, 112))

local mainAccounts, altAccounts = {}, {}

local function refreshAccountListLabel()
	local parts = {}
	for _, n in ipairs(mainAccounts) do table.insert(parts, "[M] " .. n) end
	for _, n in ipairs(altAccounts) do table.insert(parts, "[A] " .. n) end
	accountListLabel.Text = #parts > 0 and table.concat(parts, "   ") or "Saved Accounts: none yet"
end
refreshAccountListLabel()

addMain.MouseButton1Click:Connect(function()
	local name = mainInput.Text:match("^%s*(.-)%s*$")
	if name == "" then return end
	table.insert(mainAccounts, name)
	mainInput.Text = ""
	refreshAccountListLabel()
end)

addAlt.MouseButton1Click:Connect(function()
	local name = altInput.Text:match("^%s*(.-)%s*$")
	if name == "" then return end
	table.insert(altAccounts, name)
	altInput.Text = ""
	refreshAccountListLabel()
end)

-- --- SECTION 2: COMMANDS ---

local commandsSection = makeSection(120)
makeLabel(commandsSection, "Command Controls", UDim2.fromOffset(10, 0))

local commandEnabled = true
local commandToggle = makeButton(
	commandsSection,
	"Command Toggle: ON",
	UDim2.fromOffset(10, 30),
	UDim2.new(1, -20, 0, 36),
	Color3.fromRGB(50, 120, 70)
)

commandToggle.MouseButton1Click:Connect(function()
	commandEnabled = not commandEnabled
	commandToggle.Text = "Command Toggle: " .. (commandEnabled and "ON" or "OFF")
	commandToggle.BackgroundColor3 = commandEnabled
		and Color3.fromRGB(50, 120, 70)
		or Color3.fromRGB(120, 60, 60)
end)

local sayInput = makeTextBox(commandsSection, "Say", UDim2.fromOffset(10, 75), 200)
local sayButton = makeButton(commandsSection, "Say", UDim2.fromOffset(220, 75), UDim2.fromOffset(100, 36), Color3.fromRGB(60, 80, 120))

sayButton.MouseButton1Click:Connect(function()
	if not commandEnabled then return end
	local text = sayInput.Text
	if text == "" then return end
	-- Hook your actual chat/command dispatch here.
	sayInput.Text = ""
end)

-- --- SECTION 3: LOOP ---

local loopSection = makeSection(165)
makeLabel(loopSection, "Auto Loop", UDim2.fromOffset(10, 0))

local loopSeconds = makeTextBox(loopSection, "Secs", UDim2.fromOffset(10, 40), 70)
local loopCommand = makeTextBox(loopSection, "Command", UDim2.fromOffset(90, 40), 200)

local startLoopButton = makeButton(loopSection, "Start Loop", UDim2.fromOffset(10, 85), UDim2.fromOffset(180, 36), Color3.fromRGB(60, 100, 150))
local stopLoopButton = makeButton(loopSection, "Stop Loop", UDim2.fromOffset(200, 85), UDim2.fromOffset(180, 36), Color3.fromRGB(120, 50, 50))

local loopTask = nil

local function stopLoop()
	if loopTask then
		task.cancel(loopTask)
		loopTask = nil
	end
	startLoopButton.Text = "Start Loop"
end

startLoopButton.MouseButton1Click:Connect(function()
	if loopTask then
		stopLoop()
		return
	end

	local secs = tonumber(loopSeconds.Text)
	if not secs or secs <= 0 then
		startLoopButton.Text = "Bad interval"
		task.wait(1)
		startLoopButton.Text = "Start Loop"
		return
	end

	local cmd = loopCommand.Text
	if cmd == "" then
		startLoopButton.Text = "No command"
		task.wait(1)
		startLoopButton.Text = "Start Loop"
		return
	end

	startLoopButton.Text = "Stop Loop (running)"
	loopTask = task.spawn(function()
		while true do
			if commandEnabled then
				-- Hook your actual command dispatch here using `cmd`.
			end
			task.wait(secs)
		end
	end)
end)

stopLoopButton.MouseButton1Click:Connect(function()
	stopLoop()
end)
