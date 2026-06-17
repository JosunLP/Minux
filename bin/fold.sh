-- fold: wrap each input line at the requested column (default 80).
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: fold [-w <width>] <file>")
	print("Wrap each input line so it never exceeds <width> columns.")
	return 0
end

local width = 80
local cursor = 1
if args[1] == "-w" then
	width = tonumber(args[2]) or width
	cursor = 3
end

local target = shell.resolve(args[cursor] or "")
if fs.exists(target) == false or fs.isDir(target) then
	print("fold: not a file: " .. tostring(target))
	return false
end
if width < 1 then
	print("fold: width must be >= 1")
	return false
end

local handle = fs.open(target, "r")
local line = handle.readLine()
while line ~= nil do
	if #line == 0 then
		print("")
	else
		local index = 1
		while index <= #line do
			print(line:sub(index, index + width - 1))
			index = index + width
		end
	end
	line = handle.readLine()
end
handle.close()
