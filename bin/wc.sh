-- wc: count lines, words, and bytes in one or more files.
local args = { ... }

if args[1] == nil or args[1] == "?" or args[1] == "help" or args[1] == "--help" then
	print("Usage: wc [-l|-w|-c] <file> [file...]")
	print("  -l  show line count only")
	print("  -w  show word count only")
	print("  -c  show byte count only")
	return 0
end

local mode = "all"
local startIndex = 1
if args[1] == "-l" then mode, startIndex = "lines", 2
elseif args[1] == "-w" then mode, startIndex = "words", 2
elseif args[1] == "-c" then mode, startIndex = "bytes", 2 end

local function countFile(filepath)
	if fs.exists(filepath) == false or fs.isDir(filepath) then
		return nil, "not a file: " .. filepath
	end
	local handle = fs.open(filepath, "r")
	local lines, words, bytes = 0, 0, 0
	local line = handle.readLine()
	while line ~= nil do
		lines = lines + 1
		bytes = bytes + #line + 1 -- count the implicit newline
		for _ in line:gmatch("%S+") do words = words + 1 end
		line = handle.readLine()
	end
	handle.close()
	return lines, words, bytes
end

local totalLines, totalWords, totalBytes = 0, 0, 0
local fileCount = 0

for index = startIndex, #args do
	local target = shell.resolve(args[index])
	local lines, words, bytes = countFile(target)
	if lines == nil then
		print(words) -- error message stored in 'words'
	else
		fileCount = fileCount + 1
		totalLines = totalLines + lines
		totalWords = totalWords + words
		totalBytes = totalBytes + bytes
		if mode == "lines" then
			print(string.format("%7d %s", lines, target))
		elseif mode == "words" then
			print(string.format("%7d %s", words, target))
		elseif mode == "bytes" then
			print(string.format("%7d %s", bytes, target))
		else
			print(string.format("%7d %7d %7d %s", lines, words, bytes, target))
		end
	end
end

if fileCount > 1 then
	if mode == "lines" then
		print(string.format("%7d total", totalLines))
	elseif mode == "words" then
		print(string.format("%7d total", totalWords))
	elseif mode == "bytes" then
		print(string.format("%7d total", totalBytes))
	else
		print(string.format("%7d %7d %7d total",
			totalLines, totalWords, totalBytes))
	end
end
