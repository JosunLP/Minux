local args = { ... }

local function printUsage()
	print("Usage: ls [-a] [-l] [-R] [-d] [path...]")
	print("  -a  include entries beginning with '.'")
	print("  -l  long format with mode and size")
	print("  -R  recurse into subdirectories")
	print("  -d  list a directory itself, not its contents")
end

local includeHidden = false
local longFormat = false
local recursive = false
local listDirectoryItself = false
local targets = {}

for _, arg in ipairs(args) do
	if arg == "-a" then
		includeHidden = true
	elseif arg == "-l" then
		longFormat = true
	elseif arg == "-R" or arg == "-r" then
		recursive = true
	elseif arg == "-d" then
		listDirectoryItself = true
	elseif arg == "?" or arg == "help" then
		printUsage()
		return 0
	else
		table.insert(targets, arg)
	end
end

if #targets == 0 then
	targets[1] = "."
end

local function formatSize(size)
	if size == nil then
		return "-"
	end
	return tostring(size)
end

local function emitEntry(entry, displayName)
	if longFormat == true then
		if term.isColor() then
			term.setTextColor(entry.isDir and colors.lightBlue or colors.white)
		end
		minux.writeOutputLine(string.format("%-10s %-8s %-8s %8s %s",
			entry.mode or "----------",
			entry.owner or "-",
			entry.group or "-",
			formatSize(entry.size),
			displayName))
		if term.isColor() then term.setTextColor(colors.white) end
	else
		if term.isColor() then
			term.setTextColor(entry.isDir and colors.lightBlue or colors.white)
		end
		minux.writeOutputLine(displayName)
		if term.isColor() then term.setTextColor(colors.white) end
	end
end

local function listDirectory(path, showHeader)
	local entries = minux.listEntries(path, {
		includeHidden = includeHidden,
	})
	if entries == false then
		print("ls: cannot access " .. path)
		return false
	end
	if showHeader == true then
		minux.writeOutputLine(path .. ":")
	end
	for _, entry in ipairs(entries) do
		emitEntry(entry, entry.name)
	end
	if recursive == true then
		for _, entry in ipairs(entries) do
			if entry.isDir == true then
				minux.writeOutputLine("")
				listDirectory(entry.path, true)
			end
		end
	end
	return true
end

local ok = true
local multipleTargets = #targets > 1
for index, target in ipairs(targets) do
	local resolved = shell.resolve(target)
	local info = minux.pathInfo(resolved)
	if info == nil then
		print("ls: cannot access " .. resolved)
		ok = false
	else
		if multipleTargets == true and index > 1 then
			minux.writeOutputLine("")
		end
		if info.isDir == true and listDirectoryItself ~= true then
			listDirectory(resolved, multipleTargets == true or recursive == true)
		else
			if multipleTargets == true then
				minux.writeOutputLine(resolved .. ":")
			end
			emitEntry(info, fs.getName(resolved) ~= "" and fs.getName(resolved) or resolved)
		end
	end
end

return ok
