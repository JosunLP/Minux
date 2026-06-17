local args = { ... }

if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: grep [-F] [-i] [-n] [-v] [-r] <pattern> [file...]")
	print("  -F  fixed-string match")
	print("  -i  case-insensitive match")
	print("  -n  show line numbers")
	print("  -v  invert: show non-matching lines")
	print("  -r  recurse into directories")
	print("Use '-' or shell I/O context input for stdin.")
	return 0
end

local fixedString     = false
local caseInsensitive = false
local showLineNumbers = false
local invertMatch     = false
local recursive       = false
local cursor = 1
while args[cursor] == "-F" or args[cursor] == "-i" or args[cursor] == "-n" or args[cursor] == "-v" or args[cursor] == "-r" or args[cursor] == "-R" do
	if args[cursor] == "-F" then fixedString = true
	elseif args[cursor] == "-i" then caseInsensitive = true
	elseif args[cursor] == "-n" then showLineNumbers = true
	elseif args[cursor] == "-v" then invertMatch = true
	elseif args[cursor] == "-r" or args[cursor] == "-R" then recursive = true
	end
	cursor = cursor + 1
end

local pattern = args[cursor]
if pattern == nil then
	print("grep: no pattern given")
	return false
end
if caseInsensitive == true then pattern = string.lower(pattern) end
if fixedString ~= true then
	local ok = pcall(string.find, "", pattern)
	if ok ~= true then
		print("grep: invalid Lua pattern")
		return false
	end
end

local files = {}
for i = cursor + 1, #args do files[#files + 1] = args[i] end

local function readLinesFromFile(path)
	local handle = fs.open(path, "r")
	if handle == nil then
		return nil
	end
	local lines = {}
	local line = handle.readLine()
	while line ~= nil do
		lines[#lines + 1] = line
		line = handle.readLine()
	end
	handle.close()
	return lines
end

local stdinLines = minux.readInputLines()
local sources = {}

local function addSource(kind, value, label)
	sources[#sources + 1] = {
		kind = kind,
		value = value,
		label = label,
	}
end

local function addFileSource(filepath)
	local target = shell.resolve(filepath)
	if fs.exists(target) == false then
		print("grep: no such file: " .. target)
		return
	end
	if fs.isDir(target) == true then
		if recursive ~= true then
			print("grep: " .. target .. ": is a directory")
			return
		end
		local entries = minux.findEntries(target, {
			recursive = true,
			includeHidden = true,
			type = "file",
		})
		for _, entry in ipairs(entries or {}) do
			addSource("file", entry.path, entry.path)
		end
		return
	end
	addSource("file", target, target)
end

if #files == 0 then
	if type(stdinLines) ~= "table" then
		print("grep: no input files")
		return false
	end
	addSource("stdin", stdinLines, "(standard input)")
else
	for _, file in ipairs(files) do
		if file == "-" then
			if type(stdinLines) == "table" then
				addSource("stdin", stdinLines, "(standard input)")
			else
				print("grep: stdin is not available")
			end
		else
			addFileSource(file)
		end
	end
end

local showFilename = #sources > 1

local function searchLines(lines, label)
	local lineNumber = 0
	for _, line in ipairs(lines) do
		lineNumber = lineNumber + 1
		local subject = caseInsensitive and string.lower(line) or line
		local matched
		if fixedString == true then
			matched = string.find(subject, pattern, 1, true) ~= nil
		else
			matched = string.find(subject, pattern) ~= nil
		end
		if invertMatch then matched = not matched end
		if matched then
			local prefix = ""
			if showFilename then prefix = label .. ":" end
			if showLineNumbers then prefix = prefix .. lineNumber .. ":" end
			minux.writeOutputLine(prefix .. line)
		end
	end
end

for _, source in ipairs(sources) do
	if source.kind == "file" then
		local lines = readLinesFromFile(source.value)
		if lines ~= nil then
			searchLines(lines, source.label)
		end
	else
		searchLines(source.value, source.label)
	end
end
