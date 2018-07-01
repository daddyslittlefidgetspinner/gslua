local to_dump = {{name="client", table=client}, {name="entity", table=entity}, {name="globals", table=globals}, {name="ui", table=ui}}
local table_insert = table.insert
local table_remove = table.remove
local table_concat = table.concat
local string_len = string.len

local function get_n_elements(table, n, start)
	local new_table = {}
	local start = start or 1
	for i=start, n do
		local element = table[i]
		if element ~= nil then
			table_insert(new_table, element)
		end
	end
	return new_table
end

function array_sub(t1, t2)
  local t = {}
  for i = 1, #t1 do
    t[t1[i]] = true
  end
  for i = #t2, 1, -1 do
    if t[t2[i]] then
      table_remove(t2, i)
    end
  end
end

local function log_raw(message)
	client.exec("echo \"", message, "\"")
end

local function dump_api()
	client.log("Copy and paste this into your script:")
	log_raw("--local variables for API. Automatically generated by https://github.com/simpleavaster/gslua/blob/master/authors/sapphyrus/generate_api.lua")
	for i=1, #to_dump do
		local global = to_dump[i]["table"]
		local name = to_dump[i]["name"]
		local part1 = {}
		local part2 = {}
		for i,v in pairs(global) do
			table_insert(part1, name .. "_" .. i)
			table_insert(part2, name .. "." .. i)
		end
		local message = "local " .. table_concat(part1, ", ") .. " = " .. table_concat(part2, ", ")
		local split_at = #part1/2
		if string_len(message) > 512 then
			local part1_1, part2_1 = get_n_elements(part1, split_at), get_n_elements(part2, split_at)
			local part1_2, part2_2 = get_n_elements(part1, #part1, #part1_1), get_n_elements(part2, #part2, #part2_1)
			message1 = "local " .. table_concat(part1_1, ", ") .. " = " .. table_concat(part2_1, ", ")
			message2 = "local " .. table_concat(part1_2, ", ") .. " = " .. table_concat(part2_2, ", ")
			log_raw(message1)
			log_raw(message2)
		else
			log_raw(message)
		end
	end
	log_raw("--end of local variables")
end

ui.new_button("MISC", "Lua", "Generate API local variables", dump_api)