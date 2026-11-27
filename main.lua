--[[
	DropdownMaster — Improved AgarWare dropdown
	• Outline only exists on the panel → disappears completely when collapsed
	• Search bar, player icons, checkmarks, smooth animation
	• Same API: shared.DropdownMaster.create({dropdown=..., multiSelect=..., showIcons=..., onMultiSelectChange=..., bottomButtons=...})
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local ACCENT  = Color3.fromRGB(0, 124, 255)
local BG      = Color3.fromRGB(17, 17, 17)
local ITEM_BG = Color3.fromRGB(25, 25, 25)
local HOVER   = Color3.fromRGB(40, 40, 40)
local BORDER  = Color3.fromRGB(58, 58, 58)
local WHITE   = Color3.fromRGB(255, 255, 255)
local GREY    = Color3.fromRGB(150, 150, 150)

local FONT = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function getScreenGui(obj)
	local p = obj
	while p do
		if p:IsA("ScreenGui") then return p end
		p = p.Parent
	end
	return LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AgarWareGui")
end

local function newCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 4)
	c.Parent = parent
	return c
end

local DropdownMaster = {}

function DropdownMaster.create(config)
	local dropdown      = config.dropdown
	local multiSelect   = config.multiSelect ~= false
	local showIcons     = config.showIcons == true
	local onChange      = config.onMultiSelectChange
	local bottomButtons = config.bottomButtons or {}
	local initial       = config.initialSelection or {}

	local sg = getScreenGui(dropdown)

	-- remove any leftover red outline stuck on the button itself
	for _, child in ipairs(dropdown:GetChildren()) do
		if child:IsA("UIStroke") then child:Destroy() end
	end
	dropdown.Text = ""

	-- label + arrow on the button
	local mainLabel = Instance.new("TextLabel")
	mainLabel.Name = "MainLabel"
	mainLabel.BackgroundTransparency = 1
	mainLabel.Font = FONT
	mainLabel.TextSize = 14
	mainLabel.TextColor3 = WHITE
	mainLabel.TextXAlignment = Enum.TextXAlignment.Left
	mainLabel.TextTruncate = Enum.TextTruncate.AtEnd
	mainLabel.Size = UDim2.new(1, -24, 1, 0)
	mainLabel.Position = UDim2.new(0, 5, 0, 0)
	mainLabel.Text = "Select Players"
	mainLabel.ZIndex = dropdown.ZIndex + 1
	mainLabel.Parent = dropdown

	local arrow = Instance.new("TextLabel")
	arrow.Name = "DropdownArrow"
	arrow.BackgroundTransparency = 1
	arrow.Font = FONT
	arrow.TextSize = 14
	arrow.TextColor3 = GREY
	arrow.Size = UDim2.new(0, 18, 1, 0)
	arrow.Position = UDim2.new(1, -20, 0, 0)
	arrow.Text = "v"
	arrow.ZIndex = dropdown.ZIndex + 1
	arrow.Parent = dropdown

	-- panel (outline lives HERE, so closing the panel kills the outline)
	local panel = Instance.new("Frame")
	panel.Name = "DropdownPanel"
	panel.BackgroundColor3 = BG
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 1000
	panel.Parent = sg
	newCorner(panel, 6)

	local stroke = Instance.new("UIStroke")
	stroke.Name = "DropdownOutline"
	stroke.Color = ACCENT
	stroke.Thickness = 1.5
	stroke.Transparency = 1
	stroke.Parent = panel

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 3)
	layout.Parent = panel

	local search = Instance.new("TextBox")
	search.Name = "SearchBox"
	search.LayoutOrder = 0
	search.Size = UDim2.new(1, 0, 0, 22)
	search.BackgroundColor3 = ITEM_BG
	search.BorderSizePixel = 0
	search.Font = FONT
	search.TextSize = 13
	search.TextColor3 = WHITE
	search.PlaceholderText = "Search..."
	search.PlaceholderColor3 = GREY
	search.ClearTextOnFocus = false
	search.ZIndex = 1001
	search.Parent = panel
	newCorner(search, 4)

	local list = Instance.new("ScrollingFrame")
	list.Name = "PlayerList"
	list.LayoutOrder = 1
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 3
	list.ScrollBarImageColor3 = BORDER
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.ZIndex = 1001
	list.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = list

	local bottom = Instance.new("Frame")
	bottom.Name = "BottomButtons"
	bottom.LayoutOrder = 2
	bottom.AutomaticSize = Enum.AutomaticSize.Y
	bottom.BackgroundTransparency = 1
	bottom.BorderSizePixel = 0
	bottom.ZIndex = 1001
	bottom.Parent = panel

	local bottomLayout = Instance.new("UIListLayout")
	bottomLayout.FillDirection = Enum.FillDirection.Horizontal
	bottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bottomLayout.Padding = UDim.new(0, 3)
	bottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	bottomLayout.Parent = bottom

	local state = {
		selectedPlayers = {},
		showDisplay = false,
		mainLabel = mainLabel,
		button = nil,
	}
	for name in pairs(initial) do state.selectedPlayers[name] = true end

	local isOpen = false
	local listHeight = 0
	local closeDropdown

	local function notifyChange()
		if multiSelect then
			local count = 0
			for _ in pairs(state.selectedPlayers) do count += 1 end
			mainLabel.Text = count > 0 and (count .. " Players Selected") or "Select Players"
		end
		if onChange then onChange(state.selectedPlayers) end
	end

	local function playerName(player)
		return state.showDisplay and player.DisplayName or player.Name
	end

	local function computeHeight()
		return 8 + 22 + 3 + listHeight + (#bottomButtons > 0 and (3 + 20) or 0)
	end

	local function rebuildList()
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local filter = search.Text:lower()
		local entries = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local name = playerName(player)
			if filter == "" or name:lower():find(filter, 1, true) then
				table.insert(entries, {player = player, name = name})
			end
		end
		table.sort(entries, function(a, b) return a.name:lower() < b.name:lower() end)

		local rowHeight = 26
		for i, entry in ipairs(entries) do
			local player = entry.player
			local selected = state.selectedPlayers[player.Name] == true

			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, rowHeight)
			row.BackgroundColor3 = selected and HOVER or ITEM_BG
			row.BorderSizePixel = 0
			row.LayoutOrder = i
			row.ZIndex = 1002
			row.Parent = list
			newCorner(row, 4)

			local labelX = 6
			if showIcons then
				labelX = 28
				local icon = Instance.new("ImageLabel")
				icon.Size = UDim2.new(0, 20, 0, 20)
				icon.Position = UDim2.new(0, 4, 0.5, -10)
				icon.BackgroundTransparency = 1
				icon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
				icon.ZIndex = 1003
				icon.Parent = row
				newCorner(icon, 10)
				task.spawn(function()
					local ok, url = pcall(function()
						return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size42x42)
					end)
					if ok and icon.Parent then icon.Image = url end
				end)
			end

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.Font = FONT
			label.TextSize = 13
			label.TextColor3 = selected and ACCENT or WHITE
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.Size = UDim2.new(1, -(labelX + 22), 1, 0)
			label.Position = UDim2.new(0, labelX, 0, 0)
			label.Text = entry.name
			label.ZIndex = 1003
			label.Parent = row

			local tick = Instance.new("Frame")
			tick.Size = UDim2.new(0, 14, 0, 14)
			tick.Position = UDim2.new(1, -18, 0.5, -7)
			tick.BackgroundColor3 = selected and ACCENT or Color3.new(0, 0, 0)
			tick.BorderColor3 = BORDER
			tick.BorderSizePixel = 1
			tick.ZIndex = 1003
			tick.Parent = row
			newCorner(tick, 3)

			local click = Instance.new("TextButton")
			click.Size = UDim2.new(1, 0, 1, 0)
			click.BackgroundTransparency = 1
			click.Text = ""
			click.ZIndex = 1004
			click.Parent = row

			click.MouseEnter:Connect(function()
				if not state.selectedPlayers[player.Name] then row.BackgroundColor3 = HOVER end
			end)
			click.MouseLeave:Connect(function()
				if not state.selectedPlayers[player.Name] then row.BackgroundColor3 = ITEM_BG end
			end)
			click.MouseButton1Click:Connect(function()
				if multiSelect then
					state.selectedPlayers[player.Name] = state.selectedPlayers[player.Name] and nil or true
					notifyChange()
					rebuildList()
				else
					state.selectedPlayers = {[player.Name] = true}
					mainLabel.Text = entry.name
					notifyChange()
					closeDropdown()
				end
			end)
		end

		local visible = math.min(#entries, 8)
		listHeight = math.max(visible * (rowHeight + 2), 26)
		list.Size = UDim2.new(1, 0, 0, listHeight)
	end

	local function positionPanel()
		local absPos = dropdown.AbsolutePosition
		local absSize = dropdown.AbsoluteSize
		panel.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
		panel.Size = UDim2.new(0, math.max(absSize.X, 160), 0, 0)
	end

	local function openDropdown()
		if isOpen then return end
		repeat task.wait() until dropdown.AbsoluteSize.X > 0
		isOpen = true
		arrow.Text = "^"
		search.Text = ""
		positionPanel()
		rebuildList()
		panel.Visible = true
		stroke.Transparency = 0
		local target = computeHeight()
		TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(0, panel.Size.X.Offset, 0, target)}):Play()
	end

	closeDropdown = function()
		if not isOpen then return end
		isOpen = false
		arrow.Text = "v"
		stroke.Transparency = 1 -- outline gone instantly
		local t = TweenService:Create(panel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Size = UDim2.new(0, panel.Size.X.Offset, 0, 0)})
		t:Play()
		t.Completed:Connect(function()
			if not isOpen then panel.Visible = false end
		end)
	end

	-- bottom buttons
	for i, cfg in ipairs(bottomButtons) do
		local btn = Instance.new("TextButton")
		btn.Name = "BottomBtn_" .. i
		btn.LayoutOrder = i
		btn.Size = UDim2.new(1 / #bottomButtons, -3, 0, 20)
		btn.BackgroundColor3 = ITEM_BG
		btn.BorderSizePixel = 0
		btn.Font = FONT
		btn.TextSize = 12
		btn.TextColor3 = WHITE
		btn.Text = cfg.text
		btn.AutoButtonColor = true
		btn.ZIndex = 1002
		btn.Parent = bottom
		newCorner(btn, 4)
		btn.MouseButton1Click:Connect(function()
			state.button = btn
			cfg.onClick(state)
		end)
	end

	state.notifyChange = notifyChange
	state.rebuildList = rebuildList
	state.setShowDisplay = function(v) state.showDisplay = v end

	dropdown.MouseButton1Click:Connect(function()
		if isOpen then closeDropdown() else openDropdown() end
	end)

	search:GetPropertyChangedSignal("Text"):Connect(function()
		rebuildList()
		if isOpen then
			panel.Size = UDim2.new(0, panel.Size.X.Offset, 0, computeHeight())
		end
	end)

	-- close on outside click
	UserInputService.InputBegan:Connect(function(input)
		if not isOpen then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local pP, pS = panel.AbsolutePosition, panel.AbsoluteSize
			local dP, dS = dropdown.AbsolutePosition, dropdown.AbsoluteSize
			local inside =
				(pos.X >= pP.X and pos.X <= pP.X + pS.X and pos.Y >= pP.Y and pos.Y <= pP.Y + pS.Y) or
				(pos.X >= dP.X and pos.X <= dP.X + dS.X and pos.Y >= dP.Y and pos.Y <= dP.Y + dS.Y)
			if not inside then closeDropdown() end
		end
	end)

	-- keep list/selection fresh
	Players.PlayerRemoving:Connect(function(player)
		if state.selectedPlayers[player.Name] then
			state.selectedPlayers[player.Name] = nil
			notifyChange()
			if isOpen then rebuildList() end
		end
	end)
	Players.PlayerAdded:Connect(function()
		if isOpen then rebuildList() end
	end)

	notifyChange()
end

shared.DropdownMaster = DropdownMaster
