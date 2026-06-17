-- date: print the current in-game date and time.
local args = { ... }
local format = args[1]

if format == "?" or format == "help" or format == "-h" or format == "--help" then
	print("Usage: date [format]")
	print("  format  Lua os.date format string (defaults to '%c')")
	print("Without arguments, prints in-game day and time-of-day.")
	return 0
end

if format ~= nil and format ~= "" then
	print(os.date(format))
else
	-- ComputerCraft tracks an in-game day counter and a time-of-day in
	-- hours.  Display both alongside the regular system date.
	local day  = os.day()
	local hour = os.time()
	local intHour = math.floor(hour)
	local minute  = math.floor((hour - intHour) * 60)
	print(string.format("Day %d %02d:%02d  (%s)",
		day, intHour, minute, os.date("%c")))
end
