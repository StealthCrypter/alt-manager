local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
frame.Size = UDim2.fromOffset(520, 310)
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
title.Text = "Cortege"
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
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = accountList

local removeButton = makeButton(
	"Remove Selected",
	UDim2.new(0, 10, 1, -40),
	UDim2.new(1, -20, 0, 30)
)
removeButton.BackgroundColor3 = Color3.fromRGB(160, 70, 70)

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
			entry.BackgroundTransparency = 0.3

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

local commands = {
	jump = function()
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

local lastSync = 0
local function relayCommand(text)
	task.spawn(function()
		if not hasRole(player.Name, "Alt") and os.clock() - lastSync > 60 then
			local names = {}
			for _, account in ipairs(accounts) do
				if account.Role == "Alt" then
					table.insert(names, account.Name)
				end
			end
			if #names > 0 then
				say(PREFIX .. "setalts " .. table.concat(names, " "))
				lastSync = os.clock()
				task.wait(0.6)
			end
		end
		say(text)
	end)
end

local destroyed = false

local spinConnection

local function stopSpin()
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.AutoRotate = true
		end
	end
end

local function startSpin(speed)
	stopSpin()
	local turns = math.clamp(speed or 2, 0.5, 10)
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.AutoRotate = false
	end
	spinConnection = RunService.Heartbeat:Connect(function(dt)
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and commandEnabled and not destroyed then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.pi * 2 * turns * dt, 0)
		else
			stopSpin()
		end
	end)
end

commands.spin = function(args)
	startSpin(tonumber(args[1]))
end
commands.unspin = stopSpin

for _, emoteName in ipairs({ "wave", "dance", "dance2", "dance3", "cheer", "laugh", "point" }) do
	commands[emoteName] = function()
		local humanoid = getHumanoid()
		if humanoid then
			pcall(function()
				humanoid:PlayEmote(emoteName)
			end)
		end
	end
end

local setPing
local loopId = 0

gui.Destroying:Connect(function()
	destroyed = true
	loopId += 1
	stopSpin()
end)

local function setCommandEnabled(value)
	commandEnabled = value
	commandToggle.Text = value and "Command Toggle: ON" or "Command Toggle: OFF"
	commandToggle.BackgroundColor3 = value
		and Color3.fromRGB(65, 125, 75)
		or Color3.fromRGB(110, 65, 65)
end

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

local PathfindingService = game:GetService("PathfindingService")
local followId = 0
local followingName
local followingMode
local FOLLOW_MODES = {
	pf = true, direct = true, orbit = true, line = true,
	circle = true, vee = true, grid = true, wall = true,
}

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

local function altCount()
	local count = 0
	for _, account in ipairs(accounts) do
		if account.Role == "Alt" then
			count += 1
		end
	end
	return math.max(count, 1)
end

