-- less: scrollable file viewer.
local args     = { ... }
local filename = args[1]

if filename == "?" or filename == "help" or filename == "-h" or filename == "--help" then
print("less, /bin/less.sh")
print("Scrollable text-file viewer")
print("Usage: less <filename>")
print("Keys: Up/W, Down/S to scroll; LeftCtrl to exit")
return 0
end

if filename == nil or filename == "" then
print("Invalid filename")
print("Use 'man less' for the manual")
return false
end

local resolved = shell.resolve(filename)
if fs.exists(resolved) == false then
print("File not found: " .. resolved)
return false
end

local termX, termY = term.getSize()
local lines = {}

-- Read all lines into memory.
local file = fs.open(resolved, "r")
local line = file.readLine()
while line ~= nil do
table.insert(lines, line)
print(line)
line = file.readLine()
end
file.close()

-- Status line.
table.insert(lines, "viewing: '" .. resolved .. "'")
print(lines[#lines])

-- Enable scrolling when content exceeds the viewport.
if #lines > termY then
table.insert(lines, "Scroll with Up/Down or W/S; press LeftCtrl to exit")
write(lines[#lines])
local buffer = #lines - termY

local function scroll(direction)
if (buffer == 0 and direction == -1) or
   (buffer == #lines - termY and direction == 1) then
return
end
term.scroll(direction)
if direction == 1 then
buffer = buffer + 1
term.setCursorPos(1, termY)
write(lines[#lines - (#lines - termY - buffer + 1)])
else
buffer = buffer - 1
term.setCursorPos(1, 1)
write(lines[buffer + 1])
end
end

local event, value
repeat
event, value = os.pullEvent()
if event == "mouse_scroll" then
scroll(value)
elseif event == "key" then
if value == keys.up or value == keys.w then
scroll(-1)
elseif value == keys.down or value == keys.s then
scroll(1)
end
end
until event == "key" and value == keys.leftCtrl

-- Return to bottom when exiting.
while buffer < #lines - termY do
scroll(1)
end
write("\n")
end
