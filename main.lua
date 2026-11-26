-- LocalScript UI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
frame.Size = UDim2.fromOffset(360, 534)
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

local sayInput = makeTextBox("Say", UDim2.fromOffset(10, 172))
local sayButton = makeButton("Say", UDim2.fromOffset(250, 172), UDim2.fromOffset(100, 32))

local loopSeconds = makeTextBox("Secs", UDim2.fromOffset(10, 212))
loopSeconds.Size = UDim2.fromOffset(70, 32)
local loopCommand = makeTextBox("Command", UDim2.fromOffset(88, 212))
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

local setPing -- defined in the Ping section below
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

-- ============================================================
-- !follow / !unfollow: alts pathfind after the Main (client-side)
-- ============================================================
local PathfindingService = game:GetService("PathfindingService")
local followId = 0
local followingName

local function altIndex()
	local index = 0
	for _, account in ipairs(accounts) do
		if account.Role == "Alt" then
			index += 1
			if account.Name:lower() == player.Name:lower() then
				return index
			end
		end
	end
	return 1
end

local function startFollow(targetName, baseDistance)
	followId += 1
	local myId = followId
	followingName = targetName
	-- Each alt keeps a slightly different distance so they don't all stack up.
	local stopDistance = math.clamp(baseDistance or 6, 3, 50) + 2 * (altIndex() - 1)

	task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
		})

		while followId == myId and commandEnabled and not destroyed and hasRole(player.Name, "Alt") do
			local target = Players:FindFirstChild(targetName)
			local humanoid = getHumanoid()
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")

			if humanoid and root and targetRoot and humanoid.Health > 0
				and (targetRoot.Position - root.Position).Magnitude > stopDistance then
				local ok = pcall(function()
					path:ComputeAsync(root.Position, targetRoot.Position)
				end)

				if ok and path.Status == Enum.PathStatus.Success then
					local waypoints = path:GetWaypoints()
					-- Walk the next few waypoints, then re-plan (the Main keeps moving).
					for i = 2, math.min(#waypoints, 5) do
						if followId ~= myId then
							break
						end
						local waypoint = waypoints[i]
						if waypoint.Action == Enum.PathWaypointAction.Jump then
							humanoid.Jump = true
						end
						humanoid:MoveTo(waypoint.Position)

						local reached = false
						local connection = humanoid.MoveToFinished:Connect(function()
							reached = true
						end)
						local waited = 0
						while not reached and waited < 1.5 and followId == myId do
							task.wait(0.1)
							waited += 0.1
						end
						connection:Disconnect()
					end
				else
					-- No path found: head straight at the Main as a fallback.
					humanoid:MoveTo(targetRoot.Position)
				end
			end
			task.wait(0.25)
		end

		-- Ended (not replaced by a newer follow): stand still.
		if followId == myId then
			followingName = nil
			local humanoid = getHumanoid()
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if humanoid and root then
				humanoid:MoveTo(root.Position)
			end
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

	if name == "ping" then
		setPing((args[1] or "on"):lower() ~= "off")
		return
	end

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
	elseif name == "follow" then
		startFollow(senderName, tonumber(args[1]))
	elseif name == "unfollow" then
		followId += 1
		followingName = nil
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
for _, tabName in ipairs({ "Manager", "Ping", "Follow", "FAQ" }) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.fromOffset(80, 26)
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
faqPage.Size = UDim2.new(1, -20, 1, -116)
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

faq("Setup", "Run on every account. Main chats !setalts alt1 alt2, or add usernames by hand.")
faq("Toggle", "Command Toggle ON on the alts. Or Main chats !on.")
faq("Commands", "!jump  !sit  !speed n  !stop  !say text\n!follow [studs]  !unfollow  !ping on/off\n!loop secs cmd  !stoploop")
faq("Not working?", "Toggle off, wrong or missing names, or old script on the alt.")

-- ============================================================
-- Ping tab: periodic movement / click so the account stays active
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")

local pingPage = Instance.new("Frame")
pingPage.Position = UDim2.fromOffset(0, 72)
pingPage.Size = UDim2.new(1, 0, 1, -72)
pingPage.BackgroundTransparency = 1
pingPage.BorderSizePixel = 0
pingPage.Visible = false
pingPage.Parent = frame

local function pingBox(placeholder, y, default)
	local box = Instance.new("TextBox")
	box.Position = UDim2.fromOffset(10, y)
	box.Size = UDim2.new(1, -20, 0, 32)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
	box.BorderSizePixel = 0
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(170, 170, 175)
	box.Text = default
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = pingPage
	round(box)
	return box
end

local function pingButton(text, y)
	local button = Instance.new("TextButton")
	button.Position = UDim2.fromOffset(10, y)
	button.Size = UDim2.new(1, -20, 0, 32)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = pingPage
	round(button)
	return button
end

local pingEnabled = false
local pingId = 0
local pingOptions = { Walk = true, Jump = true, Click = false }

local pingToggle = pingButton("Ping: OFF", 12)
pingToggle.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
local pingInterval = pingBox("Seconds", 54, "10")

local optionButtons = {}
local optionLabels = { Walk = "Walk", Jump = "Jump", Click = "Click" }
local function paintOption(name)
	local on = pingOptions[name]
	optionButtons[name].Text = optionLabels[name] .. ": " .. (on and "ON" or "OFF")
	optionButtons[name].BackgroundColor3 = on and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(60, 60, 68)
end
for index, name in ipairs({ "Walk", "Jump", "Click" }) do
	optionButtons[name] = pingButton("", 96 + (index - 1) * 40)
	paintOption(name)
	optionButtons[name].Activated:Connect(function()
		pingOptions[name] = not pingOptions[name]
		paintOption(name)
	end)
end

local function pingOnce()
	local character = player.Character
	local humanoid = getHumanoid()
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if pingOptions.Walk and humanoid and root then
		local angle = math.random() * math.pi * 2
		humanoid:MoveTo(root.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * 8)
	end
	if pingOptions.Jump and humanoid then
		humanoid.Jump = true
	end
	if pingOptions.Click then
		local viewport = workspace.CurrentCamera.ViewportSize
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new(viewport.X / 2, viewport.Y / 2))
	end
