-- doctor: audit and repair core ReMinux state.
local args = { ... }
local repair = false

local function withColor(color, fn)
  if term.isColor() then term.setTextColor(color) end
  fn()
  if term.isColor() then term.setTextColor(colors.white) end
end

local function isHelpToken(token)
  return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function printUsage()
  withColor(colors.cyan, function() print("doctor  -  system health audit") end)
  print("Usage: doctor [--repair]")
  withColor(colors.gray, function()
    print("  (no args)  scan and report issues")
    print("  --repair   recreate missing core files and directories")
    print("  help       show this message")
  end)
end

if isHelpToken(args[1]) then
  printUsage()
  return true
elseif args[1] == "--repair" or args[1] == "repair" then
  repair = true
elseif args[1] ~= nil then
  withColor(colors.red, function()
    print("doctor: unknown option '" .. tostring(args[1]) .. "'")
  end)
  printUsage()
  return false
end

-- Scanning animation
local w = term.getSize()
withColor(colors.cyan, function() print(string.rep("=", w)) end)
withColor(colors.white, function() print("  ReMinux System Audit" .. (repair and "  [repair mode]" or "")) end)
withColor(colors.cyan, function() print(string.rep("=", w)) end)

do
  local SPIN = { "|", "/", "-", "\\" }
  write("  Scanning")
  local sx, sy = term.getCursorPos()
  withColor(colors.yellow, function()
    for i = 1, 8 do
      term.setCursorPos(sx, sy)
      write(SPIN[((i - 1) % #SPIN) + 1])
      os.sleep(0.06)
    end
  end)
  term.setCursorPos(1, sy)
  term.clearLine()
end

local findings = minux.doctor(repair)
local counts = { ok = 0, warning = 0, error = 0, fixed = 0 }

local SYMBOLS = {
  error   = { sign = " !! ", color = colors.red },
  warning = { sign = " ?? ", color = colors.yellow },
  fixed   = { sign = " ++ ", color = colors.lime },
  ok      = { sign = "    ", color = colors.white },
}

local function printFinding(level, message)
  local s = SYMBOLS[level] or SYMBOLS.ok
  withColor(s.color, function() write(s.sign) end)
  print(message)
end

for _, finding in ipairs(findings) do
  counts[finding.level] = (counts[finding.level] or 0) + 1
  printFinding(finding.level, finding.message)
end

-- Summary
print("")
withColor(colors.cyan, function() print(string.rep("-", math.min(w, 40))) end)
withColor(colors.white, function() print("  Audit summary:") end)

if counts.error > 0 then
  withColor(colors.red, function()
    print(string.format("    Errors:   %d", counts.error))
  end)
else
  withColor(colors.gray, function()
    print(string.format("    Errors:   %d", counts.error))
  end)
end

if counts.warning > 0 then
  withColor(colors.yellow, function()
    print(string.format("    Warnings: %d", counts.warning))
  end)
else
  withColor(colors.gray, function()
    print(string.format("    Warnings: %d", counts.warning))
  end)
end

if counts.fixed > 0 then
  withColor(colors.lime, function()
    print(string.format("    Fixed:    %d", counts.fixed))
  end)
else
  withColor(colors.gray, function()
    print(string.format("    Fixed:    %d", counts.fixed))
  end)
end

withColor(counts.ok > 0 and colors.white or colors.gray, function()
  print(string.format("    OK:       %d", counts.ok))
end)

withColor(colors.cyan, function() print(string.rep("-", math.min(w, 40))) end)

if repair ~= true and counts.error > 0 then
  withColor(colors.yellow, function()
    print("  Run 'doctor --repair' to fix missing files.")
  end)
end
if counts.warning > 0 and minux.getconfig("login") == "local"
    and minux.getconfig("encrypt") ~= true then
  withColor(colors.gray, function()
    print("  Tip: local auth is safer with 'config encrypt enabled'.")
  end)
end

return counts.error == 0
