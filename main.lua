-- LocalScript UI
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = player:FindFirstChild("AltManagerGUI")
if gui then
	gui:Destroy()
end

gui = Instance.new("ScreenGui")
gui.Name = "AltManagerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(360, 430)
frame.Position = UDim2.fromOffset(20, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
title.BorderSizePixel = 0
title.Text = "Alt Manager"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

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
	box.Parent = frame
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
	button.Parent = frame
	return button
end

local mainInput = makeTextBox("Main username", UDim2.fromOffset(10, 52))
local addMain = makeButton("Add Main", UDim2.fromOffset(250, 52), UDim2.fromOffset(100, 32))
local altInput = makeTextBox("Alt username", UDim2.fromOffset(10, 92))
local addAlt = makeButton("Add Alt", UDim2.fromOffset(250, 92), UDim2.fromOffset(100, 32))

local commandEnabled = false
local commandToggle = makeButton(
	"Command Toggle: OFF",
	UDim2.fromOffset(10, 132),
	UDim2.new(1, -20, 0, 32)
)
commandToggle.BackgroundColor3 = Color3.fromRGB(110, 65, 65)

local sayInput = makeTextBox("Say something in chat", UDim2.fromOffset(10, 172))
local sayButton = makeButton("Say", UDim2.fromOffset(250, 172), UDim2.fromOffset(100, 32))

local accountList = Instance.new("ScrollingFrame")
accountList.Position = UDim2.fromOffset(10, 214)
accountList.Size = UDim2.new(1, -20, 1, -264)
accountList.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
accountList.BorderSizePixel = 0
accountList.ScrollBarThickness = 6
accountList.CanvasSize = UDim2.new()
accountList.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = accountList

local removeButton = makeButton(
	"Remove Selected",
	UDim2.new(0, 10, 1, -40),
	UDim2.new(1, -20, 0, 30)
)
removeButton.BackgroundColor3 = Color3.fromRGB(160, 70, 70)

-- Local display data only; it is not saved and does not represent authenticated accounts.
local accounts = {}
local selectedIndex

local function refresh()
	for _, child in ipairs(accountList:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	if #accounts == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, -8, 0, 28)
		empty.BackgroundTransparency = 1
		empty.Text = "No usernames added yet."
		empty.TextColor3 = Color3.fromRGB(190, 190, 195)
		empty.Font = Enum.Font.Gotham
		empty.TextSize = 14
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.LayoutOrder = 1
		empty.Parent = accountList
	else
		for index, account in ipairs(accounts) do
			local entry = Instance.new("TextButton")
			entry.Size = UDim2.new(1, -8, 0, 30)
			entry.BackgroundColor3 = index == selectedIndex
				and Color3.fromRGB(75, 95, 125)
				or Color3.fromRGB(50, 50, 57)
			entry.BorderSizePixel = 0
			entry.Text = ("[%s] %s"):format(account.Role, account.Name)
			entry.TextColor3 = Color3.new(1, 1, 1)
			entry.Font = Enum.Font.Gotham
			entry.TextSize = 14
			entry.TextXAlignment = Enum.TextXAlignment.Left
			entry.LayoutOrder = index
			entry.Parent = accountList

			entry.Activated:Connect(function()
				selectedIndex = index
				refresh()
			end)
		end
	end

	accountList.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 4)
end

local function addAccount(box, role)
	local name = box.Text:match("^%s*(.-)%s*$")
	if name == "" then
		return
	end

	table.insert(accounts, { Name = name, Role = role })
	selectedIndex = #accounts
	box.Text = ""
	refresh()
end

addMain.Activated:Connect(function()
	addAccount(mainInput, "Main")
end)

addAlt.Activated:Connect(function()
	addAccount(altInput, "Alt")
end)

removeButton.Activated:Connect(function()
	if selectedIndex and accounts[selectedIndex] then
		table.remove(accounts, selectedIndex)
		selectedIndex = nil
		refresh()
	end
end)

commandToggle.Activated:Connect(function()
	commandEnabled = not commandEnabled
	commandToggle.Text = commandEnabled and "Command Toggle: ON" or "Command Toggle: OFF"
	commandToggle.BackgroundColor3 = commandEnabled
		and Color3.fromRGB(65, 125, 75)
		or Color3.fromRGB(110, 65, 65)
end)

refresh()
-- ============================================================
-- Command system (client-only, no server code)
-- Each client running this script listens to chat. A command runs
-- on THIS player's own character only when ALL of these are true:
--   1) Command Toggle is ON
--   2) the local player is listed as an Alt
--   3) the person who chatted is listed as a Main
-- ============================================================
local TextChatService = game:GetService("TextChatService")
local PREFIX = "!"

local function hasRole(username, role)
	username = username:lower()
	for _, account in ipairs(accounts) do
		if account.Role == role and account.Name:lower() == username then
			return true
		end
	end
	return false
end

local function getHumanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function say(text)
	local channels = TextChatService:FindFirstChild("TextChannels")
	local general = channels and channels:FindFirstChild("RBXGeneral")
	if general then
		general:SendAsync(text)
	end
end

-- Add your own commands here. Each gets a table of args.
local commands = {
	jump = function()
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.Jump = true
		end
	end,

	sit = function()
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.Sit = true
		end
	end,

	speed = function(args)
		local humanoid = getHumanoid()
		local value = tonumber(args[1])
		if humanoid and value then
			humanoid.WalkSpeed = math.clamp(value, 0, 100)
		end
	end,

	stop = function()
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:Move(Vector3.zero)
		end
	end,

	say = function(args)
		local text = table.concat(args, " ")
		if text ~= "" then
			say(text)
		end
	end,
}

local function handleMessage(senderName, text)
	if not commandEnabled then return end
	if senderName:lower() == player.Name:lower() then return end
	if not hasRole(player.Name, "Alt") then return end
	if not hasRole(senderName, "Main") then return end
	if text:sub(1, #PREFIX) ~= PREFIX then return end

	local args = {}
	for word in text:sub(#PREFIX + 1):gmatch("%S+") do
		table.insert(args, word)
	end

	local name = table.remove(args, 1)
	local command = name and commands[name:lower()]
	if command then
		command(args)
	end
end

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
	TextChatService.MessageReceived:Connect(function(message)
		local source = message.TextSource
		if source then
			local sender = Players:GetPlayerByUserId(source.UserId)
			if sender then
				handleMessage(sender.Name, message.Text)
			end
		end
	end)
else
	local function hook(p)
		p.Chatted:Connect(function(msg)
			handleMessage(p.Name, msg)
		end)
	end
	for _, p in ipairs(Players:GetPlayers()) do
		hook(p)
	end
	Players.PlayerAdded:Connect(hook)
end

-- ============================================================
-- Say box (press the Say button or hit Enter in the box):
--   * If this account is listed as a Main, it chats "!say <text>",
--     so every Alt (with Command Toggle ON) says <text>.
--   * Otherwise it just sends <text> as a normal chat message.
-- ============================================================
local function sendSayBox()
	local text = sayInput.Text:match("^%s*(.-)%s*$")
	if text == "" then
		return
	end

	if hasRole(player.Name, "Main") then
		say(PREFIX .. "say " .. text)
	else
		say(text)
	end
	sayInput.Text = ""
end

sayButton.Activated:Connect(sendSayBox)

sayInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		sendSayBox()
	end
end)