end

setPing = function(value)
	if value and hasRole(player.Name, "Main") then
		return -- the Main never pings itself, it only tells the Alts
	end
	pingEnabled = value
	pingId += 1
	pingToggle.Text = value and "Ping: ON" or "Ping: OFF"
	pingToggle.BackgroundColor3 = value and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(110, 65, 65)

	if value then
		local myId = pingId
		task.spawn(function()
			while pingId == myId and pingEnabled and not destroyed do
				pingOnce()
				task.wait(math.max(tonumber(pingInterval.Text) or 10, 3))
			end
		end)
	end
end

-- Also answer Roblox's own idle signal while Ping is on.
player.Idled:Connect(function()
	if pingEnabled then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new())
	end
end)

gui.Destroying:Connect(function()
	pingId += 1
end)

local relayOn = false
pingToggle.Activated:Connect(function()
	if hasRole(player.Name, "Main") then
		relayOn = not relayOn
		say(PREFIX .. "ping " .. (relayOn and "on" or "off"))
	else
		setPing(not pingEnabled)
	end
end)

-- ============================================================
-- Follow tab
-- ============================================================
local followPage = Instance.new("Frame")
followPage.Position = UDim2.fromOffset(0, 72)
followPage.Size = UDim2.new(1, 0, 1, -72)
followPage.BackgroundTransparency = 1
followPage.BorderSizePixel = 0
followPage.Visible = false
followPage.Parent = frame

local followDistance = Instance.new("TextBox")
followDistance.Position = UDim2.fromOffset(10, 12)
followDistance.Size = UDim2.new(1, -20, 0, 32)
followDistance.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
followDistance.BorderSizePixel = 0
followDistance.PlaceholderText = "Distance"
followDistance.PlaceholderColor3 = Color3.fromRGB(170, 170, 175)
followDistance.Text = "6"
followDistance.TextColor3 = Color3.new(1, 1, 1)
followDistance.Font = Enum.Font.Gotham
followDistance.TextSize = 14
followDistance.ClearTextOnFocus = false
followDistance.Parent = followPage
round(followDistance)

local function followButton(text, y, color)
	local button = Instance.new("TextButton")
	button.Position = UDim2.fromOffset(10, y)
	button.Size = UDim2.new(1, -20, 0, 32)
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = followPage
	round(button)
	return button
end

local startFollowButton = followButton("Start Follow", 54, Color3.fromRGB(65, 125, 75))
local stopFollowButton = followButton("Stop Follow", 96, Color3.fromRGB(110, 65, 65))