local function startFollow(targetName, baseDistance, mode)
	mode = FOLLOW_MODES[mode] and mode or "pf"
	followId += 1
	local myId = followId
	followingName = targetName
	followingMode = mode
	local baseGap = math.clamp(baseDistance or 6, 3, 50)
	local stopDistance = baseGap + 2 * (altIndex() - 1)

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

			if humanoid and root and targetRoot and humanoid.Health > 0 and mode ~= "pf" then
				local index = altIndex()
				if mode == "direct" then
					if (targetRoot.Position - root.Position).Magnitude > stopDistance then
						humanoid:MoveTo(targetRoot.Position)
					end
				elseif mode == "orbit" then
					local angle = os.clock() * 0.8 + (index - 1) * (math.pi * 2 / altCount())
					humanoid:MoveTo(targetRoot.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * baseGap)
				elseif mode == "line" then
					humanoid:MoveTo(targetRoot.Position - targetRoot.CFrame.LookVector * (baseGap * index))
				else
					local total = altCount()
					local offset
					if mode == "circle" then
						local angle = (index - 1) * (math.pi * 2 / total)
						offset = Vector3.new(math.cos(angle) * baseGap, 0, math.sin(angle) * baseGap)
					elseif mode == "vee" then
						local side = index % 2 == 1 and -1 or 1
						local rank = math.ceil(index / 2)
						offset = Vector3.new(side * rank * baseGap * 0.8, 0, rank * baseGap)
					elseif mode == "grid" then
						local columns = math.ceil(math.sqrt(total))
						local row = (index - 1) // columns
						local column = (index - 1) % columns
						offset = Vector3.new((column - (columns - 1) / 2) * baseGap, 0, baseGap * (row + 1))
					else
						offset = Vector3.new((index - (total + 1) / 2) * baseGap, 0, baseGap)
					end
					humanoid:MoveTo(targetRoot.CFrame:PointToWorldSpace(offset))
				end
			elseif humanoid and root and targetRoot and humanoid.Health > 0
				and (targetRoot.Position - root.Position).Magnitude > stopDistance then
				local ok = pcall(function()
					path:ComputeAsync(root.Position, targetRoot.Position)
				end)

				if ok and path.Status == Enum.PathStatus.Success then
					local waypoints = path:GetWaypoints()
					for i = 2, math.min(#waypoints, 5) do
						if followId ~= myId then
							break
						end
						local waypoint = waypoints[i]
						if waypoint.Action == Enum.PathWaypointAction.Jump then
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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
					humanoid:MoveTo(targetRoot.Position)
				end
			end
			task.wait(mode == "pf" and 0.25 or 0.15)
		end

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
		setPing((args[1] or "on"):lower() ~= "off", tonumber(args[2]), args[3])
		return
	end

	if name == "stoploop" then
		loopId += 1
	elseif name == "loop" then
		local interval = tonumber(table.remove(args, 1))
		local rawName = table.remove(args, 1)
		if interval and rawName then
			local command = commands[rawName:lower()]
			if not command then
				local fullText = rawName .. (#args > 0 and (" " .. table.concat(args, " ")) or "")
				command = function()
					say(fullText)
				end
			end
			startLoop(math.max(interval, 2), command, args)
		end
	elseif name == "follow" then
		local modeArg = args[1] and args[1]:lower()
		local mode = FOLLOW_MODES[modeArg] and modeArg or nil
		startFollow(senderName, tonumber(mode and args[2] or args[1]), mode)
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

startLoopButton.Activated:Connect(function()
	local seconds = tonumber(loopSeconds.Text)
	local command = loopCommand.Text:match("^%s*(.-)%s*$")
	if seconds and command ~= "" then
		relayCommand(PREFIX .. "loop " .. seconds .. " " .. command)
	end
end)

stopLoopButton.Activated:Connect(function()
	relayCommand(PREFIX .. "stoploop")
end)

title.ZIndex = 2
title.Text = "  Cortege"
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

local tabBar = Instance.new("ScrollingFrame")
tabBar.Position = UDim2.fromOffset(0, 40)
tabBar.Size = UDim2.new(1, 0, 0, 32)
tabBar.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 2
tabBar.ScrollingDirection = Enum.ScrollingDirection.Y
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabBar.CanvasSize = UDim2.new()
tabBar.ScrollBarThickness = 3
tabBar.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
tabBar.Parent = frame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Vertical
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 4)
tabPadding.PaddingRight = UDim.new(0, 4)
tabPadding.PaddingTop = UDim.new(0, 3)
tabPadding.Parent = tabBar

local tabButtons = {}
for _, tabName in ipairs({ "Manager", "Actions", "Ping", "Move", "Destruction", "FAQ", "Settings" }) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(1, -4, 0, 28)
	tab.BorderSizePixel = 0
	tab.Text = tabName
	tab.TextColor3 = Color3.new(1, 1, 1)
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 12
	tab.ZIndex = 3
	tab.Parent = tabBar
	round(tab)
	tabButtons[tabName] = tab
end

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
faq("Toggle", "Commands are ON by default. Turn the toggle OFF (or chat !off) to pause the alts.")
faq("Commands", "!jump  !sit  !speed n  !stop  !say text\n!spin [n]  !unspin  !wave  !dance  !cheer  !laugh  !point\n!follow [mode] [studs]  !unfollow  !ping on/off\nModes: pf direct orbit line circle vee grid wall\n!loop secs cmd  !stoploop")
faq("Not working?", "Toggle off, wrong or missing names, or old script on the alt.")

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

local pingToggle = pingButton("Ping Alts: OFF", 12)
pingToggle.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
local pingSelf = pingButton("Ping Me: OFF", 54)
pingSelf.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
local pingInterval = pingBox("Seconds", 96, "10")

local optionButtons = {}
local optionLabels = { Walk = "Walk", Jump = "Jump", Click = "Click" }
local function paintOption(name)
	local on = pingOptions[name]
	optionButtons[name].Text = optionLabels[name] .. ": " .. (on and "ON" or "OFF")
	optionButtons[name].BackgroundColor3 = on and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(60, 60, 68)
end
for index, name in ipairs({ "Walk", "Jump", "Click" }) do
	optionButtons[name] = pingButton("", 138 + (index - 1) * 40)
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
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	if pingOptions.Click then
		local viewport = workspace.CurrentCamera.ViewportSize
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new(viewport.X / 2, viewport.Y / 2))
	end
end

setPing = function(value, seconds, optionList)
	if value and hasRole(player.Name, "Main") then
		return
	end
	if value and seconds then
		pingInterval.Text = tostring(seconds)
	end
	if value and optionList then
		local chosen = {}
		for option in optionList:lower():gmatch("[^,]+") do
			chosen[option] = true
		end
		pingOptions.Walk = chosen.walk == true
		pingOptions.Jump = chosen.jump == true
		pingOptions.Click = chosen.click == true
		for name in pairs(optionButtons) do
			paintOption(name)
		end
	end
	pingEnabled = value
	pingId += 1
	pingSelf.Text = value and "Ping Me: ON" or "Ping Me: OFF"
	pingSelf.BackgroundColor3 = value and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(110, 65, 65)

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

local antiAfk = true

player.Idled:Connect(function()
	if antiAfk or pingEnabled then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new())
	end
end)

gui.Destroying:Connect(function()
	pingId += 1
end)

