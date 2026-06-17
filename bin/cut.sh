-- cut: extract sections from each line of a file.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" or args[1] == "--help" then
	print("Usage:")
	print("  cut -c <ranges> <file>           cut by character positions")
	print("  cut -d <delim> -f <ranges> <file> cut by delimited field")
	print("Ranges are comma-separated and may be of the form N, N-M or -M, N-.")
	return 0
end

local mode, charSpec, fieldSpec, delim, fileArg
local cursor = 1
while cursor <= #args do
	local token = args[cursor]
	if token == "-c" then mode = "char" charSpec  = args[cursor + 1] cursor = cursor + 2
	elseif token == "-f" then mode = "field" fieldSpec = args[cursor + 1] cursor = cursor + 2
	elseif token == "-d" then delim = args[cursor + 1] cursor = cursor + 2
	else fileArg = token cursor = cursor + 1 end
end
if mode == nil or fileArg == nil then
	print("cut: missing -c/-f or file argument")
	return false
end
if mode == "field" and (delim == nil or delim == "") then delim = "\t" end

local function parseRanges(spec, maxValue)
	local ranges = {}
	for piece in spec:gmatch("[^,]+") do
		local from, to = piece:match("^(%d*)%-(%d*)$")
		if from ~= nil then
			from = tonumber(from)
			to   = tonumber(to)
			if from == nil then from = 1 end
			if to == nil then to = maxValue end
			ranges[#ranges + 1] = { from = from, to = to }
		else
			local single = tonumber(piece)
			if single ~= nil then
				ranges[#ranges + 1] = { from = single, to = single }
			end
		end
	end
	return ranges
end

local target = shell.resolve(fileArg)
if fs.exists(target) == false or fs.isDir(target) then
	print("cut: not a file: " .. target)
	return false
end

local handle = fs.open(target, "r")
local spec = mode == "char" and charSpec or fieldSpec
local line = handle.readLine()
while line ~= nil do
	if mode == "char" then
		local ranges = parseRanges(spec, #line)
		local pieces = {}
		for _, range in ipairs(ranges) do
			pieces[#pieces + 1] = line:sub(range.from, range.to)
		end
		print(table.concat(pieces))
	else
		-- field mode
		local fields = {}
		local index = 1
		for piece in line:gmatch("([^" .. delim:sub(1, 1) .. "]+)") do
			fields[index] = piece
			index = index + 1
		end
		local ranges = parseRanges(spec, #fields)
		local pieces = {}
		for _, range in ipairs(ranges) do
			for fieldIndex = range.from, math.min(range.to, #fields) do
				pieces[#pieces + 1] = fields[fieldIndex]
			end
		end
		print(table.concat(pieces, delim:sub(1, 1)))
	end
	line = handle.readLine()
end
handle.close()
