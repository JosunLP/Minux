-- uniq: collapse runs of equal lines (input must already be sorted).
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: uniq [-c] [-d] <file>")
	print("  -c  prefix each line with its occurrence count")
	print("  -d  print only duplicated lines")
	return 0
end

local showCount, onlyDup = false, false
local cursor = 1
while args[cursor] == "-c" or args[cursor] == "-d" do
	if args[cursor] == "-c" then showCount = true end
	if args[cursor] == "-d" then onlyDup   = true end
	cursor = cursor + 1
end

local target = shell.resolve(args[cursor] or "")
if fs.exists(target) == false or fs.isDir(target) then
	print("uniq: not a file: " .. tostring(target))
	return false
end

local handle = fs.open(target, "r")
local previous, count = nil, 0

local function emit()
	if previous == nil then return end
	if onlyDup and count < 2 then return end
	if showCount then
		print(string.format("%4d %s", count, previous))
	else
		print(previous)
	end
end

local line = handle.readLine()
while line ~= nil do
	if line == previous then
		count = count + 1
	else
		emit()
		previous = line
		count = 1
	end
	line = handle.readLine()
end
emit()
handle.close()