local relayOn = false
pingToggle.Activated:Connect(function()
	relayOn = not relayOn
	if relayOn then
		local chosen = {}
		for _, name in ipairs({ "Walk", "Jump", "Click" }) do
			if pingOptions[name] then
				table.insert(chosen, name:lower())
			end
		end
		local seconds = math.max(tonumber(pingInterval.Text) or 10, 3)
		relayCommand(PREFIX .. "ping on " .. seconds .. " " .. (#chosen > 0 and table.concat(chosen, ",") or "none"))
	else
		relayCommand(PREFIX .. "ping off")
	end
end)

pingSelf.Activated:Connect(function()
	setPing(not pingEnabled)
end)

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

local followModes = { "pf", "direct", "orbit", "line", "circle", "vee", "grid", "wall" }
local followModeLabels = {
	pf = "PF", direct = "Direct", orbit = "Orbit", line = "Line",
	circle = "Circle", vee = "Vee", grid = "Grid", wall = "Wall",
}
local followMode = "pf"

local modeGrid = Instance.new("Frame")
modeGrid.Position = UDim2.fromOffset(10, 56)
modeGrid.Size = UDim2.new(1, -20, 0, 70)
modeGrid.BackgroundTransparency = 1
modeGrid.Parent = followPage

local modeLayout = Instance.new("UIGridLayout")
modeLayout.CellSize = UDim2.new(0.25, -5, 0, 32)
modeLayout.CellPadding = UDim2.fromOffset(6, 6)
modeLayout.SortOrder = Enum.SortOrder.LayoutOrder
modeLayout.Parent = modeGrid

local modeButtons = {}
local function paintModes()
	for name, button in pairs(modeButtons) do
		button.BackgroundColor3 = name == followMode and Color3.fromRGB(75, 110, 170) or Color3.fromRGB(60, 60, 68)
	end
end
for index, name in ipairs(followModes) do
	local button = Instance.new("TextButton")
	button.BorderSizePixel = 0
	button.Text = followModeLabels[name]
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.LayoutOrder = index
	button.Parent = modeGrid
	round(button)
	modeButtons[name] = button
	button.Activated:Connect(function()
		followMode = name
		paintModes()
	end)
end
paintModes()

local startFollowButton = followButton("Start", 138, Color3.fromRGB(65, 125, 75))
startFollowButton.Size = UDim2.new(0.5, -15, 0, 32)
local stopFollowButton = followButton("Stop", 138, Color3.fromRGB(110, 65, 65))
stopFollowButton.Position = UDim2.new(0.5, 5, 0, 138)
stopFollowButton.Size = UDim2.new(0.5, -15, 0, 32)

local followStatus = Instance.new("TextLabel")
followStatus.Position = UDim2.fromOffset(10, 182)
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
		relayCommand(PREFIX .. "follow " .. followMode .. " " .. distance)
	else
		for _, account in ipairs(accounts) do
			if account.Role == "Main" then
				startFollow(account.Name, distance, followMode)
				break
			end
		end
	end
end)

stopFollowButton.Activated:Connect(function()
	if hasRole(player.Name, "Main") then
		relayCommand(PREFIX .. "unfollow")
	else
		followId += 1
		followingName = nil
	end
end)

-- ==========================================
-- ACTIONS PAGE (ScrollingFrame for Hacks)
-- ==========================================
local actionsPage = Instance.new("ScrollingFrame")
actionsPage.Position = UDim2.fromOffset(0, 72)
actionsPage.Size = UDim2.new(1, 0, 1, -72)
actionsPage.BackgroundTransparency = 1
actionsPage.BorderSizePixel = 0
actionsPage.Visible = false
actionsPage.ScrollBarThickness = 4
actionsPage.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
actionsPage.CanvasSize = UDim2.new(0, 0, 0, 450)
actionsPage.Parent = frame

sayInput.Parent = actionsPage
sayInput.Position = UDim2.fromOffset(10, 12)
sayButton.Parent = actionsPage
sayButton.Position = UDim2.fromOffset(250, 12)

local actionGrid = Instance.new("Frame")
actionGrid.Position = UDim2.fromOffset(10, 56)
actionGrid.Size = UDim2.new(1, -20, 0, 108)
actionGrid.BackgroundTransparency = 1
actionGrid.Parent = actionsPage

local actionLayout = Instance.new("UIGridLayout")
actionLayout.CellSize = UDim2.new(0.25, -5, 0, 32)
actionLayout.CellPadding = UDim2.fromOffset(6, 6)
actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
actionLayout.Parent = actionGrid

local quickActions = {
	{ "Jump", "jump" }, { "Sit", "sit" }, { "Spin", "spin" }, { "Unspin", "unspin" },
	{ "Wave", "wave" }, { "Dance", "dance" }, { "Dance 2", "dance2" }, { "Dance 3", "dance3" },
	{ "Cheer", "cheer" }, { "Laugh", "laugh" }, { "Point", "point" }, { "Stop", "stop" },
}
for index, action in ipairs(quickActions) do
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(75, 110, 170)
	button.BorderSizePixel = 0
	button.Text = action[1]
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.LayoutOrder = index
	button.Parent = actionGrid
	round(button)
	button.Activated:Connect(function()
		relayCommand(PREFIX .. action[2])
	end)
end

loopSeconds.Parent = actionsPage
loopSeconds.Position = UDim2.fromOffset(10, 176)
loopCommand.Parent = actionsPage
loopCommand.Position = UDim2.fromOffset(88, 176)
startLoopButton.Parent = actionsPage
startLoopButton.Position = UDim2.fromOffset(10, 218)
stopLoopButton.Parent = actionsPage
stopLoopButton.Position = UDim2.new(0.5, 5, 0, 218)

-- ==========================================
-- MOVEMENT HACKS (Actions Tab) - FIXED LAYOUT
-- ==========================================
local hacksFrame = Instance.new("Frame")
hacksFrame.Position = UDim2.fromOffset(10, 260)
hacksFrame.Size = UDim2.new(1, -20, 0, 160)
hacksFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
hacksFrame.BorderSizePixel = 0
hacksFrame.Parent = actionsPage
round(hacksFrame)

local hacksTitle = Instance.new("TextLabel")
hacksTitle.Size = UDim2.new(1, 0, 0, 25)
hacksTitle.BackgroundTransparency = 1
hacksTitle.Text = "Movement Hacks"
hacksTitle.TextColor3 = Color3.fromRGB(130, 175, 255)
hacksTitle.Font = Enum.Font.GothamBold
hacksTitle.TextSize = 14
hacksTitle.TextXAlignment = Enum.TextXAlignment.Left
hacksTitle.Parent = hacksFrame

local function makeHackButton(text, xPos, yPos, colorOn, colorOff, onFunc, offFunc)
	local btn = Instance.new("TextButton")
	btn.Position = UDim2.fromOffset(xPos, yPos)
	btn.Size = UDim2.fromOffset(190, 28)
	btn.BackgroundColor3 = colorOff
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = hacksFrame
	round(btn)
	
	local enabled = false
	btn.Activated:Connect(function()
		enabled = not enabled
		if enabled then
			btn.Text = text .. " [ON]"
			btn.BackgroundColor3 = colorOn
			if onFunc then onFunc() end
		else
			btn.Text = text
			btn.BackgroundColor3 = colorOff
			if offFunc then offFunc() end
		end
	end)
	return btn
end

-- Row 1: Noclip (Left) & Fly (Right)
local noclipConn = nil
makeHackButton("Noclip", 10, 30, Color3.fromRGB(65, 125, 75), Color3.fromRGB(75, 110, 170),
	function()
		noclipConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	end,
	function()
		if noclipConn then noclipConn:Disconnect() noclipConn = nil end
		local char = player.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
)

local flyConn = nil
local flyEnabled = false
makeHackButton("Fly", 210, 30, Color3.fromRGB(65, 125, 75), Color3.fromRGB(75, 110, 170),
	function()
		flyEnabled = true
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end
		for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
			pcall(function() hum:SetStateEnabled(state, false) end)
		end
		hum:ChangeState(Enum.HumanoidStateType.Swimming)
		hum.PlatformStand = true
		local bg = Instance.new("BodyGyro")
		bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bg.CFrame = hrp.CFrame; bg.Parent = hrp
		local bv = Instance.new("BodyVelocity")
		bv.Velocity = Vector3.new(0,0.1,0); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bv.Parent = hrp
		flyConn = RunService.RenderStepped:Connect(function()
			if not flyEnabled then return end
			local cam = workspace.CurrentCamera.CFrame
			local flatLook = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z).Unit
			local flatRight = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z).Unit
			local dir = Vector3.new(0,0,0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + flatLook end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - flatLook end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - flatRight end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + flatRight end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
			bv.Velocity = dir * 50
			bg.CFrame = cam
		end)
	end,
	function()
		flyEnabled = false
		if flyConn then flyConn:Disconnect() flyConn = nil end
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hum then
				for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
					pcall(function() hum:SetStateEnabled(state, true) end)
				end
				hum.PlatformStand = false
			end
			if hrp then
				local bg = hrp:FindFirstChildOfClass("BodyGyro")
				local bv = hrp:FindFirstChildOfClass("BodyVelocity")
				if bg then bg:Destroy() end
				if bv then bv:Destroy() end
			end
		end
	end
)

