-- main.lua
-- Client-side, in-memory account manager.
-- No DataStore or server-only APIs. Data is not saved or shared with the server.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ========================================
-- CONFIG
-- ========================================

local Config = {
	MaxAccounts = 5,
	MaxNameLength = 30,
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
	length = math.max(0, math.floor(tonumber(length) or 0))

	local parts = table.create(length)
	for i = 1, length do
		local index = rng:NextInteger(1, #CHARS)
		parts[i] = string.sub(CHARS, index, index)
	end

	return table.concat(parts)
end

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
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))

	if seconds < 60 then
		return seconds .. "s"
	elseif seconds < 3600 then
		return math.floor(seconds / 60) .. "m"
	elseif seconds < 86400 then
		return math.floor(seconds / 3600) .. "h"
	end

	return math.floor(seconds / 86400) .. "d"
end

function Utils.ReplaceAll(str, old, new)
	str = tostring(str)
	old = tostring(old)
	new = tostring(new)

	if old == "" then
		return str
	end

	local escapedOld = old:gsub("%p", "%%%0")
	local escapedNew = new:gsub("%%", "%%%%")

	return (str:gsub(escapedOld, escapedNew))
end

function Utils.Trim(str)
	return tostring(str):match("^%s*(.-)%s*$")
end

function Utils.PadLeft(str, totalLength, padChar)
	str = tostring(str)
	padChar = padChar or " "
	return string.rep(padChar, math.max(0, totalLength - #str)) .. str
end

function Utils.PadRight(str, totalLength, padChar)
	str = tostring(str)
	padChar = padChar or " "
	return str .. string.rep(padChar, math.max(0, totalLength - #str))
end

function Utils.Round(number, decimalPlaces)
	number = tonumber(number) or 0
	local multiplier = 10 ^ (decimalPlaces or 2)
	return math.floor(number * multiplier + 0.5) / multiplier
end

function Utils.Clamp(value, minValue, maxValue)
	return math.min(math.max(value, minValue), maxValue)
end

function Utils.Lerp(a, b, t)
	return a + (b - a) * t
end

function Utils.ShallowCopy(source)
	local copy = {}

	for key, value in pairs(source) do
		copy[key] = value
	end

	return copy
end

function Utils.DeepCopy(source, seen)
	if type(source) ~= "table" then
		return source
	end

	seen = seen or {}

	if seen[source] then
		return seen[source]
	end

	local copy = {}
	seen[source] = copy

	for key, value in pairs(source) do
		copy[Utils.DeepCopy(key, seen)] = Utils.DeepCopy(value, seen)
	end

	return copy
end

function Utils.MergeTables(...)
	local result = {}

	for _, source in ipairs({ ... }) do
		for key, value in pairs(source) do
			result[key] = value
		end
	end

	return result
end

function Utils.Wait(duration)
	return task.wait(duration)
end

function Utils.WaitRandom(minDuration, maxDuration)
	return task.wait(rng:NextNumber(minDuration, maxDuration))
end

function Utils.IsInRange(value, minValue, maxValue)
	return value >= minValue and value <= maxValue
end

local function normalizeName(name)
	if type(name) ~= "string" then
		return nil
	end

	name = Utils.Trim(name)

	if name == "" then
		return nil
	end

	return string.sub(name, 1, Config.MaxNameLength)
end

-- ========================================
-- ACCOUNT MANAGER
-- ========================================

local AccountManager = {}
AccountManager.__index = AccountManager

local function newAccount(name, displayName)
	local accountName = normalizeName(name) or "Account"
	local accountDisplayName = normalizeName(displayName) or accountName

	return {
		Id = Utils.GenerateGUID(),
		Name = accountName,
		DisplayName = accountDisplayName,
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
	if #self.Accounts == 0 then
		table.insert(
			self.Accounts,
			newAccount(self.Player.Name, self.Player.DisplayName)
		)
	end

	self.CurrentIndex = 1
	return self
end

function AccountManager:Destroy()
	table.clear(self.Accounts)
	self.CurrentIndex = 1
	self.Player = nil
end

function AccountManager:CreateAccount(name)
	if #self.Accounts >= Config.MaxAccounts then
		warn("Max accounts reached (" .. Config.MaxAccounts .. ")")
		return nil
	end

	local accountName = normalizeName(name)
	if not accountName then
		accountName = "Alt" .. (#self.Accounts + 1)
	end

	local account = newAccount(accountName, accountName)
	table.insert(self.Accounts, account)
	self.CurrentIndex = #self.Accounts

	return account
end

function AccountManager:RemoveAccount(index)
	if #self.Accounts <= 1 then
		warn("Can't remove the last account")
		return false
	end

	if type(index) ~= "number"
		or index ~= math.floor(index)
		or index < 1
		or index > #self.Accounts
	then
		return false
	end

	table.remove(self.Accounts, index)

	if self.CurrentIndex > index then
		self.CurrentIndex -= 1
	end

	self.CurrentIndex = Utils.Clamp(self.CurrentIndex, 1, #self.Accounts)
	return true
end

function AccountManager:SwitchAccount(index)
	if type(index) ~= "number"
		or index ~= math.floor(index)
		or index < 1
		or index > #self.Accounts
	then
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
	return Utils.DeepCopy(self.Accounts)
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
		Id = account.Id,
		Name = account.Name,
		DisplayName = account.DisplayName,
		Level = account.Level,
		Points = account.Points,
		LastLogin = Utils.FormatTimeAgo(account.LastLogin),
		Inventory = Utils.DeepCopy(account.Inventory),
		Settings = Utils.DeepCopy(account.Settings),
	}
end

-- ========================================
-- CLIENT-SIDE STARTUP
-- ========================================

local managers = {}

local function onPlayerAdded(player)
	if managers[player] then
		return
	end

	local manager = AccountManager.new(player)
	manager:Initialize()
	managers[player] = manager
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

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Keep these available to other code in this same script environment.
return {
	Config = Config,
	Utils = Utils,
	AccountManager = AccountManager,
	Managers = managers,
}
