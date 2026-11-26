-- LocalScript UI
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")

-- Destroy any other copy of this GUI before making ours.
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
frame.Size = UDim2.fromOffset(360, 510)
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
title.Text = "Alt Manager"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Manager tab content (the original controls live in here)
local managerPage = Instance.new("Frame")
managerPage.Name = "ManagerPage"
managerPage.Position = UDim2.fromOffset(0, 30)
managerPage.Size = UDim2.new(1, 0, 1, -30)
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

local loopSeconds = makeTextBox("Secs", UDim2.fromOffset(10, 212))
loopSeconds.Size = UDim2.fromOffset(70, 32)
local loopCommand = makeTextBox("Loop command, e.g. say hi / jump", UDim2.fromOffset(88, 212))
loopCommand.Size = UDim2.new(1, -98, 0, 32)
local startLoopButton = makeButton("Start Loop", UDim2.fromOffset(10, 252), UDim2.new(0.5, -15, 0, 32))
local stopLoopButton = makeButton("Stop Loop", UDim2.new(0.5, 5, 0, 252), UDim2.new(0.5, -15, 0, 32))
stopLoopButton.BackgroundColor3 = Color3.fromRGB(110, 65, 65)

local accountList = Instance.new("ScrollingFrame")
accountList.Position = UDim2.fromOffset(10, 294)
accountList.Size = UDim2.new(1, -20, 1, -314)
accountList.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
accountList.BorderSizePixel = 0
accountList.ScrollBarThickness = 6
accountList.CanvasSize = UDim2.new()
accountList.Parent = managerPage
round(accountList)

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
			round(entry, 4)

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

local loopId = 0
local destroyed = false

-- If another copy replaces this GUI, this copy goes inert: stops its loops
-- and ignores chat commands (so two scripts never both act on one message).
gui.Destroying:Connect(function()
	destroyed = true
	loopId += 1
end)

local function setCommandEnabled(value)
	commandEnabled = value
	commandToggle.Text = value and "Command Toggle: ON" or "Command Toggle: OFF"
	commandToggle.BackgroundColor3 = value
		and Color3.fromRGB(65, 125, 75)
		or Color3.fromRGB(110, 65, 65)
end

-- Repeats a command every `interval` seconds. Stops by itself if the
-- toggle goes OFF, this account stops being an Alt, or a new loop/!stoploop arrives.
local function startLoop(interval, command, args)
	loopId += 1
	local myId = loopId
	task.spawn(function()
		while loopId == myId and commandEnabled and hasRole(player.Name, "Alt") do
			command(args)
			task.wait(interval)
		end
	end)
end

local function hasAnyMain()
	for _, account in ipairs(accounts) do
		if account.Role == "Main" then
			return true
		end
	end
	return false
end

-- !setalts a b c : sender becomes Main, listed names become Alts.
-- Accepted only if no Main is set yet (first claim) or sender is already the Main.
local function applySetAlts(senderName, args)
	if hasAnyMain() and not hasRole(senderName, "Main") then
		return
	end
	table.clear(accounts)
	table.insert(accounts, { Name = senderName, Role = "Main" })
	for _, name in ipairs(args) do
		if name:lower() ~= senderName:lower() then
			table.insert(accounts, { Name = name, Role = "Alt" })
		end
	end
	selectedIndex = nil
	refresh()
end

