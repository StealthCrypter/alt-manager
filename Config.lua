-- Config.lua (ModuleScript)
-- Shared settings for AccountManager and StorageService.

return {
	MaxAccounts = 5,          -- max saved accounts per player
	AutoSaveInterval = 60,    -- seconds between autosaves (only saves if something changed)
	DataStoreName = "RobloxAltAccounts",
	MaxRetries = 3,           -- DataStore retry attempts
	RetryDelay = 1,           -- seconds between retries
}