-- Row 2: Speed (Left) & Jump (Right)
local speedConn = nil
makeHackButton("Speed 50", 10, 64, Color3.fromRGB(65, 125, 75), Color3.fromRGB(75, 110, 170),
	function()
		speedConn = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = 50 end
			end
		end)
	end,
	function()
		if speedConn then speedConn:Disconnect() speedConn = nil end
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end
	end
)

local jumpConn = nil
makeHackButton("Jump 100", 210, 64, Color3.fromRGB(65, 125, 75), Color3.fromRGB(75, 110, 170),
	function()
		jumpConn = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.UseJumpPower = true
					hum.JumpPower = 100
				end
			end
		end)
	end,
	function()
		if jumpConn then jumpConn:Disconnect() jumpConn = nil end
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.JumpPower = 50 end
		end
	end
)

gui.Destroying:Connect(function()
	if noclipConn then noclipConn:Disconnect() end
	if flyConn then flyConn:Disconnect() end
	if speedConn then speedConn:Disconnect() end
	if jumpConn then jumpConn:Disconnect() end
end)
-- ==========================================

-- ==========================================
-- SETTINGS PAGE (ScrollingFrame for Chat Spy)
-- ==========================================
local settingsPage = Instance.new("ScrollingFrame")
settingsPage.Position = UDim2.fromOffset(0, 72)
settingsPage.Size = UDim2.new(1, 0, 1, -72)
settingsPage.BackgroundTransparency = 1
settingsPage.BorderSizePixel = 0
settingsPage.Visible = false
settingsPage.ScrollBarThickness = 4
settingsPage.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
settingsPage.CanvasSize = UDim2.new(0, 0, 0, 450)
settingsPage.Parent = frame

