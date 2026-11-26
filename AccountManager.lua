-- AccountManager.lua (ModuleScript, SERVER ONLY)
-- Keeps a list of saved "account profiles" for ONE player inside YOUR game's DataStore.
-- NOTE: these are data records only. This cannot log anyone into another Roblox account.
--
-- Usage (in a server Script):
--   local AccountManager = require(path.AccountManager)
--   local manager = AccountManager.new(player)
--   manager:Initialize()
--   ... later, when the player leaves:
--   manager:Destroy()

local HttpService = game:GetService("HttpService")

local Config = require(script.Parent.Config)
local StorageService = require(script.Parent.StorageService)
local Utils = require(script.Parent.Utils)

local AccountManager = {}
AccountManager.__index = AccountManager

-- One shared storage wrapper for all players.
local storage = nil
local function getStorage()
	if not storage then
		storage = StorageService.new()
	end
	return storage
end

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

-- ========== CONSTRUCTOR ==========

function AccountManager.new(player)
	local self = setmetatable({}, AccountManager)
	self.Player = player
	self.Key = "Player_" .. player.UserId
	self.Accounts = {}
	self.CurrentIndex = 1
	self.Dirty = false   -- true when there are unsaved changes
	self.Running = false
	return self
end

-- ========== INIT / SAVE ==========

function AccountManager:Initialize()
	local ok, data = getStorage():Get(self.Key)

	if ok and type(data) == "table" and type(data.Accounts) == "table" and #data.Accounts > 0 then
		self.Accounts = data.Accounts
		self.CurrentIndex = Utils.Clamp(data.CurrentIndex or 1, 1, #self.Accounts)
		print(("Loaded %d account(s) for %s"):format(#self.Accounts, self.Player.Name))
	else
		if not ok then
			-- Don't overwrite real saved data if loading just failed.
			warn("Could not load accounts for " .. self.Player.Name .. ": " .. tostring(data))
			self.LoadFailed = true
		end
		-- Default account is created ONLY when there is nothing saved.
		table.insert(self.Accounts, newAccount(self.Player.Name, self.Player.DisplayName))
		self.CurrentIndex = 1
		self.Dirty = true
	end

	self:StartAutoSave()
	return self
end

function AccountManager:Save()
	if self.LoadFailed then
		return false -- never overwrite data we failed to load
	end
	local ok, err = getStorage():Set(self.Key, {
		Accounts = self.Accounts,
		CurrentIndex = self.CurrentIndex,
	})
	if ok then
		self.Dirty = false
	else
		warn("Error saving accounts: " .. tostring(err))
	end
	return ok
end

function AccountManager:StartAutoSave()
	if self.Running then
		return
	end
	self.Running = true
	task.spawn(function()
		while self.Running do
			task.wait(Config.AutoSaveInterval)
			if self.Running and self.Dirty then
				self:Save()
			end
		end
	end)
end

-- Call when the player leaves.
function AccountManager:Destroy()
	self.Running = false
	if self.Dirty then
		self:Save()
	end
end

-- ========== ACCOUNT OPERATIONS ==========

function AccountManager:CreateAccount(name)
	if #self.Accounts >= Config.MaxAccounts then
		warn("Max accounts reached (" .. Config.MaxAccounts .. ")")
		return nil
	end

	local accountName = name or ("Alt" .. (#self.Accounts + 1))
	local account = newAccount(accountName)
	table.insert(self.Accounts, account)
	self.CurrentIndex = #self.Accounts
	self.Dirty = true
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
	self.Dirty = true
	return true
end

-- Selects a different saved account. Returns the account, or nil if invalid.
function AccountManager:SwitchAccount(index)
	if type(index) ~= "number" or index < 1 or index > #self.Accounts then
		return nil
	end
	self.CurrentIndex = index
	local account = self.Accounts[index]
	account.LastLogin = os.time()
	self.Dirty = true
	return account
end

-- ========== INFO ==========

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

return AccountManager
