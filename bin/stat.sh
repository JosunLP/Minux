-- stat: display metadata about a file or directory.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" or args[1] == "-h" or args[1] == "--help" then
	print("Usage: stat <path>")
	print("Print type, owner, group, mode and timestamps.")
	return 0
end

local target = shell.resolve(args[1])
local info = minux.pathInfo(target)
if info == nil then
	print("stat: no such path: " .. target)
	return false
end

local function fmt(bytes)
	if bytes == nil then return "?" end
	if bytes >= 1024 * 1024 then return string.format("%.1f MB", bytes / 1024 / 1024) end
	if bytes >= 1024 then return string.format("%.1f KB", bytes / 1024) end
	return tostring(bytes) .. " B"
end

print("File   : " .. info.path)
print("Type   : " .. (info.isDir and "directory" or "regular file"))
print("Owner  : " .. (info.owner or "-"))
print("Group  : " .. (info.group or "-"))
print("Mode   : " .. (info.mode or "----------") .. " (" .. (info.modeOctalString or "---") .. ")")
if info.isDir == false then
	print("Size   : " .. fmt(info.size))
end
print("ReadOnly: " .. tostring(info.readOnly == true))
if info.created ~= nil then print("Created : " .. info.created) end
if info.modified ~= nil then print("Modified: " .. info.modified) end
if info.drive ~= nil then print("Drive  : " .. tostring(info.drive)) end
return true
