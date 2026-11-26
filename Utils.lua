-- Utils.lua (ModuleScript)
-- General helpers. Call with a DOT, e.g. Utils.Round(3.14159, 2)

local HttpService = game:GetService("HttpService")

local Utils = {}

local CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
local rng = Random.new()

-- ========== STRINGS ==========

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

-- ========== MATH ==========

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

-- ========== TABLES ==========

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

-- ========== TIME ==========

function Utils.Wait(duration)
	return task.wait(duration)
end

function Utils.WaitRandom(min, max)
	return task.wait(rng:NextNumber(min, max))
end

function Utils.IsInRange(value, min, max)
	return value >= min and value <= max
end

return Utils
