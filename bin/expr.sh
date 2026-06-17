-- expr: evaluate a simple arithmetic expression and print the result.
-- For safety only digits, parentheses and the operators + - * / % ^ // are
-- accepted; anything else is rejected before evaluation.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: expr <expression>")
	print("Operators allowed: + - * / % ^ ()  (// for integer division)")
	return 0
end

local expression = table.concat(args, " ")
if expression:find("[^%d%s%+%-%*%/%%%^%(%)%.]") ~= nil then
	print("expr: invalid characters in expression")
	return false
end

-- Integer division: rewrite "a // b" -> "math.floor((a)/(b))" in either
-- direction so chained expressions like "(1+2)//3" and "10//3" both work.
local function rewriteIdiv(src)
	return src:gsub("(%b())%s*//%s*(%b())", "math.floor(%1/%2)")
		:gsub("(%-?[%d%.]+)%s*//%s*(%b())", "math.floor((%1)/%2)")
		:gsub("(%b())%s*//%s*(%-?[%d%.]+)", "math.floor(%1/(%2))")
		:gsub("(%-?[%d%.]+)%s*//%s*(%-?[%d%.]+)", "math.floor((%1)/(%2))")
end
local lua = rewriteIdiv("(" .. expression .. ")")

local chunk, err = loadstring("return " .. lua)
if chunk == nil then
	print("expr: parse error: " .. tostring(err))
	return false
end
setfenv(chunk, { math = math })
local ok, result = pcall(chunk)
if ok == false then
	print("expr: evaluation error: " .. tostring(result))
	return false
end
print(result)
