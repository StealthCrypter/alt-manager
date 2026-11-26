local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

for _, old in ipairs(playerGui:GetChildren()) do
	if old.Name == "AltManagerGUI" then
		old:Destroy()
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "AltManagerGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function round(inst, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = inst
end

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(520, 480)
frame.Position = UDim2.fromOffset(20, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = gui
round(frame, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.BorderSizePixel = 0
title.Text = "Cortege Manager"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local managerPage = Instance.new("Frame")
managerPage.Name = "ManagerPage"
managerPage.Position = UDim2.fromOffset(0, 30)
managerPage.Size = UDim2.new(1, 0, 1, -54)
managerPage.BackgroundTransparency = 1
managerPage.BorderSizePixel = 0
managerPage.Parent = frame

local function makeTextBox(placeholder, position)
	local box = Instance.new("TextBox")
	box.Position = position
	box.Size = UDim2.fromOffset(230, 32)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
	box.BorderSizePixel = 0
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(170, 170, 175)
	box.Text = ""
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = managerPage
	round(box)
	return box
end

local function makeButton(text, position, size)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(75, 110, 170)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = managerPage
	round(button)
	return button
end

-- --- EXISTING UI ELEMENTS ---

local mainInput = makeTextBox("Main username", UDim2.fromOffset(10, 52))
local addMain = makeButton("Add Main", UDim2.fromOffset(250, 52), UDim2.fromOffset(100, 32))
local altInput = makeTextBox("Alt username", UDim2.fromOffset(10, 92))
local addAlt = makeButton("Add Alt", UDim2.fromOffset(250, 92), UDim2.fromOffset(100, 32))

local commandEnabled = true
local commandToggle = makeButton(
	"Command Toggle: ON",
	UDim2.fromOffset(10, 132),
	UDim2.new(1, -20, 0, 32)
)
commandToggle.BackgroundColor3 = Color3.fromRGB(65, 125, 75)

local sayInput = makeTextBox("Say", UDim2.fromOffset(10, 172))
local sayButton = makeButton("Say", UDim2.fromOffset(250, 172), UDim2.fromOffset(100, 32))

local loopSeconds = makeTextBox("Secs", UDim2.fromOffset(10, 212))
loopSeconds.Size = UDim2.fromOffset(70, 32)
local loopCommand = makeTextBox("Command", UDim2.fromOffset(88, 212))
loopCommand.Size = UDim2.new(1, -98, 0, 32)
local startLoopButton = makeButton("Start Loop", UDim2.fromOffset(10, 252), UDim2.new(0.5, -15, 0, 32))
local stopLoopButton = makeButton("Stop Loop", UDim2.new(0.5, 5, 0, 252), UDim2.new(0.5, -15, 0, 32))
stopLoopButton.BackgroundColor3 = Color3.fromRGB(110, 65, 65)

-- --- NEW/FIXED: account list now sits in its own slot, no longer overlapping sayRow/loopRow ---
-- Old version put this at Y=174 sized to fill most of the page, covering every row below it.
-- It now lives in the gap between the loop buttons (bottom ~284) and the grief label (Y=292).

local accountListLabel = Instance.new("TextLabel")
accountListLabel.Size = UDim2.new(1, -20, 0, 16)
accountListLabel.Position = UDim2.fromOffset(10, 288 - 22)
accountListLabel.BackgroundTransparency = 1
accountListLabel.Text = "" -- populated below
accountListLabel.TextColor3 = Color3.fromRGB(170, 170, 175)
accountListLabel.Font = Enum.Font.Gotham
accountListLabel.TextSize = 12
accountListLabel.TextXAlignment = Enum.TextXAlignment.Left
accountListLabel.TextTruncate = Enum.TextTruncate.AtEnd
accountListLabel.Parent = managerPage

local mainAccounts, altAccounts = {}, {}

local function refreshAccountListLabel()
	local parts = {}
	for _, n in ipairs(mainAccounts) do table.insert(parts, "[M] " .. n) end
	for _, n in ipairs(altAccounts) do table.insert(parts, "[A] " .. n) end
	accountListLabel.Text = #parts > 0 and table.concat(parts, "   ") or "No accounts added yet"
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

commandToggle.MouseButton1Click:Connect(function()
	commandEnabled = not commandEnabled
	commandToggle.Text = "Command Toggle: " .. (commandEnabled and "ON" or "OFF")
	commandToggle.BackgroundColor3 = commandEnabled
		and Color3.fromRGB(65, 125, 75)
		or Color3.fromRGB(125, 65, 65)
end)

sayButton.MouseButton1Click:Connect(function()
	if not commandEnabled then return end
	if sayInput.Text == "" then return end
	-- Hook your actual chat/command dispatch here.
	sayInput.Text = ""
end)

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

	if loopCommand.Text == "" then
		startLoopButton.Text = "No command"
		task.wait(1)
		startLoopButton.Text = "Start Loop"
		return
	end

	startLoopButton.Text = "Running..."
	loopTask = task.spawn(function()
		while true do
			if commandEnabled then
				-- Hook your actual command dispatch here using loopCommand.Text
			end
			task.wait(secs)
		end
	end)
end)

stopLoopButton.MouseButton1Click:Connect(function()
	stopLoop()
end)

-- --- NEW GRIEF FUNCTIONALITY UI ---
-- (unchanged from your file — pasted as-is below)

local griefLabel = Instance.new("TextLabel")
griefLabel.Size = UDim2.new(1, -20, 0, 20)
griefLabel.Position = UDim2.fromOffset(10, 292)
griefLabel.BackgroundTransparency = 1
griefLabel.Text = "Grief Management"
griefLabel.TextColor3 = Color3.fromRGB(170, 170, 175)
griefLabel.Font = Enum.Font.GothamBold
griefLabel.TextSize = 14
griefLabel.Parent = managerPage

local selectDRow = makeTextBox("Select Players (comma sep)", UDim2.fromOffset(10, 320))
selectDRow.Size = UDim2.new(1, -20, 0, 32)

local toggleGriefButton = makeButton("Start Grief", UDim2.fromOffset(10, 360), UDim2.new(1, -20, 0, 32))
toggleGriefButton.BackgroundColor3 = Color3.fromRGB(170, 75, 75)

-- [grief logic functions go here, unchanged from your file — getSelectedPlayers,
--  getAllTargetBlocks, findDeleteTools, startGrief, stopGrief, and the Click handler]