local function handleMessage(senderName, text)
	if destroyed then return end
	if text:sub(1, #PREFIX) ~= PREFIX then return end

	local args = {}
	for word in text:sub(#PREFIX + 1):gmatch("%S+") do
		table.insert(args, word)
	end
	local name = (table.remove(args, 1) or ""):lower()

	-- Runs on every client, including the sender's own.
	if name == "setalts" then
		applySetAlts(senderName, args)
		return
	end

	if senderName:lower() == player.Name:lower() then return end
	if not hasRole(player.Name, "Alt") then return end
	if not hasRole(senderName, "Main") then return end

	if name == "on" or name == "off" then
		setCommandEnabled(name == "on")
		return
	end

	if not commandEnabled then return end

	if name == "stoploop" then
		loopId += 1
	elseif name == "loop" then
		-- !loop <seconds> <command> [args...]   (minimum 2s)
		local interval = tonumber(table.remove(args, 1))
		local rawName = table.remove(args, 1)
		if interval and rawName then
			local command = commands[rawName:lower()]
			if not command then
				-- Not a built-in command: chat it exactly as typed so the game's own
				-- command handling (e.g. donate) picks it up.
				local fullText = rawName .. (#args > 0 and (" " .. table.concat(args, " ")) or "")
				command = function()
					say(fullText)
				end
			end
			startLoop(math.max(interval, 2), command, args)
		end
	elseif commands[name] then
		commands[name](args)
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

	if text:sub(1, #PREFIX) == PREFIX then
		say(text)
	elseif hasRole(player.Name, "Main") then
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

-- ============================================================
-- Loop controls: send !loop / !stoploop (alts act on them if this
-- account is the Main and their toggle is ON; min interval 2s).
-- ============================================================
startLoopButton.Activated:Connect(function()
	local seconds = tonumber(loopSeconds.Text)
	local command = loopCommand.Text:match("^%s*(.-)%s*$")
	if seconds and command ~= "" then
		say(PREFIX .. "loop " .. seconds .. " " .. command)
	end
end)

stopLoopButton.Activated:Connect(function()
	say(PREFIX .. "stoploop")
end)

-- ============================================================
-- Header: collapse button + tabs (Manager / FAQ)
-- ============================================================
title.ZIndex = 2
title.Text = "  Alt Manager"
title.TextXAlignment = Enum.TextXAlignment.Left

local collapseButton = Instance.new("TextButton")
collapseButton.Size = UDim2.fromOffset(28, 28)
collapseButton.Position = UDim2.new(1, -34, 0, 6)
collapseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
collapseButton.BorderSizePixel = 0
collapseButton.Text = "-"
collapseButton.TextColor3 = Color3.new(1, 1, 1)
collapseButton.Font = Enum.Font.GothamBold
collapseButton.TextSize = 18
collapseButton.ZIndex = 4
collapseButton.Parent = frame
round(collapseButton)

local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.fromOffset(0, 40)
tabBar.Size = UDim2.new(1, 0, 0, 32)
tabBar.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 2
tabBar.Parent = frame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 10)
tabPadding.PaddingTop = UDim.new(0, 3)
tabPadding.Parent = tabBar

local tabButtons = {}
for _, tabName in ipairs({ "Manager", "FAQ" }) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.fromOffset(90, 26)
	tab.BorderSizePixel = 0
	tab.Text = tabName
	tab.TextColor3 = Color3.new(1, 1, 1)
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 13
	tab.ZIndex = 3
	tab.Parent = tabBar
	round(tab)
	tabButtons[tabName] = tab
end

-- FAQ page
local faqPage = Instance.new("ScrollingFrame")
faqPage.Position = UDim2.fromOffset(10, 82)
faqPage.Size = UDim2.new(1, -20, 1, -92)
faqPage.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
faqPage.BorderSizePixel = 0
faqPage.ScrollBarThickness = 6
faqPage.CanvasSize = UDim2.new()
faqPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
faqPage.Visible = false
faqPage.Parent = frame
round(faqPage)

local faqLayout = Instance.new("UIListLayout")
faqLayout.Padding = UDim.new(0, 4)
faqLayout.SortOrder = Enum.SortOrder.LayoutOrder
faqLayout.Parent = faqPage

local faqPadding = Instance.new("UIPadding")
faqPadding.PaddingLeft = UDim.new(0, 8)
faqPadding.PaddingRight = UDim.new(0, 8)
faqPadding.PaddingTop = UDim.new(0, 8)
faqPadding.PaddingBottom = UDim.new(0, 8)
faqPadding.Parent = faqPage

local faqOrder = 0
local function faqText(text, isHeading)
	faqOrder += 1
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = isHeading and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = isHeading and 14 or 13
	label.TextColor3 = isHeading and Color3.fromRGB(130, 175, 255) or Color3.fromRGB(205, 205, 210)
	label.LayoutOrder = faqOrder
	label.Parent = faqPage
end

local function faq(heading, body)
	faqText(heading, true)
	faqText(body, false)
end

faq("Setup (do this on BOTH accounts)",
	"1. Run this script on the Main account and on every Alt account.\n2. Add the Main's username as Main and each Alt's username as Alt. Or, from the Main, chat: !setalts altname1 altname2 and every copy fills itself in.\n3. Use Roblox usernames, not display names.")
faq("Command Toggle",
	"Turn it ON (green) on the Alt accounts, and on the Main too to be safe. A client with the toggle OFF ignores every command and loop. From the Main you can also chat !on or !off to flip the alts' toggles.")
faq("Lists are per account",
	"Each client keeps its own list. The Alt's list must contain the Main (as Main) and itself (as Alt), or it ignores commands. Lists are not saved, so they reset when you rejoin.")
faq("Commands",
	"!jump  !sit  !speed 32  !stop  !say hello\nOnly the Main can send them, and only Alts run them.")
faq("Say box",
	"On the Main it makes every Alt say your text. On any other account it sends a normal chat message. Anything starting with ! is sent as typed.")
faq("Loops",
	"Put seconds (minimum 2) and a command, then Start Loop. Alts repeat it until you press Stop Loop (or chat !stoploop). If the command isn't built in (like donate), the Alt chats it exactly as typed, so type it the way your game expects it.")
faq("Nothing happens?",
	"- Toggle is OFF on the Alt\n- Alt's list is missing the Main or itself\n- Old version of the script on the Alt\n- Typed a display name instead of the username\n- Chat is the legacy system (say needs the new TextChatService)")
faq("Good to know",
	"Commands show up in public chat for everyone. Re-running the script replaces the old window and switches the old copy off. Use the - button to collapse the window.")

-- Tab switching + collapse
local activeTab = "Manager"
local expanded = true
local fullSize = frame.Size

local function applyView()
	tabBar.Visible = expanded
	managerPage.Visible = expanded and activeTab == "Manager"
	faqPage.Visible = expanded and activeTab == "FAQ"
	frame.Size = expanded and fullSize or UDim2.fromOffset(fullSize.X.Offset, 40)
	collapseButton.Text = expanded and "-" or "+"
	for name, tab in pairs(tabButtons) do
		tab.BackgroundColor3 = name == activeTab and Color3.fromRGB(75, 110, 170) or Color3.fromRGB(55, 55, 63)
	end
end

for name, tab in pairs(tabButtons) do
	tab.Activated:Connect(function()
		activeTab = name
		applyView()
	end)
end

collapseButton.Activated:Connect(function()
	expanded = not expanded
	applyView()
end)

applyView()
