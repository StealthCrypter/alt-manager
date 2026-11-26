-- main.lua
-- Server-only, in-memory account manager.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

assert(RunService:IsServer(), "main.lua must run in a server Script.")

local Config = {
	MaxAccounts = 5,
	MaxNameLength = 30,
}

local Utils = {}
local rng = Random.new()

local function normalizeName(name)
	if type(name) ~= "string" then
		return nil
	end

	name = name:match("^%s*(.-)%s*$")
	if name == "" then
		return nil
	end

	return string.sub(name, 1, Config.MaxNameLength)
end

function Utils.Clamp(value, min, max)
	return math.min(math.max(value, min), max)
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

local function newAccount(name, displayName)
	local now = os.time()

	return {
		Id = HttpService:GenerateGUID(false),
		Name = normalizeName(name) or "Account",
		DisplayName = normalizeName(displayName) or "Account",
		Level = 1,
		Points = 0,
		LastLogin = now,
		Inventory = {},
		Settings = {
			GUIEnabled = true,
			NotificationsEnabled = true,
			AutoJoin = false,
		},
	}
end

local AccountManager = {}
AccountManager.__index = AccountManager

function AccountManager.new(player)
	assert(typeof(player) == "Instance" and player:IsA("Player"))

	local self = setmetatable({}, AccountManager)
	self.Player = player
	self.Accounts = {}
	self.CurrentIndex = 1

	return self
end

function AccountManager:Initialize()
	if #self.Accounts > 0 then
		return self
	end

	table.insert(
		self.Accounts,
		newAccount(self.Player.Name, self.Player.DisplayName)
	)
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

	self.CurrentIndex = Utils.Clamp(
		self.CurrentIndex,
		1,
		#self.Accounts
	)

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
	local copy = table.create(#self.Accounts)

	for index, account in ipairs(self.Accounts) do
		copy[index] = {
			Id = account.Id,
			Name = account.Name,
			DisplayName = account.DisplayName,
			Level = account.Level,
			Points = account.Points,
			LastLogin = Utils.FormatTimeAgo(account.LastLogin),
			Inventory = table.clone(account.Inventory),
			Settings = table.clone(account.Settings),
		}
	end

	return copy
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
		Inventory = table.clone(account.Inventory),
		Settings = table.clone(account.Settings),
	}
end

local managers = {}

local function onPlayerAdded(player)
	if managers[player] then
		return
	end

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

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
