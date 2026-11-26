for _, inst in ipairs({ title, tabBar, footer }) do
	setBase(inst, 0.35)
end

-- Griefing functionality (added code)
new: local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ToggleGriefRow = script.Parent
local GriefGroup = ToggleGriefRow.Parent
local ToggleGriefButton = ToggleGriefRow:WaitForChild("ToggleGriefButton")

local SelectDRow = GriefGroup:FindFirstChild("SelectDRow")

local isGriefing = false
local griefLoop = nil

local TEXT_START = "Start Grief"
local TEXT_STOP = "Stop Grief"
local TEXT_NO_BLOCKS = "No Blocks Found"

local ws = 0.05 -- wait-time budget per delete pass

-- Reads whichever players were checked in the dropdown
local function getSelectedPlayers()
    if shared.GriefSelectedPlayers then
        return shared.GriefSelectedPlayers
    end
    if SelectDRow then
        local attr = SelectDRow:GetAttribute("SelectedPlayers")
        if attr and attr ~= "" then
            local players = {}
            for name in string.gmatch(attr, "[^,]+") do
                players[name] = true
            end
            return players
        end
    end
    return {}
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
        ToggleGriefButton.Text = "Delete tool not found"
        task.wait(1)
        ToggleGriefButton.Text = TEXT_START
        return
    end

    local selectedPlayers = getSelectedPlayers()
    if not next(selectedPlayers) then
        ToggleGriefButton.Text = "No players selected"
        task.wait(1)
        ToggleGriefButton.Text = TEXT_START
        return
    end

    isGriefing = true
    ToggleGriefButton.Text = TEXT_STOP

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
                    for _, block in pairs(targetBlocks) do
                        if not isGriefing then break end
                        if block and block:IsDescendantOf(workspace) then
                            dti = dti + 1
                            local dt = dtools[(dti % #dtools) + 1]
                            pcall(function()
                                dt.e:FireServer(block, hrp.Position) -- fires the real Delete remote
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
    ToggleGriefButton.Text = TEXT_START
    if griefLoop then
        task.cancel(griefLoop)
        griefLoop = nil
    end
    task.wait(0.1)
    local dtools = findDeleteTools()
    for _, dt in pairs(dtools) do
        if dt.bt.Parent == LocalPlayer.Character then
            dt.bt.Parent = LocalPlayer.Backpack
        end
    end
end

ToggleGriefButton.MouseEnter:Connect(function()
    if not isGriefing then
        local targetBlocks = getAllTargetBlocks()
        if #targetBlocks == 0 then
            ToggleGriefButton.Text = TEXT_NO_BLOCKS
        end
    end
end)

ToggleGriefButton.MouseLeave:Connect(function()
    if not isGriefing then
        ToggleGriefButton.Text = TEXT_START
    end
end)

ToggleGriefButton.MouseButton1Click:Connect(function()
    if isGriefing then
        stopGrief()
    else
        startGrief()
    end
end)
