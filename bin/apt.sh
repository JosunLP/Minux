-- apt controller script

local args = { ... }
local command = args[1]
local packageName = args[2]

local commandAliases = {
  install          = "-i",
  remove           = "-r",
  update           = "-u",
  ["update-forced"] = "-U",
  setsource        = "-s",
  clearsource      = "-c",
  setupdate        = "-a",
  ["list-installed"]  = "-l",
  ["list-available"]  = "-la",
  ["list-source"]     = "-ls",
  version          = "-v",
  status           = "-v",
  help             = "help",
  ["-h"]           = "help",
  ["--help"]       = "help",
  ["?"]            = "help",
}

if commandAliases[command] ~= nil then
  command = commandAliases[command]
end

local function withColor(color, fn)
  if term.isColor() then term.setTextColor(color) end
  fn()
  if term.isColor() then term.setTextColor(colors.white) end
end

local function err(message)
  withColor(colors.red, function() print("apt: " .. message) end)
end

local function ok(message)
  withColor(colors.lime, function() print(message) end)
end

-- Print "  label ........ " and return the current column so the caller can
-- append the status ([done] / [fail]) on the same line.
local function progressWrite(label)
  local w = term.getSize()
  local prefix = "  " .. label
  local dotsLen = math.max(1, w - #prefix - 8)
  write(prefix .. " " .. string.rep(".", dotsLen) .. " ")
end

local function printDone()
  withColor(colors.lime, function() print("[done]") end)
end

local function printFail()
  withColor(colors.red, function() print("[fail]") end)
end

local function printHelp()
  local w = term.getSize()
  local function section(title)
    withColor(colors.cyan, function() print(title) end)
  end
  local function item(cmd, desc)
    withColor(colors.white, function() write(string.format("  %-26s", cmd)) end)
    withColor(colors.gray, function() print(desc) end)
  end

  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
  withColor(colors.white, function() print("  apt  -  ReMinux package manager") end)
  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
  print("  Usage: apt <command> [package]")
  print("")
  section("  Package commands:")
  item("-i, install <pkg>",       "install a package")
  item("-r, remove <pkg>",        "remove a package")
  item("-u, update [pkg]",        "update one or all packages")
  item("-U, update-forced",       "force-update everything")
  item("-v, version <pkg>",       "show version info")
  print("")
  section("  Sources & lists:")
  item("-s, setsource <url>",     "add an APT source")
  item("-c, clearsource <url>",   "remove an APT source")
  item("-ls, list-source",        "show active sources")
  item("-la, list-available",     "list all available packages")
  item("-l, list-installed",      "list installed packages")
  item("-a, setupdate <mode>",    "configure auto-update")
  print("")
  withColor(colors.gray, function() print("  See 'man apt' for details.") end)
  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
end

local function requireAdmin(commandLabel)
  if _G.admin == true then return true end
  err("'" .. commandLabel .. "' requires admin privileges")
  withColor(colors.gray, function() print("Hint: log in as admin with 'login'.") end)
  return false
end

local function requirePackage(commandLabel)
  if packageName ~= nil and packageName ~= "" then return true end
  err("'" .. commandLabel .. "' needs a package name")
  print("Usage: apt " .. commandLabel .. " <package>")
  return false
end

local function printResult(success, successMessage, failureMessage)
  if success == true then
    ok(successMessage)
    return true
  end
  err(failureMessage)
  return false
end

local function runInstall(targetPackage)
  if apt.checkinstall(targetPackage) == true then
    withColor(colors.gray, function() print("Already installed: " .. targetPackage) end)
    return true
  end

  progressWrite("Installing " .. targetPackage)
  local result = apt.install(targetPackage)
  if result == true then
    printDone()
    ok("Package installed: " .. targetPackage)
    return true
  end

  printFail()
  err("install failed for '" .. targetPackage .. "' (E:" .. tostring(result) .. ")")
  return false
end

local function runUninstall(targetPackage)
  if apt.checkinstall(targetPackage) ~= true then
    err("not installed: " .. targetPackage)
    return false
  end

  progressWrite("Removing " .. targetPackage)
  local result, errorCode = apt.uninstall(targetPackage)
  if result == true then
    printDone()
    ok("Package removed: " .. targetPackage)
    return true
  end

  printFail()
  if errorCode ~= nil then
    err("removal failed for '" .. targetPackage .. "' (E:" .. tostring(errorCode) .. ")")
  else
    err("removal failed for '" .. targetPackage .. "'")
  end
  return false
end

local function runUpdate(targetPackage)
  local label = targetPackage and ("Updating " .. targetPackage) or "Updating all packages"
  progressWrite(label)
  local result = apt.update(targetPackage)
  if result == true then
    printDone()
    ok("Update complete")
    return true
  end

  printFail()
  err("update failed (E:" .. tostring(result) .. ")")
  return false
end

local function describeLookupError(errorCode)
  if errorCode == 102 then return "no package sources configured"
  elseif errorCode == 105 then return "package not found"
  elseif errorCode == 111 then return "source unavailable"
  end
  return tostring(errorCode)
end

local function runVersion(targetPackage)
  local info = apt.packageinfo(targetPackage)
  if type(info) ~= "table" then
    err("version lookup failed for '" .. tostring(targetPackage) .. "'")
    return false
  end

  local w = term.getSize()
  withColor(colors.cyan, function()
    print(string.rep("-", math.min(w, 40)))
  end)
  withColor(colors.white, function() print("  Package: " .. tostring(info.package)) end)
  withColor(colors.gray, function()
    print("  Installed:         " .. tostring(info.installed))
    print("  Installed version: " .. tostring(info.installedVersion or "unknown"))
    print("  Available version: " .. tostring(info.availableVersion or "unknown"))
  end)
  if info.releaseTracking == true then
    local tag
    if info.releaseStatus == "ok"    then tag = tostring(info.releaseTag)
    elseif info.releaseStatus == "none"  then tag = "none"
    elseif info.releaseStatus == "error" then tag = "unavailable"
    else                                      tag = "unknown"
    end
    withColor(colors.gray, function() print("  Latest release:    " .. tag) end)
  end
  if info.source ~= nil then
    withColor(colors.gray, function() print("  Source: " .. info.source) end)
  end
  withColor(colors.cyan, function()
    print(string.rep("-", math.min(w, 40)))
  end)
  if info.error ~= nil then
    err("lookup error: " .. describeLookupError(info.error))
    return false
  end
  return true
end

-- Dispatch
local success = false

if command == "help" then
  printHelp()
  return true

elseif command == nil then
  if apt.checkinstall("menu") == true then
    shell.run("/etc/minux-main/menu/soft.sys")
    return true
  end
  err("missing command")
  printHelp()
  return false

elseif command == "-i" then
  if requirePackage("-i") ~= true then return false end
  if packageName ~= "auth-client" and requireAdmin("-i") ~= true then return false end
  success = runInstall(packageName)

elseif command == "-r" then
  if requirePackage("-r") ~= true then return false end
  if requireAdmin("-r") ~= true then return false end
  success = runUninstall(packageName)

elseif command == "-u" then
  success = runUpdate(packageName)

elseif command == "-U" then
  if requireAdmin("-U") ~= true then return false end
  success = runUpdate("-f")

elseif command == "-s" then
  if requirePackage("-s") ~= true then return false end
  if requireAdmin("-s") ~= true then return false end
  success = printResult(apt.addsource(packageName), "Source added", "source not added")

elseif command == "-c" then
  if requirePackage("-c") ~= true then return false end
  if requireAdmin("-c") ~= true then return false end
  success = printResult(apt.clearsource(packageName), "Source removed", "source not removed")

elseif command == "-a" then
  if requirePackage("-a") ~= true then return false end
  if requireAdmin("-a") ~= true then return false end
  local ok = minux.setconfig("update", packageName)
  if ok ~= true then
    err("failed to apply auto-update setting '" .. packageName .. "'")
    return false
  end
  success = true

elseif command == "-ls" then
  shell.run("/bin/less.sh /usr/apt/source.ls")
  return true

elseif command == "-la" then
  if packageName == "--update" or not fs.exists("/temp/apt/programs.ls") then
    progressWrite("Fetching package list")
    local result = apt.softlist()
    if result ~= true and not fs.exists("/temp/apt/programs.ls") then
      printFail()
      err("list failed (E:" .. tostring(result) .. ")")
      return false
    end
    printDone()
  end
  shell.run("/bin/less.sh /temp/apt/programs.ls")
  return true

elseif command == "-l" then
  shell.run("/bin/less.sh /etc/apt/list/installed.db")
  return true

elseif command == "-v" then
  if requirePackage("-v") ~= true then return false end
  success = runVersion(packageName)

else
  err("unknown command '" .. tostring(command) .. "'")
  withColor(colors.gray, function() print("Try 'apt help' or 'man apt'.") end)
  return false
end

return success
