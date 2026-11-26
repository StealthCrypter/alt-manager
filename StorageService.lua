-- StorageService.lua (ModuleScript, SERVER ONLY)
-- Thin wrapper around Roblox's DataStoreService with retries.
-- Renamed from "DataStoreService" so it no longer hides the real service.

local RealDataStoreService = game:GetService("DataStoreService")
local Config = require(script.Parent.Config)

local StorageService = {}
StorageService.__index = StorageService

-- Create one wrapper around ONE DataStore. Keys are separated inside it.
function StorageService.new(storeName)
	local self = setmetatable({}, StorageService)
	self.Store = RealDataStoreService:GetDataStore(storeName or Config.DataStoreName)
	self.MaxRetries = Config.MaxRetries
	self.RetryDelay = Config.RetryDelay
	return self
end

-- Runs fn with retries. Returns (success, resultOrError).
function StorageService:_retry(fn)
	local lastErr
	for attempt = 1, self.MaxRetries do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastErr = result
		if attempt < self.MaxRetries then
			task.wait(self.RetryDelay)
		end
	end
	return false, lastErr
end

-- Returns (success, value). value is nil if the key has no data yet.
function StorageService:Get(key)
	return self:_retry(function()
		return self.Store:GetAsync(key)
	end)
end

-- Returns (success, errorIfAny).
function StorageService:Set(key, value)
	return self:_retry(function()
		self.Store:SetAsync(key, value)
	end)
end

function StorageService:Delete(key)
	return self:_retry(function()
		self.Store:RemoveAsync(key)
	end)
end

return StorageService