local function settingsLabel(text, y, isHeading)
	local label = Instance.new("TextLabel")
	label.Position = UDim2.fromOffset(10, y)
	label.Size = UDim2.new(1, -20, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = isHeading and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = isHeading and 14 or 13
	label.TextColor3 = isHeading and Color3.fromRGB(130, 175, 255) or Color3.fromRGB(205, 205, 210)
	label.Parent = settingsPage
end

settingsLabel("Credits", 64, true)
settingsLabel("Made by stealthcrypter", 90, false)
settingsLabel("GitHub", 120, false)

local githubBox = Instance.new("TextBox")
githubBox.Position = UDim2.fromOffset(10, 144)
githubBox.Size = UDim2.new(1, -20, 0, 32)
githubBox.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
githubBox.BorderSizePixel = 0
githubBox.Text = "https://github.com/stealthcrypter"
githubBox.TextColor3 = Color3.fromRGB(130, 175, 255)
githubBox.Font = Enum.Font.Gotham
githubBox.TextSize = 13
githubBox.TextEditable = false
githubBox.ClearTextOnFocus = false
githubBox.Parent = settingsPage
round(githubBox)

local afkButton = Instance.new("TextButton")
afkButton.Position = UDim2.fromOffset(10, 12)
afkButton.Size = UDim2.new(1, -20, 0, 32)
afkButton.BackgroundColor3 = Color3.fromRGB(65, 125, 75)
afkButton.BorderSizePixel = 0
afkButton.Text = "Anti-AFK: ON"
afkButton.TextColor3 = Color3.new(1, 1, 1)
afkButton.Font = Enum.Font.GothamBold
afkButton.TextSize = 13
afkButton.Parent = settingsPage
round(afkButton)

afkButton.Activated:Connect(function()
	antiAfk = not antiAfk
	afkButton.Text = antiAfk and "Anti-AFK: ON" or "Anti-AFK: OFF"
	afkButton.BackgroundColor3 = antiAfk and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(110, 65, 65)
end)

-- ==========================================
-- CHAT SPY (Settings Tab)
-- ==========================================
local chatSpyFrame = Instance.new("Frame")
chatSpyFrame.Position = UDim2.fromOffset(10, 220)
chatSpyFrame.Size = UDim2.new(1, -20, 0, 180)
chatSpyFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
chatSpyFrame.BorderSizePixel = 0
chatSpyFrame.Parent = settingsPage
round(chatSpyFrame)

local chatSpyTitle = Instance.new("TextLabel")
chatSpyTitle.Size = UDim2.new(1, 0, 0, 25)
chatSpyTitle.BackgroundTransparency = 1
chatSpyTitle.Text = "Chat Spy"
chatSpyTitle.TextColor3 = Color3.fromRGB(130, 175, 255)
chatSpyTitle.Font = Enum.Font.GothamBold
chatSpyTitle.TextSize = 14
chatSpyTitle.TextXAlignment = Enum.TextXAlignment.Left
chatSpyTitle.Parent = chatSpyFrame

local chatSpyToggle = Instance.new("TextButton")
chatSpyToggle.Position = UDim2.fromOffset(10, 30)
chatSpyToggle.Size = UDim2.new(1, -20, 0, 30)
chatSpyToggle.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
chatSpyToggle.BorderSizePixel = 0
chatSpyToggle.Text = "Chat Spy: OFF"
chatSpyToggle.TextColor3 = Color3.new(1, 1, 1)
chatSpyToggle.Font = Enum.Font.GothamBold
chatSpyToggle.TextSize = 13
chatSpyToggle.Parent = chatSpyFrame
round(chatSpyToggle)

local chatLog = Instance.new("ScrollingFrame")
chatLog.Position = UDim2.fromOffset(10, 65)
chatLog.Size = UDim2.new(1, -20, 1, -75)
chatLog.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
chatLog.BorderSizePixel = 0
chatLog.ScrollBarThickness = 4
chatLog.CanvasSize = UDim2.new(0, 0, 0, 0)
chatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatLog.Parent = chatSpyFrame
round(chatLog)

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = chatLog

local chatSpyEnabled = false
local spyConnection = nil

local function addLogEntry(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = chatLog
	task.wait()
	chatLog.CanvasPosition = Vector2.new(0, chatLog.AbsoluteCanvasSize.Y)
end

chatSpyToggle.Activated:Connect(function()
	chatSpyEnabled = not chatSpyEnabled
	if chatSpyEnabled then
		chatSpyToggle.Text = "Chat Spy: ON"
		chatSpyToggle.BackgroundColor3 = Color3.fromRGB(65, 125, 75)
		spyConnection = TextChatService.MessageReceived:Connect(function(message)
			local source = message.TextSource
			if not source then return end
			local sender = Players:GetPlayerByUserId(source.UserId)
			if not sender or sender == player then return end
			local text = message.Text
			local isHidden = text:sub(1, 1) == ";"
			local isMuted = false
			pcall(function() isMuted = sender:HasTag("Muted") end)
			local prefix = ""
			local color = Color3.fromRGB(200, 200, 200)
			if isHidden then
				prefix = "[HIDDEN] "
				color = Color3.fromRGB(255, 100, 100)
			elseif isMuted then
				prefix = "[MUTED] "
				color = Color3.fromRGB(255, 165, 0)
			end
			addLogEntry(prefix .. sender.Name .. ": " .. text, color)
			print("[CHAT SPY] " .. sender.Name .. ": " .. text)
		end)
	else
		chatSpyToggle.Text = "Chat Spy: OFF"
		chatSpyToggle.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
		if spyConnection then spyConnection:Disconnect() spyConnection = nil end
	end
end)

gui.Destroying:Connect(function()
	if spyConnection then spyConnection:Disconnect() end
end)
-- ==========================================

-- ==========================================
-- DESTRUCTION PAGE & GRIEF TOOL INTEGRATION (WITH DROPDOWN)
-- ==========================================
local destructionPage = Instance.new("Frame")
destructionPage.Position = UDim2.fromOffset(0, 72)
destructionPage.Size = UDim2.new(1, 0, 1, -72)
destructionPage.BackgroundTransparency = 1
destructionPage.BorderSizePixel = 0
destructionPage.Visible = false
destructionPage.Parent = frame

-- Dropdown Selection Button (NEW)
local selectTargetsBtn = Instance.new("TextButton")
selectTargetsBtn.Position = UDim2.fromOffset(10, 12)
selectTargetsBtn.Size = UDim2.new(1, -20, 0, 32)
selectTargetsBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 57)
selectTargetsBtn.BorderSizePixel = 0
selectTargetsBtn.Text = "Select Targets: None"
selectTargetsBtn.TextColor3 = Color3.new(1, 1, 1)
selectTargetsBtn.Font = Enum.Font.GothamBold
selectTargetsBtn.TextSize = 13
selectTargetsBtn.Parent = destructionPage
round(selectTargetsBtn)

-- Dropdown Frame (NEW - parented to frame to avoid clipping)
local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Position = UDim2.fromOffset(10, 50)
dropdownFrame.Size = UDim2.new(1, -20, 0, 150)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.ScrollBarThickness = 4
dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownFrame.Visible = false
dropdownFrame.ZIndex = 10
dropdownFrame.ClipsDescendants = false
dropdownFrame.Parent = frame  -- PARENTED TO FRAME, NOT destructionPage
round(dropdownFrame)

local dropdownLayout = Instance.new("UIListLayout")
dropdownLayout.Padding = UDim.new(0, 4)
dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownLayout.Parent = dropdownFrame

local dropdownPadding = Instance.new("UIPadding")
dropdownPadding.PaddingTop = UDim.new(0, 4)
dropdownPadding.PaddingBottom = UDim.new(0, 4)
dropdownPadding.PaddingLeft = UDim.new(0, 4)
dropdownPadding.PaddingRight = UDim.new(0, 4)
dropdownPadding.Parent = dropdownFrame

-- Start Grief Button (repositioned)
local toggleGriefButton = Instance.new("TextButton")
toggleGriefButton.Position = UDim2.fromOffset(10, 54)
toggleGriefButton.Size = UDim2.new(1, -20, 0, 32)
toggleGriefButton.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
toggleGriefButton.BorderSizePixel = 0
toggleGriefButton.Text = "Start Grief"
toggleGriefButton.TextColor3 = Color3.new(1, 1, 1)
toggleGriefButton.Font = Enum.Font.GothamBold
toggleGriefButton.TextSize = 13
toggleGriefButton.Parent = destructionPage
round(toggleGriefButton)

local griefStatusLabel = Instance.new("TextLabel")
griefStatusLabel.Position = UDim2.fromOffset(10, 96)
griefStatusLabel.Size = UDim2.new(1, -20, 0, 24)
griefStatusLabel.BackgroundTransparency = 1
griefStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
griefStatusLabel.Font = Enum.Font.GothamBold
griefStatusLabel.TextSize = 13
griefStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
griefStatusLabel.Text = ""
griefStatusLabel.Parent = destructionPage

-- ==========================================
-- LOGIC
-- ==========================================
local isGriefing = false
local griefLoop = nil
local selectedTargets = {}
local activeHighlights = {}
local isDropdownOpen = false

local TEXT_START = "Start Grief"
local TEXT_STOP = "Stop Grief"
local ws = 0.05

local function createDropdownButton(text, isSelected)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 28)
	btn.BackgroundColor3 = isSelected and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(50, 50, 57)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.ZIndex = 11
	btn.Parent = dropdownFrame
	round(btn)
	return btn
