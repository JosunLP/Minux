-- tree: print a directory tree.
local args = { ... }

if args[1] == "?" or args[1] == "help" then
	print("Usage: tree [path]")
	print("Print the directory hierarchy rooted at <path> (or cwd).")
	return 0
end

local root = args[1]
if root == nil or root == "" then
	root = "/" .. shell.dir()
else
	root = shell.resolve(root)
end

if fs.exists(root) == false then
	print("tree: no such path: " .. root)
	return false
end
if fs.isDir(root) == false then
	print(root)
	return 0
end

local fileCount = 0
local dirCount  = 0

local function colorize(name, isDir)
	if term.isColor() then
		term.setTextColor(isDir and colors.cyan or colors.white)
	end
	write(name)
	if term.isColor() then term.setTextColor(colors.white) end
end

local function walk(path, prefix)
	local entries = fs.list(path)
	-- Stable alphabetical listing.
	table.sort(entries)
	for index, name in ipairs(entries) do
		local full = fs.combine(path, name)
		local last = index == #entries
		local connector = last and "`-- " or "|-- "
		write(prefix .. connector)
		if fs.isDir(full) then
			dirCount = dirCount + 1
			colorize(name .. "/", true)
			print("")
			local nextPrefix = prefix .. (last and "    " or "|   ")
			walk(full, nextPrefix)
		else
			fileCount = fileCount + 1
			colorize(name, false)
			print("")
		end
	end
end

print(root)
walk(root, "")
print("")
print(dirCount .. " directories, " .. fileCount .. " files")
