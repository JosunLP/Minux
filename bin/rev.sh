-- rev: reverse the characters of every line in a file (or input lines).
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: rev <file>")
	print("Print each line of <file> with its characters reversed.")
	return 0
end

local target = shell.resolve(args[1])
if fs.exists(target) == false or fs.isDir(target) then
	print("rev: not a file: " .. target)
	return false
end

local handle = fs.open(target, "r")
local line = handle.readLine()
while line ~= nil do
	print(string.reverse(line))
	line = handle.readLine()
end
handle.close()