end

local function updateSelectBtnText()
	if selectedTargets["ALL"] then
		selectTargetsBtn.Text = "Select Targets: ALL"
	elseif next(selectedTargets) then
		local count = 0
		for _ in pairs(selectedTargets) do count = count + 1 end
		selectTargetsBtn.Text = "Select Targets: " .. count .. " Player(s)"
	else
		selectTargetsBtn.Text = "Select Targets: None"
	end
end

local function clearHighlights()
	for _, h in pairs(activeHighlights) do 
		pcall(function() h:Destroy() end) 
	end
	activeHighlights = {}
end

local function applyHighlights()
	clearHighlights()
	local bricksFolder = workspace:FindFirstChild("Bricks")
	if not bricksFolder then return end

	local selectAll = selectedTargets["ALL"]

	for _, folder in pairs(bricksFolder:GetChildren()) do
		local shouldHighlight = selectAll or selectedTargets[folder.Name]
		if shouldHighlight then
			local h = Instance.new("Highlight")
			h.Adornee = folder
			h.FillColor = Color3.fromRGB(255, 0, 0)
			h.OutlineColor = Color3.fromRGB(255, 50, 50)
			h.FillTransparency = 0.8
			h.OutlineTransparency = 0.2
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = folder
			table.insert(activeHighlights, h)
		end
	end
end

