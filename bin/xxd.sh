-- xxd: hex-dump a file (16 bytes per line, plus the printable form).
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: xxd <file>")
	print("Hex+ASCII dump of <file>. Non-printable bytes appear as '.'.")
	return 0
end

local target = shell.resolve(args[1])
if fs.exists(target) == false or fs.isDir(target) then
	print("xxd: not a file: " .. target)
	return false
end

local handle = fs.open(target, "rb")
local offset = 0
while true do
	local hexParts, asciiParts = {}, {}
	local readCount = 0
	for index = 1, 16 do
		local byte = handle.read()
		if byte == nil then break end
		readCount = readCount + 1
		hexParts[#hexParts + 1] = string.format("%02x", byte)
		if byte >= 32 and byte < 127 then
			asciiParts[#asciiParts + 1] = string.char(byte)
		else
			asciiParts[#asciiParts + 1] = "."
		end
		if index == 8 then hexParts[#hexParts + 1] = " " end
	end
	if readCount == 0 then break end
	-- pad incomplete trailing line so columns line up
	while readCount < 16 do
		hexParts[#hexParts + 1] = "  "
		readCount = readCount + 1
		if readCount == 8 then hexParts[#hexParts + 1] = " " end
	end
	print(string.format("%08x  %s  %s",
		offset, table.concat(hexParts, " "), table.concat(asciiParts)))
	offset = offset + 16
end
handle.close()
