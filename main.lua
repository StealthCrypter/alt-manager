-- main.lua
-- Everything in ONE file: Config + Utils + AccountManager + startup.
-- Put this in a regular SERVER Script inside ServerScriptService.
-- If you sync with Rojo, name the file main.server.lua instead.
--
-- NOTE: No saving at all now. Accounts only live in memory while the player
-- is in the server, and are gone when they leave.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ========================================
-- CONFIG
-- ========================================

local Config = {
	MaxAccounts = 5, -- max accounts per player
}

-- ========================================
-- UTILS
-- ========================================

local Utils = {}

local CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
local rng = Random.new()

function Utils.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

function Utils.GenerateRandomString(length)
	local parts = table.create(length)
	for i = 1, length do
		local idx = rng:NextInteger(1, #CHARS)
		parts[i] = string.sub(CHARS, idx, idx) -- exactly ONE character
	end
	return table.concat(parts)
end

-- "Just now", "5m ago", "3h ago", or a date for older timestamps.
function Utils.FormatTimeAgo(timestamp)
	local diff = math.max(0, os.time() - timestamp)
	if diff < 60 then
		return "Just now"
	elseif diff < 3600 then
		return math.floor(diff / 60) .. "m ago"
	elseif diff < 86400 then
		return math.floor(diff / 3600) .. "h ago"
	end
	return os.date("%Y-%m-%d", timestamp)
end

function Utils.FormatDuration(seconds)
	seconds = math.floor(seconds)
	if seconds < 60 then
		return seconds .. "s"
	elseif seconds < 3600 then
		return math.floor(seconds / 60) .. "m"
	elseif seconds < 86400 then
		return math.floor(seconds / 3600) .. "h"
	end
	return math.floor(seconds / 86400) .. "d"
end

-- Plain-text replace (no pattern symbols), returns ONE value.
function Utils.ReplaceAll(str, old, new)
	local escapedOld = old:gsub("%p", "%%%0")
	local escapedNew = new:gsub("%%", "%%%%")
	return (str:gsub(escapedOld, escapedNew))
end

function Utils.Trim(str)
	return str:match("^%s*(.-)%s*$")
end

-- Pads on the LEFT so the text is right-aligned.
function Utils.PadLeft(str, totalLength, padChar)
	padChar = padChar or " "
	return string.rep(padChar, math.max(0, totalLength - #str)) .. str
end

-- Pads on the RIGHT so the text is left-aligned.
function Utils.PadRight(str, totalLength, padChar)
	padChar = padChar or " "
	return str .. string.rep(padChar, math.max(0, totalLength - #str))
end

function Utils.Round(num, decimalPlaces)
	local multiplier = 10 ^ (decimalPlaces or 2)
	return math.floor(num * multiplier + 0.5) / multiplier
end

function Utils.Clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

function Utils.Lerp(a, b, t)
	return a + (b - a) * t
end

function Utils.ShallowCopy(source)
	local copy = {}
	for k, v in pairs(source) do
		copy[k] = v
	end
	return copy
end

-- Handles tables that contain themselves.
function Utils.DeepCopy(source, seen)
	seen = seen or {}
	if seen[source] then
		return seen[source]
	end
	local copy = {}
	seen[source] = copy
	for k, v in pairs(source) do
		copy[k] = (type(v) == "table") and Utils.DeepCopy(v, seen) or v
	end
	return copy
end

-- Later tables overwrite earlier ones.
function Utils.MergeTables(...)
	local result = {}
	for _, tbl in ipairs({ ... }) do
		for k, v in pairs(tbl) do
			result[k] = v
		end
	end
	return result
end

function Utils.Wait(duration)
	return task.wait(duration)
end

function Utils.WaitRandom(min, max)
	return task.wait(rng:NextNumber(min, max))
end

function Utils.IsInRange(value, min, max)
	return value >= min and value <= max
end

-- ========================================
-- ACCOUNT MANAGER (in-memory only)
-- ========================================

local AccountManager = {}
AccountManager.__index = AccountManager

local function newAccount(name, displayName)
	return {
		Id = HttpService:GenerateGUID(false),
		Name = name,
		DisplayName = displayName or name,
		Level = 1,
		Points = 0,
		LastLogin = os.time(),
		Inventory = {},
		Settings = {
			GUIEnabled = true,
			NotificationsEnabled = true,
			AutoJoin = false,
		},
	}
end

function AccountManager.new(player)
	local self = setmetatable({}, AccountManager)
	self.Player = player
	self.Accounts = {}
	self.CurrentIndex = 1
	return self
end

function AccountManager:Initialize()
	table.insert(self.Accounts, newAccount(self.Player.Name, self.Player.DisplayName))
	self.CurrentIndex = 1
	return self
end

-- Call when the player leaves.
function AccountManager:Destroy()
	table.clear(self.Accounts)
end

function AccountManager:CreateAccount(name)
	if #self.Accounts >= Config.MaxAccounts then
		warn("Max accounts reached (" .. Config.MaxAccounts .. ")")
		return nil
	end

	local accountName = name or ("Alt" .. (#self.Accounts + 1))
	local account = newAccount(accountName)
	table.insert(self.Accounts, account)
	self.CurrentIndex = #self.Accounts
	return account
end

function AccountManager:RemoveAccount(index)
	if #self.Accounts <= 1 then
		warn("Can't remove the last account")
		return false
	end
	if type(index) ~= "number" or index < 1 or index > #self.Accounts then
		return false
	end

	table.remove(self.Accounts, index)
	-- Keep CurrentIndex pointing at a valid account.
	if self.CurrentIndex > index then
		self.CurrentIndex = self.CurrentIndex - 1
	end
	self.CurrentIndex = Utils.Clamp(self.CurrentIndex, 1, #self.Accounts)
	return true
end

-- Selects a different account. Returns the account, or nil if invalid.
function AccountManager:SwitchAccount(index)
	if type(index) ~= "number" or index < 1 or index > #self.Accounts then
		return nil
	end
	self.CurrentIndex = index
	local account = self.Accounts[index]
	account.LastLogin = os.time()
	return account
end

function AccountManager:GetCurrent()
	return self.Accounts[self.CurrentIndex]
end

function AccountManager:GetAllAccounts()
	return self.Accounts
end

function AccountManager:GetAccountCount()
	return #self.Accounts
end

function AccountManager:GetAccountInfo()
	local account = self:GetCurrent()
	if not account then
		return nil
	end
	return {
		Name = account.Name,
		DisplayName = account.DisplayName,
		Level = account.Level,
		Points = account.Points,
		LastLogin = Utils.FormatTimeAgo(account.LastLogin),
		Inventory = account.Inventory,
		Settings = account.Settings,
	}
end

-- ========================================
-- STARTUP: one manager per player
-- ========================================

local managers = {} -- [Player] = AccountManager

local function onPlayerAdded(player)
	local manager = AccountManager.new(player)
	managers[player] = manager
	manager:Initialize()
end

local function onPlayerRemoving(player)
	local manager = managers[player]
	if manager then
		manager:Destroy()
		managers[player] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before this script finished loading.
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
