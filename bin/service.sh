local args = { ... }
local action = args[1] or "list"
local name = args[2]

local function withColor(color, callback)
if term.isColor() then term.setTextColor(color) end
callback()
if term.isColor() then term.setTextColor(colors.white) end
end

local function isHelpToken(token)
return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function err(message)
withColor(colors.red, function()
print("service: " .. message)
end)
end

local function ok(message)
withColor(colors.lime, function()
print("service: " .. message)
end)
end

local function printUsage()
print("Usage: service [list|status|start|stop|restart|enable|disable] [name]")
print("       service help|-h|--help|?   show this message")
print("Use 'service list' to see available service names.")
end

if isHelpToken(action) then
printUsage()
return 0
end

if action == "list" then
local services = minux.listServices()
print("Name         Trigger  Enabled  State")
for _, service in ipairs(services) do
local state = service.state or "inactive"
local enabled = service.enabled == true and "enabled" or "disabled"
print(string.format("%-12s %-8s %-8s %s", service.name, service.trigger or "manual", enabled, state))
end
return 0
end

if name == nil or name == "" then
err("missing service name for '" .. tostring(action) .. "'")
printUsage()
return false
end

if action == "status" then
local service = minux.getService(name)
if service == nil then
err("unknown service: " .. name)
print("Hint: use 'service list' to see available services.")
return false
end
print("Name    : " .. service.name)
print("Trigger : " .. (service.trigger or "manual"))
print("Enabled : " .. (service.enabled == true and "yes" or "no"))
print("State   : " .. (service.state or "inactive"))
if service.description ~= nil and service.description ~= "" then
print("About   : " .. service.description)
end
if service.detail ~= nil and service.detail ~= "" then
print("Detail  : " .. service.detail)
end
return 0
end

local actions = {
start = minux.startService,
stop = minux.stopService,
restart = minux.restartService,
enable = function(serviceName)
return minux.setServiceEnabled(serviceName, true)
end,
disable = function(serviceName)
return minux.setServiceEnabled(serviceName, false)
end,
}

local handler = actions[action]
if handler == nil then
err("unknown action: " .. action)
printUsage()
return false
end

local succeeded, handlerErr = handler(name)
if succeeded ~= true then
err(handlerErr or "operation failed")
return false
end

ok(action .. " ok: " .. name)