local function populateDropdown()
	for _, child in pairs(dropdownFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local allBtn = createDropdownButton("All Players", selectedTargets["ALL"])
	allBtn.Activated:Connect(function()
		if selectedTargets["ALL"] then
			selectedTargets = {}
		else
			selectedTargets = { ["ALL"] = true }
		end
		populateDropdown()
		updateSelectBtnText()
		applyHighlights()
	end)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = createDropdownButton(plr.Name, selectedTargets[plr.Name])
			btn.Activated:Connect(function()
				selectedTargets[plr.Name] = not selectedTargets[plr.Name]
				selectedTargets["ALL"] = nil
				populateDropdown()
				updateSelectBtnText()
				applyHighlights()
			end)
		end
	end
end

selectTargetsBtn.Activated:Connect(function()
	isDropdownOpen = not isDropdownOpen
	dropdownFrame.Visible = isDropdownOpen
	if isDropdownOpen then
		populateDropdown()
		toggleGriefButton.Position = UDim2.fromOffset(10, 220)
		griefStatusLabel.Position = UDim2.fromOffset(10, 260)
	else
		toggleGriefButton.Position = UDim2.fromOffset(10, 54)
		griefStatusLabel.Position = UDim2.fromOffset(10, 96)
	end
end)

Players.PlayerAdded:Connect(function() if isDropdownOpen then populateDropdown() end end)
Players.PlayerRemoving:Connect(function() 
	selectedTargets["ALL"] = nil
	if isDropdownOpen then populateDropdown() end
	applyHighlights() 
end)

local bricksFolder = workspace:FindFirstChild("Bricks")
if bricksFolder then
	bricksFolder.ChildAdded:Connect(applyHighlights)
	bricksFolder.ChildRemoved:Connect(applyHighlights)
end

updateSelectBtnText()
applyHighlights()

-- Griefing Logic (Updated to use dropdown)
local function getSelectedPlayers()
	local players = {}
	if selectedTargets["ALL"] then
		local bf = workspace:FindFirstChild("Bricks")
		if bf then
			for _, folder in pairs(bf:GetChildren()) do
				players[folder.Name] = true
			end
		end
	else
		for name, _ in pairs(selectedTargets) do
			players[name] = true
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

	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		table.sort(blocks, function(a, b)
			return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
		end)
	end
	return blocks
end

local function findDeleteTools()
	local dtools = {}
	for _, v in pairs(player.Backpack:GetChildren()) do
		if v:IsA("Tool") and v.Name == "Delete" and v:FindFirstChild("Script") and v.Script:FindFirstChild("Event") then
			table.insert(dtools, {bt = v, e = v.Script.Event})
		end
	end
	if player.Character then
		for _, v in pairs(player.Character:GetChildren()) do
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
		griefStatusLabel.Text = "Delete tool not found"
		task.wait(1)
		griefStatusLabel.Text = ""
		return
	end

	local selectedPlayers = getSelectedPlayers()
	if not next(selectedPlayers) then
		griefStatusLabel.Text = "No players selected"
		task.wait(1)
		griefStatusLabel.Text = ""
		return
	end

	isGriefing = true
	toggleGriefButton.Text = TEXT_STOP
	toggleGriefButton.BackgroundColor3 = Color3.fromRGB(65, 125, 75)
	griefStatusLabel.Text = "Griefing..."

	griefLoop = task.spawn(function()
		local dti = 0
		local lastRefreshTime = 0
		if type(shared.DeleteToolRefresh) == "function" then
			shared.DeleteToolRefresh()
		end
		lastRefreshTime = tick()

		while isGriefing do
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then task.wait() continue end

			local dtools = findDeleteTools()
			if #dtools > 0 then
				local targetBlocks = getAllTargetBlocks()
				if #targetBlocks > 0 then
					if tick() - lastRefreshTime >= 5 then
						if type(shared.DeleteToolRefresh) == "function" then
							shared.DeleteToolRefresh()
						end
						lastRefreshTime = tick()
					end
					for _, block in pairs(targetBlocks) do
						if not isGriefing then break end
						if block and block:IsDescendantOf(workspace) then
							dti = dti + 1
							local dt = dtools[(dti % #dtools) + 1]
							pcall(function()
								dt.e:FireServer(block, hrp.Position)
							end)
							task.wait(ws / #dtools)
						end
					end
				else
					task.wait(0.5)
				end
			else
				task.wait(1)
			end
			task.wait()
		end
	end)
end

local function stopGrief()
	isGriefing = false
	toggleGriefButton.Text = TEXT_START
	toggleGriefButton.BackgroundColor3 = Color3.fromRGB(110, 65, 65)
	griefStatusLabel.Text = "Stopped"
	if griefLoop then
		task.cancel(griefLoop)
		griefLoop = nil
	end
	task.wait(0.1)
	local dtools = findDeleteTools()
	for _, dt in pairs(dtools) do
		if dt.bt.Parent == player.Character then
			dt.bt.Parent = player.Backpack
		end
	end
	task.wait(1)
	griefStatusLabel.Text = ""
end

toggleGriefButton.MouseEnter:Connect(function()
	if not isGriefing then
		local targetBlocks = getAllTargetBlocks()
		if #targetBlocks == 0 and next(selectedTargets) then
			griefStatusLabel.Text = "No Blocks Found"
		end
	end
end)

toggleGriefButton.MouseLeave:Connect(function()
	if not isGriefing then
		griefStatusLabel.Text = ""
	end
end)

toggleGriefButton.Activated:Connect(function()
	if isGriefing then
		stopGrief()
	else
		startGrief()
	end
end)

gui.Destroying:Connect(function()
	if isGriefing then stopGrief() end
	clearHighlights()
	dropdownFrame:Destroy()
end)
-- ==========================================
title.Size = UDim2.new(1, 0, 0, 26)
title.TextSize = 13

collapseButton.Size = UDim2.fromOffset(20, 20)
collapseButton.Position = UDim2.new(1, -24, 0, 3)
collapseButton.TextSize = 14

tabBar.Position = UDim2.fromOffset(4, 34)
tabBar.Size = UDim2.new(0, 104, 1, -42)

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(112, 32)
content.Size = UDim2.new(1, -118, 1, -40)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.Parent = frame

for _, page in ipairs({ managerPage, actionsPage, pingPage, followPage, destructionPage, settingsPage }) do
	page.Parent = content
	page.Position = UDim2.new()
	page.Size = UDim2.new(1, 0, 1, 0)
end
faqPage.Parent = content
faqPage.Position = UDim2.fromOffset(8, 8)
faqPage.Size = UDim2.new(1, -16, 1, -16)

mainInput.Position = UDim2.fromOffset(8, 8)
mainInput.Size = UDim2.fromOffset(196, 30)
addMain.Position = UDim2.fromOffset(8, 44)
addMain.Size = UDim2.fromOffset(196, 30)
altInput.Position = UDim2.fromOffset(8, 84)
altInput.Size = UDim2.fromOffset(196, 30)
addAlt.Position = UDim2.fromOffset(8, 120)
addAlt.Size = UDim2.fromOffset(196, 30)
commandToggle.Position = UDim2.fromOffset(8, 166)
commandToggle.Size = UDim2.fromOffset(196, 30)
accountList.Position = UDim2.fromOffset(212, 8)
accountList.Size = UDim2.new(1, -220, 1, -52)
removeButton.Position = UDim2.new(0, 212, 1, -36)
removeButton.Size = UDim2.new(1, -220, 0, 28)

sayInput.Position = UDim2.fromOffset(10, 8)
sayInput.Size = UDim2.new(1, -120, 0, 30)
sayButton.Position = UDim2.new(1, -100, 0, 8)
sayButton.Size = UDim2.fromOffset(90, 30)
actionGrid.Position = UDim2.fromOffset(10, 46)
actionGrid.Size = UDim2.new(1, -20, 0, 70)
actionLayout.CellSize = UDim2.new(1 / 6, -5, 0, 32)
loopSeconds.Position = UDim2.fromOffset(10, 126)
loopSeconds.Size = UDim2.fromOffset(60, 30)
loopCommand.Position = UDim2.fromOffset(76, 126)
loopCommand.Size = UDim2.new(1, -258, 0, 30)
startLoopButton.Position = UDim2.new(1, -176, 0, 126)
startLoopButton.Size = UDim2.fromOffset(80, 30)
stopLoopButton.Position = UDim2.new(1, -90, 0, 126)
stopLoopButton.Size = UDim2.fromOffset(80, 30)

pingToggle.Position = UDim2.fromOffset(10, 12)
pingToggle.Size = UDim2.new(0.5, -15, 0, 32)
pingSelf.Position = UDim2.fromOffset(10, 52)
pingSelf.Size = UDim2.new(0.5, -15, 0, 32)
pingInterval.Position = UDim2.fromOffset(10, 92)
pingInterval.Size = UDim2.new(0.5, -15, 0, 32)
for index, name in ipairs({ "Walk", "Jump", "Click" }) do
	optionButtons[name].Position = UDim2.new(0.5, 5, 0, 12 + (index - 1) * 40)
	optionButtons[name].Size = UDim2.new(0.5, -15, 0, 32)
end

local altMode = false
local forceControls = false

local altNotice = Instance.new("TextLabel")
altNotice.Position = UDim2.fromOffset(10, 30)
altNotice.Size = UDim2.new(1, -20, 1, -40)
altNotice.BackgroundTransparency = 1
altNotice.Text = "Registered as an alt."
altNotice.TextWrapped = true
altNotice.Font = Enum.Font.GothamBold
altNotice.TextSize = 30
altNotice.TextColor3 = Color3.fromRGB(120, 220, 150)
altNotice.ZIndex = 2
altNotice.Visible = false
altNotice.Parent = frame

local activeTab = "Manager"
local expanded = true
local fullSize = frame.Size

local viewListeners = {}

local function applyView()
	local function showPages(shown)
		altNotice.Visible = shown and altMode
		local visible = shown and not altMode
		tabBar.Visible = visible
		managerPage.Visible = visible and activeTab == "Manager"
		actionsPage.Visible = visible and activeTab == "Actions"
		pingPage.Visible = visible and activeTab == "Ping"
		followPage.Visible = visible and activeTab == "Move"
		faqPage.Visible = visible and activeTab == "FAQ"
		settingsPage.Visible = visible and activeTab == "Settings"
		destructionPage.Visible = visible and activeTab == "Destruction"
		for _, listener in ipairs(viewListeners) do
			listener(visible)
		end
	end

	collapseButton.Text = expanded and "-" or "+"
	for name, tab in pairs(tabButtons) do
		tab.BackgroundColor3 = name == activeTab and Color3.fromRGB(75, 110, 170) or Color3.fromRGB(55, 55, 63)
	end

	local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = expanded and (altMode and UDim2.fromOffset(fullSize.X.Offset, 150) or fullSize)
			or UDim2.fromOffset(fullSize.X.Offset, 26),
	})
	if expanded then
		showPages(true)
		tween:Play()
	else
		tween:Play()
		tween.Completed:Connect(function()
			if not expanded then
				showPages(false)
			end
		end)
	end
end

local function refreshAltMode()
	local nowAlt = hasRole(player.Name, "Alt") and not forceControls
	if nowAlt ~= altMode then
		altMode = nowAlt
		applyView()
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

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if processed or destroyed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		expanded = not expanded
		applyView()
	elseif input.KeyCode == Enum.KeyCode.RightControl then
		forceControls = not forceControls
		refreshAltMode()
	end
end)

applyView()

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
accentLine.Position = UDim2.fromOffset(0, 26)
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
			TweenService:Create(inst, TweenInfo.new(0.12), { BackgroundTransparency = math.max((inst:GetAttribute("BaseT") or 0) - 0.2, 0) }):Play()
		end)
		inst.MouseLeave:Connect(function()
			TweenService:Create(inst, TweenInfo.new(0.12), { BackgroundTransparency = inst:GetAttribute("BaseT") or 0 }):Play()
		end)
	end
