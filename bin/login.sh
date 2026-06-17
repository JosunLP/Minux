-- login: authenticate a user against the configured auth backend.
local args = { ... }
local username = args[1]
local password = args[2]

local function withColor(color, fn)
  if term.isColor() then term.setTextColor(color) end
  fn()
  if term.isColor() then term.setTextColor(colors.white) end
end

local function isHelpToken(token)
  return token == "help" or token == "-h" or token == "--help" or token == "?"
end

if username ~= nil and isHelpToken(username) then
  print("Usage: login [username] [password]")
  withColor(colors.gray, function()
    print("  (no args)            prompt for both interactively")
    print("  login <user>         prompt for the password only")
    print("  login <user> <pass>  non-interactive (password visible in history)")
  end)
  print("See 'man login' for AUTH backends and security notes.")
  return true
end

-- Header (only when called interactively with no args)
if username == nil and password == nil then
  local w = term.getSize()
  local loginMode = minux and minux.getconfig and minux.getconfig("login") or "?"
  withColor(colors.cyan, function()
    print(string.rep("-", math.min(w, 40)))
    print("  ReMinux Login  (" .. loginMode .. ")")
    print(string.rep("-", math.min(w, 40)))
  end)
end

if username == nil then
  withColor(colors.white, function() write("  Username: ") end)
  username = read()
end
if password == nil then
  withColor(colors.white, function() write("  Password: ") end)
  password = read("*")
end

if username == nil or username == "" or password == nil or password == "" then
  withColor(colors.red, function()
    print("login: username and password are both required")
  end)
  return false
end

-- Brief spinner while authenticating
do
  local SPIN = { "|", "/", "-", "\\" }
  write("  Authenticating ")
  local cx, cy = term.getCursorPos()
  if term.isColor() then term.setTextColor(colors.yellow) end
  for i = 1, 6 do
    term.setCursorPos(cx, cy)
    write(SPIN[((i - 1) % #SPIN) + 1])
    os.sleep(0.06)
  end
  if term.isColor() then term.setTextColor(colors.white) end
  term.setCursorPos(1, cy)
  term.clearLine()
end

local result, err = minux.login(username, password)
if result == true then
  withColor(colors.lime, function()
    print("  Access granted: " .. username)
  end)
  minux.testcolor()
  return true
end

withColor(colors.red, function()
  if err ~= nil and err ~= "" then
    print("  Access denied: " .. err)
  else
    print("  Access denied for user '" .. username .. "'")
  end
end)
return false
