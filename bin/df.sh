-- df: report filesystem disk usage.
local args = { ... }

if args[1] == "?" or args[1] == "help" or args[1] == "-h" or args[1] == "--help" then
	print("Usage: df [path]")
	print("Reports total, used, and free space for the filesystem")
	print("containing <path> (or '/').")
	return 0
end

local path = args[1] or "/"
path = shell.resolve(path)

if fs.exists(path) == false then
	print("df: " .. path .. ": no such file or directory")
	return false
end

local function fmt(bytes)
	if bytes == nil then return "?" end
	if bytes >= 1024 * 1024 then
		return string.format("%.1f MB", bytes / 1024 / 1024)
	elseif bytes >= 1024 then
		return string.format("%.1f KB", bytes / 1024)
	end
	return tostring(bytes) .. " B"
end

local free  = fs.getFreeSpace(path)
-- ComputerCraft does not expose total capacity directly for the root
-- mount before the recent API additions; fall back to free + used.
local total = nil
if fs.getCapacity ~= nil then
	total = fs.getCapacity(path)
end

local used
if total ~= nil and free ~= nil then
	used = total - free
else
	used = nil
end

print(string.format("Filesystem: %s", path))
print(string.format("  Total : %s", fmt(total)))
print(string.format("  Used  : %s", fmt(used)))
print(string.format("  Free  : %s", fmt(free)))
if total ~= nil and total > 0 and used ~= nil then
	print(string.format("  Use%%  : %.1f%%", (used / total) * 100))
end
