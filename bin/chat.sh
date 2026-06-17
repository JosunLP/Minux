-- chat: minimal rednet chat client. Type a line and press Enter to send;
-- type ':quit' to exit. Incoming messages on protocol 'reminux-chat' are
-- printed asynchronously.
local args = { ... }
if args[1] == "?" or args[1] == "help" then
	print("Usage: chat [nick]")
	print("Open a chat session on rednet protocol 'reminux-chat'. If a nick")
	print("is omitted, the computer label (or id) is used. Type ':quit' to")
	print("exit, ':who' to list peers.")
	return 0
end

if rednet == nil then
	print("chat: rednet API not available")
	return false
end

local nick = args[1] or os.getComputerLabel() or ("user-" .. os.getComputerID())

local opened
if rednet.isOpen == nil or rednet.isOpen() == false then
	for _, side in ipairs({ "top", "bottom", "left", "right", "front", "back" }) do
		if peripheral and peripheral.getType(side) == "modem" then
			rednet.open(side)
			opened = side
			break
		end
	end
	if opened == nil then
		print("chat: no modem attached")
		return false
	end
end

if rednet.host ~= nil then rednet.host("reminux-chat", nick) end
print("Connected as '" .. nick .. "'. Type :quit to exit.")
rednet.broadcast({ from = nick, body = "*joined*" }, "reminux-chat")

local function listener()
	while true do
		local id, message = rednet.receive("reminux-chat")
		if type(message) == "table" and message.from ~= nil then
			print("<" .. tostring(message.from) .. "> " .. tostring(message.body or ""))
		end
	end
end

local function input()
	while true do
		write("> ")
		local line = read()
		if line == ":quit" then break end
		if line == ":who" then
			if rednet.lookup ~= nil then
				local peers = { rednet.lookup("reminux-chat") }
				for _, peerId in ipairs(peers) do print("  id " .. peerId) end
			else
				print("  rednet.lookup not supported")
			end
		elseif line ~= "" then
			rednet.broadcast({ from = nick, body = line }, "reminux-chat")
		end
	end
end

parallel.waitForAny(listener, input)

rednet.broadcast({ from = nick, body = "*left*" }, "reminux-chat")
if rednet.unhost ~= nil then rednet.unhost("reminux-chat") end
if opened ~= nil then rednet.close(opened) end
print("Chat closed.")
