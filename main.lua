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
frame.Size = UDim2.fromOffset(520, 480) -- Increased height slightly to fit new content
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

-- --- NEW GRIEF FUNCTIONALITY UI ---

-- Label for the new section
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
toggleGriefButton.BackgroundColor3 = Color3.fromRGB(170, 75, 75) -- Reddish for danger/grief

local accountList = Instance.new("ScrollingFrame")
accountList.Position = UDim2.fromOffset(10, 174)
accountList.Size = UDim2.new(1, -20, 1, -224)
accountList.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
accountList.BorderSizePixel = 0
accountList.ScrollBarThickness = 6
accountList.CanvasSize = UDim2.new()
accountList.Parent = managerPage
round(accountList)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = accountList

-- --- NEW GRIEF LOGIC ---

local LocalPlayer = Players.LocalPlayer
local isGriefing = false
local griefLoop = nil

local TEXT_START = "Start Grief"
local TEXT_STOP = "Stop Grief"
local TEXT_NO_BLOCKS = "No Blocks Found"
local TEXT_TOOL_MISSING = "Delete tool not found"
local TEXT_NO_PLAYERS = "No players selected"

local ws = 0.05 -- wait-time budget per delete pass

-- Reads whichever players were checked in the dropdown/textbox
local function getSelectedPlayers()
    local text = selectDRow.Text
    if not text or text == "" then return {} end
    
    local players = {}
    for name in string.gmatch(text, "[^,]+") do
        local trimmed = name:match("^%s*(.-)%s*$") -- trim whitespace
        if trimmed ~= "" then
            players[trimmed] = true
        end
    end
    return players
end

-- Collects every block belonging to the selected players, nearest first
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

-- Finds the game's real "Delete" tool and grabs its RemoteEvent
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
        local dti = 0
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
                    
                    -- Simulate the rest of the loop logic based on your snippet
                    for _, toolData in ipairs(dtools) do
                        for _, block in ipairs(targetBlocks) do
                            -- Assuming the event fires the delete
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

-- Optional: Add a simple listener to update the button text if needed elsewhere
-- You can also bind this to a keybind if desired