end
for _, inst in ipairs(frame:GetDescendants()) do
	polish(inst)
end

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
table.insert(viewListeners, function(visible)
	footer.Visible = false
end)

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

		local pingOn = pingEnabled or relayOn
		footer.Text = ("Cmds %s  |  %dM %dA  |  Ping %s"):format(
			commandEnabled and "ON" or "OFF", mains, alts, pingOn and "ON" or "OFF"
		)

		pingToggle.Text = relayOn and "Ping Alts: ON" or "Ping Alts: OFF"
		pingToggle.BackgroundColor3 = relayOn and Color3.fromRGB(65, 125, 75) or Color3.fromRGB(110, 65, 65)

		if hasRole(player.Name, "Main") then
			followStatus.Text = "Main"
		else
			followStatus.Text = followingName and (followingMode .. ": " .. followingName) or "Idle"
		end

		refreshAltMode()

		title.Text = ("  CORTEGE  |  Cmds %s  |  %dM %dA  |  Ping %s"):format(
			commandEnabled and "ON" or "OFF", mains, alts, pingOn and "ON" or "OFF"
		)

		task.wait(0.5)
	end
end)

local function setBase(inst, value)
	inst:SetAttribute("BaseT", value)
	inst.BackgroundTransparency = value
end

frame.BackgroundTransparency = 0.2
frameStroke.Transparency = 0.3

for _, inst in ipairs(frame:GetDescendants()) do
	if inst:IsA("TextButton") then
		setBase(inst, 0.25)
	elseif inst:IsA("TextBox") then
		setBase(inst, 0.4)
	elseif inst:IsA("ScrollingFrame") then
		setBase(inst, 0.5)
	elseif inst:IsA("UIStroke") and inst.Parent:IsA("TextBox") then
		inst.Transparency = 0.5
	end
end

for _, inst in ipairs({ title, tabBar, footer }) do
	setBase(inst, 0.35)
end
