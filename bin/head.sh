-- head: print the first N lines (default 10) of a file.
local args = { ... }

if args[1] == "?" or args[1] == "help" or args[1] == "--help" then
	print("Usage: head [-n <count>] <file>")
	print("Defaults to 10 lines.")
	return 0
end

if args[1] == nil then
	print("Usage: head [-n <count>] <file>")
	print("Defaults to 10 lines.")
	return false
end

local count = 10
local fileArg = args[1]
if args[1] == "-n" and args[2] ~= nil then
	local parsed = tonumber(args[2])
	if parsed == nil or parsed < 0 then
		print("Invalid line count: " .. tostring(args[2]))
		return false
	end
	count = math.floor(parsed)
	fileArg = args[3]
end

if fileArg == nil then
	print("No file given.")
	return false
end

local target = shell.resolve(fileArg)
if fs.exists(target) == false or fs.isDir(target) then
	print("Not a file: " .. target)
	return false
end

local handle = fs.open(target, "r")
local printed = 0
local line = handle.readLine()
while line ~= nil and printed < count do
	print(line)
	printed = printed + 1
	line = handle.readLine()
end
handle.close()
