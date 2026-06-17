-- cat: read and print a text file, with optional paging.
local args     = { ... }
local filename = args[1]
local option   = args[2]

if filename == "?" or filename == "help" or filename == "-h" or filename == "--help" then
print("cat, /bin/cat.sh")
print("Print a text file to the screen")
print("Usage: cat <filename> [p]")
print("  p  - pause every 15 lines")
return 0
end

if filename == nil or filename == "" then
print("Invalid filename")
print("Use 'man cat' for the manual")
return false
end

local resolved = shell.resolve(filename)
if fs.exists(resolved) == false then
print("File not found: " .. resolved)
return false
end

local file = fs.open(resolved, "r")
local lineCount = 0
local line = file.readLine()
while line ~= nil do
print(line)
lineCount = lineCount + 1
if option == "p" and lineCount == 15 then
print("Hit Enter for next page, or 'q' to stop")
local input = read()
if input == "q" or input == "Q" then
file.close()
return 0
end
lineCount = 0
end
line = file.readLine()
end
file.close()
