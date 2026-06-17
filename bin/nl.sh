-- nl: number the lines of a file.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: nl [-ba] <file>")
	print("  (default) number only non-empty lines")
	print("  -ba       number all lines, including empty ones")
	return 0
end

local numberAll = false
local cursor = 1
if args[1] == "-ba" then numberAll = true cursor = 2 end

local target = shell.resolve(args[cursor] or "")
if fs.exists(target) == false or fs.isDir(target) then
	print("nl: not a file: " .. tostring(target))
	return false
end

local handle = fs.open(target, "r")
local lineNumber = 0
local line = handle.readLine()
while line ~= nil do
	if numberAll or line:match("%S") then
		lineNumber = lineNumber + 1
		print(string.format("%6d  %s", lineNumber, line))
	else
		print("        " .. line)
	end
	line = handle.readLine()
end
handle.close()
