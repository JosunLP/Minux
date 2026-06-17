-- du: report disk usage of files and directories.
local args = { ... }
if args[1] == "?" or args[1] == "help" or args[1] == "--help" then
	print("Usage: du [-s] [-h] [path]")
	print("  -s  summary only (no per-subdirectory output)")
	print("  -h  human-readable sizes (KB / MB)")
	return 0
end

local summary, human = false, false
local cursor = 1
while args[cursor] == "-s" or args[cursor] == "-h" do
	if args[cursor] == "-s" then summary = true end
	if args[cursor] == "-h" then human   = true end
	cursor = cursor + 1
end

local root = args[cursor] or "."
root = shell.resolve(root)
if fs.exists(root) == false then
	print("du: no such path: " .. root)
	return false
end

local function formatSize(bytes)
	if human == false then return tostring(bytes) end
	if bytes >= 1024 * 1024 then return string.format("%.1fM", bytes / 1024 / 1024) end
	if bytes >= 1024 then return string.format("%.1fK", bytes / 1024) end
	return tostring(bytes) .. "B"
end

local function walk(path)
	if fs.isDir(path) == false then
		return fs.getSize(path) or 0
	end
	local total = 0
	for _, name in ipairs(fs.list(path)) do
		local child = fs.combine(path, name)
		local size = walk(child)
		total = total + size
		if summary == false and fs.isDir(child) then
			print(string.format("%-10s %s", formatSize(size), child))
		end
	end
	return total
end

local total = walk(root)
print(string.format("%-10s %s", formatSize(total), root))
