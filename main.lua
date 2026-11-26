-- LocalScript
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AltManagerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 200)
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

local list = Instance.new("TextLabel")
list.Position = UDim2.fromOffset(10, 50)
list.Size = UDim2.new(1, -20, 1, -60)
list.BackgroundTransparency = 1
list.TextXAlignment = Enum.TextXAlignment.Left
list.TextYAlignment = Enum.TextYAlignment.Top
list.TextWrapped = true
list.TextColor3 = Color3.fromRGB(220, 220, 220)
list.Font = Enum.Font.Gotham
list.TextSize = 14
list.Parent = frame

local Accounts = {} -- Populate through your AccountManager module
local function refresh()
	local lines = {}
	for i, account in ipairs(Accounts) do
		table.insert(lines, string.format(
			"%d. %s  (Lv %d)",
			i,
			account.Name or "Account",
			account.Level or 1
		))
	end
	list.Text = table.concat(lines, "\n")
end

refresh()
