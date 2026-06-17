local args = { ... }
local needle = args[1]
local startPath = args[2] or "/"

if needle == nil or needle == "" or needle == "?" or needle == "help" then
	print("Usage: search <name-fragment> [start-path]")
	return 0
end

local resolved = shell.resolve(startPath)
if fs.exists(resolved) ~= true then
	print("search: no such path: " .. resolved)
	return false
end

local results = minux.findEntries(resolved, {
	recursive = true,
	includeHidden = true,
	type = "file",
	pathContains = needle,
})

if results == false or #results == 0 then
	print("No results found")
	return 0
end

for _, entry in ipairs(results) do
	minux.writeOutputLine(entry.path)
end
