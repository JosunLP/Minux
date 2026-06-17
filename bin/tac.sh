-- tac: print the lines of a file in reverse order.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: tac <file>")
	print("Print the file with its lines in reverse order.")
	return 0
end

local target = shell.resolve(args[1])
if fs.exists(target) == false or fs.isDir(target) then
	print("tac: not a file: " .. target)
	return false
end

local lines = {}
local handle = fs.open(target, "r")
local line = handle.readLine()
while line ~= nil do
	lines[#lines + 1] = line
	line = handle.readLine()
end
handle.close()

for index = #lines, 1, -1 do print(lines[index]) end
