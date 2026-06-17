-- uptime: print the time the computer has been running since boot.
local args = { ... }
if args[1] == "?" or args[1] == "help" or args[1] == "-h" or args[1] == "--help" then
	print("Usage: uptime")
	print("Print elapsed real-time and in-game time since boot.")
	return 0
end

local clockSeconds = math.floor(os.clock())
local hours   = math.floor(clockSeconds / 3600)
local minutes = math.floor((clockSeconds % 3600) / 60)
local seconds = clockSeconds % 60

local label = os.getComputerLabel() or ("computer-" .. tostring(os.getComputerID()))
print(string.format("up %02d:%02d:%02d  (real-time)  on %s", hours, minutes, seconds, label))
print(string.format("in-game day %d, time %.2f", os.day(), os.time()))
