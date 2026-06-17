-- ping: broadcast a rednet ping and report every responding computer.
local args = { ... }
if args[1] == "?" or args[1] == "help" then
	print("Usage: ping [timeout-seconds]")
	print("Broadcasts a 'reminux-ping' rednet packet and lists responders.")
	print("Timeout defaults to 2 seconds.")
	return 0
end

if rednet == nil then
	print("ping: rednet API not available")
	return false
end

local timeout = tonumber(args[1]) or 2

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
		print("ping: no modem attached")
		return false
	end
end

print("Pinging rednet, timeout " .. timeout .. "s ...")
local start = os.clock()
rednet.broadcast("reminux-ping", "reminux-ping")

local responders = {}
local deadline = os.clock() + timeout
while os.clock() < deadline do
	local remaining = deadline - os.clock()
	if remaining <= 0 then break end
	local id, message, protocol = rednet.receive("reminux-pong", remaining)
	if id ~= nil then
		responders[#responders + 1] = {
			id = id, message = message, rtt = os.clock() - start,
		}
	end
end

if #responders == 0 then
	print("No responses.")
else
	print(string.format("%-6s %-7s %s", "id", "rtt(s)", "message"))
	for _, entry in ipairs(responders) do
		print(string.format("%-6d %-7.2f %s",
			entry.id, entry.rtt, tostring(entry.message)))
	end
end

if opened ~= nil then rednet.close(opened) end
