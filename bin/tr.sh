-- tr: translate or delete characters from each line of a file.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: tr [-d] <set1> [set2] <file>")
	print("Replaces each char in <set1> with the matching char in <set2>.")
	print("With -d, deletes every char in <set1> instead.")
	return 0
end

local deleteMode = false
local cursor = 1
if args[1] == "-d" then deleteMode = true cursor = 2 end

local set1 = args[cursor]
local set2, fileArg
if deleteMode then
	fileArg = args[cursor + 1]
else
	set2 = args[cursor + 1]
	fileArg = args[cursor + 2]
end
if set1 == nil or fileArg == nil or (deleteMode == false and set2 == nil) then
	print("tr: missing arguments")
	return false
end

local target = shell.resolve(fileArg)
if fs.exists(target) == false or fs.isDir(target) then
	print("tr: not a file: " .. target)
	return false
end

local mapping = {}
if deleteMode == false then
	for index = 1, #set1 do
		mapping[set1:sub(index, index)] =
			set2:sub(math.min(index, #set2), math.min(index, #set2))
	end
end

local handle = fs.open(target, "r")
local line = handle.readLine()
while line ~= nil do
	local result = {}
	for index = 1, #line do
		local char = line:sub(index, index)
		if deleteMode then
			if set1:find(char, 1, true) == nil then
				result[#result + 1] = char
			end
		else
			result[#result + 1] = mapping[char] or char
		end
	end
	print(table.concat(result))
	line = handle.readLine()
end
handle.close()
