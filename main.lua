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
gui.Parent = playerGui

local function round(inst, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = inst
end

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(600, 500) -- Larger size
frame.Position = UDim2.fromOffset(20, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Darker background
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

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Cortege Manager"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Scrollable Content Area
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, -20, 1, -70) -- Leaves space for header and footer
scrollContainer.Position = UDim2.fromOffset(10, 60)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 6
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollContainer.Parent = frame
round(scrollContainer, 8) -- Rounds the inner content slightly

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = scrollContainer

-- Helper Functions for Consistent UI
local function makeTextBox(placeholder, position, width)
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
	box.Parent = scrollContainer
	round(box, 6)
	return box
end

local function makeButton(text, position, size, color)
	local button = Instance.new("TextButton")
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color or Color3.fromRGB(60, 80, 120)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.Parent = scrollContainer
	round(button, 6)
	return button
end

local function makeLabel(text, position)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(180, 180, 190)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = scrollContainer
	return label
end

-- --- SECTION 1: ACCOUNT MANAGEMENT ---

makeLabel("Account Management", UDim2.fromOffset(10, 0))

local mainInput = makeTextBox("Main username", UDim2.fromOffset(10, 30), 200)
local addMain = makeButton("Add Main", UDim2.fromOffset(220, 30), UDim2.fromOffset(100, 36), Color3.fromRGB(50, 100, 150))

local altInput = makeTextBox("Alt username", UDim2.fromOffset(10, 70), 200)
local addAlt = makeButton("Add Alt", UDim2.fromOffset(220, 70), UDim2.fromOffset(100, 36), Color3.fromRGB(50, 100, 150))

-- --- SECTION 2: COMMANDS ---

makeLabel("Command Controls", UDim2.fromOffset(10, 120))

local commandToggle = makeButton(
	"Command Toggle: ON",
	UDim2.fromOffset(10, 150),
	UDim2.new(1, -20, 0, 36),
	Color3.fromRGB(50, 120, 70)
)

local sayInput = makeTextBox("Say", UDim2.fromOffset(10, 195), 200)
local sayButton = makeButton("Say", UDim2.fromOffset(220, 195), UDim2.fromOffset(100, 36), Color3.fromRGB(60, 80, 120))

-- --- SECTION 3: LOOP ---

makeLabel("Auto Loop", UDim2.fromOffset(10, 245))

local loopSeconds = makeTextBox("Secs", UDim2.fromOffset(10, 285), 70)
local loopCommand = makeTextBox("Command", UDim2.fromOffset(90, 285), 200)

local startLoopButton = makeButton("Start Loop", UDim2.fromOffset(10, 330), UDim2.fromOffset(180, 36), Color3.fromRGB(60, 100, 150))
local stopLoopButton = makeButton("Stop Loop", UDim2.fromOffset(200, 330), UDim2.fromOffset(180, 36), Color3.fromRGB(120, 50, 50))

-- --- SECTION 4: GRIEF MANAGEMENT (New) ---

makeLabel("Grief Management", UDim2.fromOffset(10, 385))

local selectDRow = makeTextBox("Select Players (comma sep)", UDim2.fromOffset(10, 420), 400)

local toggleGriefButton = makeButton("Start Grief", UDim2.fromOffset(10, 465), UDim2.new(1, -20, 0, 36), Color3.fromRGB(150, 50, 50))

-- --- NEW GRIEF LOGIC (Integrated) ---

local LocalPlayer = Players.LocalPlayer
local isGriefing = false
local griefLoop = nil

local TEXT_START = "Start Grief"
local TEXT_STOP = "Stop Grief"
local TEXT_NO_BLOCKS = "No Blocks Found"
local TEXT_TOOL_MISSING = "Delete tool not found"
local TEXT_NO_PLAYERS = "No players selected"

local ws = 0.05

local function getSelectedPlayers()
    local text = selectDRow.Text
    if not text or text == "" then return {} end
    
    local players = {}
    for name in string.gmatch(text, "[^,]+") do
        local trimmed = name:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            players[trimmed] = true
        end
    end
    return players
end

local function getAllTargetBlocks()
    local blocks = {}
    local selectedPlayers = getSelectedPlayers()
    local bricksFolder = workspace:FindFirstChild("Bricks")
    if not bricksFolder then return blocks end

    for playerName, _ in pairs(selectedPlayers) do
        local playerFolder = bricksFolder:FindFirstChild(playerName)
        if playerFolder then
            for _, brick in ipairs(playerFolder:GetChildren()) do
                if brick:IsA("BasePart") and brick.Name == "Brick" then
                    table.insert(blocks, brick)
                end
            end
        end
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.sort(blocks, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
    end
    return blocks
end

local function findDeleteTools()
    local dtools = {}
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name == "Delete" and v:FindFirstChild("Script") and v.Script:FindFirstChild("Event") then
            table.insert(dtools, {bt = v, e = v.Script.Event})
        end
    end
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") and v.Name == "Delete" and v:FindFirstChild("Script") and v.Script:FindFirstChild("Event") then
                table.insert(dtools, {bt = v, e = v.Script.Event})
            end
        end
    end
    return dtools
end

local function startGrief()
    local dtools = findDeleteTools()
    if #dtools == 0 then
        toggleGriefButton.Text = TEXT_TOOL_MISSING
        task.wait(1)
        toggleGriefButton.Text = TEXT_START
        return
    end

    local selectedPlayers = getSelectedPlayers()
    if not next(selectedPlayers) then
        toggleGriefButton.Text = TEXT_NO_PLAYERS
        task.wait(1)
        toggleGriefButton.Text = TEXT_START
        return
    end

    isGriefing = true
    toggleGriefButton.Text = TEXT_STOP

    griefLoop = task.spawn(function()
        local lastRefreshTime = 0
        if shared.DeleteToolRefresh then shared.DeleteToolRefresh() end
        lastRefreshTime = tick()

        while isGriefing do
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait() continue end

            local dtools = findDeleteTools()
            if #dtools > 0 then
                local targetBlocks = getAllTargetBlocks()
                if #targetBlocks > 0 then
                    if tick() - lastRefreshTime >= 5 then
                        if shared.DeleteToolRefresh then shared.DeleteToolRefresh() end
                        lastRefreshTime = tick()
                    end
                    
                    for _, toolData in ipairs(dtools) do
                        for _, block in ipairs(targetBlocks) do
                            if toolData.e then
                                toolData.e:FireServer(block)
                            end
                            task.wait(ws)
                        end
                    end
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

local function stopGrief()
    isGriefing = false
    if griefLoop then
        griefLoop:cancel()
        griefLoop = nil
    end
    toggleGriefButton.Text = TEXT_START
end

toggleGriefButton.MouseButton1Click:Connect(function()
    if isGriefing then
        stopGrief()
    else
        startGrief()
    end
end)
