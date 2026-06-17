-- sort: read lines of one or more files and print them sorted.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" or args[1] == "--help" then
	print("Usage: sort [-r] [-n] [-u] <file> [file...]")
	print("  -r  reverse order")
	print("  -n  numeric sort")
	print("  -u  unique (drop duplicates)")
	return 0
end

local reverse, numeric, unique = false, false, false
local cursor = 1
while args[cursor] == "-r" or args[cursor] == "-n" or args[cursor] == "-u" do
	if args[cursor] == "-r" then reverse = true
	elseif args[cursor] == "-n" then numeric = true
	elseif args[cursor] == "-u" then unique  = true end
	cursor = cursor + 1
end

local lines = {}
for index = cursor, #args do
	local target = shell.resolve(args[index])
	if fs.exists(target) and fs.isDir(target) == false then
		local handle = fs.open(target, "r")
		local line = handle.readLine()
		while line ~= nil do
			lines[#lines + 1] = line
			line = handle.readLine()
		end
		handle.close()
	else
		print("sort: not a file: " .. target)
	end
end

local function compare(a, b)
	if numeric then
		local na, nb = tonumber(a), tonumber(b)
		if na ~= nil and nb ~= nil then
			if reverse then return na > nb end
			return na < nb
		end
	end
	if reverse then return a > b end
	return a < b
end
table.sort(lines, compare)

if unique then
	local previous, deduped = nil, {}
	for _, line in ipairs(lines) do
		if line ~= previous then deduped[#deduped + 1] = line end
		previous = line
	end
	lines = deduped
end

for _, line in ipairs(lines) do print(line) end