local followStatus = Instance.new("TextLabel")
followStatus.Position = UDim2.fromOffset(10, 140)
followStatus.Size = UDim2.new(1, -20, 0, 24)
followStatus.BackgroundTransparency = 1
followStatus.TextXAlignment = Enum.TextXAlignment.Left
followStatus.Font = Enum.Font.GothamBold
followStatus.TextSize = 13
followStatus.TextColor3 = Color3.fromRGB(130, 175, 255)
followStatus.Text = "Idle"
followStatus.Parent = followPage

startFollowButton.Activated:Connect(function()
	local distance = tonumber(followDistance.Text) or 6
	if hasRole(player.Name, "Main") then
		say(PREFIX .. "follow " .. distance)
	else
		for _, account in ipairs(accounts) do
			if account.Role == "Main" then
				startFollow(account.Name, distance)
				break
			end
		end
	end
end)

stopFollowButton.Activated:Connect(function()
	if hasRole(player.Name, "Main") then
		say(PREFIX .. "unfollow")
	else
		followId += 1
		followingName = nil
	end
end)

-- Tab switching + collapse
local activeTab = "Manager"
local expanded = true
local fullSize = frame.Size

local function applyView()
	tabBar.Visible = expanded
	managerPage.Visible = expanded and activeTab == "Manager"
	faqPage.Visible = expanded and activeTab == "FAQ"
	pingPage.Visible = expanded and activeTab == "Ping"
	followPage.Visible = expanded and activeTab == "Follow"
	TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
		Size = expanded and fullSize or UDim2.fromOffset(fullSize.X.Offset, 40),
	}):Play()
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

-- ============================================================
-- Visual polish: darker palette, border, accent line, hover and
-- focus effects, live status footer
-- ============================================================
local ACCENT = Color3.fromRGB(88, 101, 242)
local PANEL = Color3.fromRGB(32, 32, 38)

frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
title.BackgroundColor3 = PANEL
tabBar.BackgroundColor3 = PANEL

local frameStroke = Instance.new("UIStroke")
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Color = Color3.fromRGB(62, 62, 72)
frameStroke.Thickness = 1
frameStroke.Parent = frame

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.BackgroundColor3 = ACCENT
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 5
accentLine.Parent = frame

local function polish(inst)
	if inst:IsA("TextBox") then
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(70, 70, 82)
		stroke.Thickness = 1
		stroke.Parent = inst
		inst.Focused:Connect(function()
			stroke.Color = ACCENT
		end)
		inst.FocusLost:Connect(function()
			stroke.Color = Color3.fromRGB(70, 70, 82)
		end)
	elseif inst:IsA("TextButton") then
		inst.AutoButtonColor = false
		inst.MouseEnter:Connect(function()
			TweenService:Create(inst, TweenInfo.new(0.12), { BackgroundTransparency = 0.2 }):Play()
		end)
		inst.MouseLeave:Connect(function()
			TweenService:Create(inst, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play()
		end)
	end
end
for _, inst in ipairs(frame:GetDescendants()) do
	polish(inst)
end

-- Footer: live status
local footer = Instance.new("TextLabel")
footer.Position = UDim2.new(0, 0, 1, -24)
footer.Size = UDim2.new(1, 0, 0, 24)
footer.BackgroundColor3 = PANEL
footer.BorderSizePixel = 0
footer.TextColor3 = Color3.fromRGB(170, 170, 178)
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.ZIndex = 2
footer.Parent = frame
local footerPad = Instance.new("UIPadding")
footerPad.PaddingLeft = UDim.new(0, 10)
footerPad.Parent = footer

task.spawn(function()
	while not destroyed do
		local mains, alts = 0, 0
		for _, account in ipairs(accounts) do
			if account.Role == "Main" then
				mains += 1
			else
				alts += 1
			end
		end

		local isMain = hasRole(player.Name, "Main")
		local pingOn = isMain and relayOn or pingEnabled
		footer.Text = ("Cmds %s  |  %dM %dA  |  Ping %s"):format(
			commandEnabled and "ON" or "OFF", mains, alts, pingOn and "ON" or "OFF"
		)

		pingToggle.Text = isMain and (relayOn and "Ping Alts: ON" or "Ping Alts: OFF")
			or (pingEnabled and "Ping: ON" or "Ping: OFF")
		pingToggle.BackgroundColor3 = pingOn and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(110, 65, 65)

		if hasRole(player.Name, "Main") then
			followStatus.Text = "Main"
		else
			followStatus.Text = followingName and (followingName) or "Idle"
		end

		task.wait(0.5)
	end
end)
