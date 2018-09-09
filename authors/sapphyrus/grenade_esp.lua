--local variables for API. Automatically generated by https://github.com/simpleavaster/gslua/blob/master/authors/sapphyrus/generate_api.lua 
local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position, client_color_log = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position, client.color_log 
local client_draw_circle, client_draw_text, client_visible, client_exec, client_delay_call, client_trace_line, client_world_to_screen, client_draw_hitboxes = client.draw_circle, client.draw_text, client.visible, client.exec, client.delay_call, client.trace_line, client.world_to_screen, client.draw_hitboxes 
local client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float 
local entity_get_local_player, entity_is_enemy, entity_get_player_name, entity_get_all, entity_set_prop, entity_get_player_weapon, entity_hitbox_position, entity_get_prop, entity_get_players, entity_get_classname = entity.get_local_player, entity.is_enemy, entity.get_player_name, entity.get_all, entity.set_prop, entity.get_player_weapon, entity.hitbox_position, entity.get_prop, entity.get_players, entity.get_classname 
local globals_mapname, globals_tickcount, globals_realtime, globals_absoluteframetime, globals_tickinterval, globals_curtime, globals_frametime, globals_maxplayers = globals.mapname, globals.tickcount, globals.realtime, globals.absoluteframetime, globals.tickinterval, globals.curtime, globals.frametime, globals.maxplayers 
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get 
local math_ceil, math_tan, math_correctRadians, math_fact, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan = math.ceil, math.tan, math.correctRadians, math.fact, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan 
local math_fmod, math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.fmod, math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad 
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert 
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub 
--end of local variables 

local grenade_timer_reference = ui.new_checkbox("VISUALS", "Other ESP", "Grenades: Timer")
local smoke_radius_reference = ui.new_checkbox("VISUALS", "Other ESP", "Grenades: Smoke radius")
local smoke_radius_color_reference = ui.new_color_picker("VISUALS", "Other ESP", "Grenades: Smoke radius", 61, 147, 250, 180)
local molotov_radius_reference = ui.new_checkbox("VISUALS", "Other ESP", "Grenades: Molotov radius")
local molotov_radius_color_reference = ui.new_color_picker("VISUALS", "Other ESP", "Grenades: Molotov radius", 255, 63, 63, 190)
local molotov_team_reference = ui.new_checkbox("VISUALS", "Other ESP", "Grenades: Molotov team")

--I hate having to do this
local smoke_radius_units = 125
local smoke_duration = 17.55
local molotov_duration = 7

local molotovs_created_at = {}

local function distance(x1, y1, x2, y2)
	return math_sqrt((x2-x1)^2 + (y2-y1)^2)
end

local function draw_circle_3d(ctx, x, y, z, radius, r, g, b, a, accuracy, width, outline, start_degrees, percentage)
	local accuracy = accuracy ~= nil and accuracy or 3
	local width = width ~= nil and width or 1
	local outline = outline ~= nil and outline or false
	local start_degrees = start_degrees ~= nil and start_degrees or 0
	local percentage = percentage ~= nil and percentage or 1

	local screen_x_line_old, screen_y_line_old
	for rot=start_degrees, percentage*360, accuracy do
		local rot_temp = math_rad(rot)
		local lineX, lineY, lineZ = radius * math_cos(rot_temp) + x, radius * math_sin(rot_temp) + y, z
		local screen_x_line, screen_y_line = client_world_to_screen(ctx, lineX, lineY, lineZ)
		if screen_x_line ~=nil and screen_x_line_old ~= nil then
			for i=1, width do
				local i=i-1
				client_draw_line(ctx, screen_x_line, screen_y_line-i, screen_x_line_old, screen_y_line_old-i, r, g, b, a)
			end
			if outline then
				local outline_a = a/255*160
				client_draw_line(ctx, screen_x_line, screen_y_line-width, screen_x_line_old, screen_y_line_old-width, 16, 16, 16, outline_a)
				client_draw_line(ctx, screen_x_line, screen_y_line+1, screen_x_line_old, screen_y_line_old+1, 16, 16, 16, outline_a)
			end
		end
		screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
	end
end

local function lerp_pos(x1, y1, z1, x2, y2, z2, percentage)
	local x = (x2 - x1) * percentage + x1
	local y = (y2 - y1) * percentage + y1
	local z = (z2 - z1) * percentage + z1
	return x, y, z
end

local function is_molotov_burning(molotov)
	return entity_get_prop(molotov, "m_fireCount") > 0

	--for i=1, 64 do
	--	if entity_get_prop(molotov, "m_bFireIsBurning", i) == 1 then
	--		return true
	--	end
	--end
	--return false
end

local function on_paint(ctx)
	if ui_get(molotov_radius_reference) then
		local r, g, b, a = ui_get(molotov_radius_color_reference)

		local molotovs = entity_get_all("CInferno")
		for i=1, #molotovs do
			local molotov = molotovs[i]
			local origin_x, origin_y, origin_z = entity_get_prop(molotov, "m_vecOrigin")

			local cell_radius = 40
			local molotov_radius = 0
			local center_x, center_y, center_z

			local cells = {}
			local maximum_distance = 0
			local cell_max_1, cell_max_2

			--accumulate burning cells
			for i=1, 64 do
				if entity_get_prop(molotov, "m_bFireIsBurning", i) == 1 then
					local x_delta = entity_get_prop(molotov, "m_fireXDelta", i)
					local y_delta = entity_get_prop(molotov, "m_fireYDelta", i)
					local z_delta = entity_get_prop(molotov, "m_fireZDelta", i)
					table_insert(cells, {x_delta, y_delta, z_delta})
				end
			end

			for i=1, #cells do
				local cell = cells[i]
				local x_delta, y_delta, z_delta = cell[1], cell[2], cell[3]

				for i2=1, #cells do
					local cell2 = cells[i2]
					local distance = distance(x_delta, y_delta, cell2[1], cell2[2])
					if distance > maximum_distance then
						maximum_distance = distance
						cell_max_1 = cell
						cell_max_2 = cell2
					end
				end
			end

			if cell_max_1 ~= nil and cell_max_2 ~= nil then
				local x1, y1, z1 = origin_x+cell_max_1[1], origin_y+cell_max_1[2], origin_z+cell_max_1[3]
				local x2, y2, z2 = origin_x+cell_max_2[1], origin_y+cell_max_2[2], origin_z+cell_max_2[3]

				local world_x1, world_y1 = client_world_to_screen(ctx, x1, y1, z1)
				local world_x2, world_y2 = client_world_to_screen(ctx, x2, y2, z2)

				local center_x_delta, center_y_delta, center_z_delta = lerp_pos(cell_max_1[1], cell_max_1[2], cell_max_1[3], cell_max_2[1], cell_max_2[2], cell_max_2[3], 0.5)
				local center_x, center_y, center_z = origin_x+center_x_delta, origin_y+center_y_delta, origin_z+center_z_delta

				draw_circle_3d(ctx, center_x, center_y, center_z, maximum_distance/2+cell_radius, r, g, b, a, 15, 1, true)
			end
		end
	end

	local smoke_radius = ui_get(smoke_radius_reference)
	local grenade_timer = ui_get(grenade_timer_reference)
	local molotov_team = ui_get(molotov_team_reference)

	if smoke_radius or grenade_timer or molotov_team then
		local grenades = entity_get_all("CSmokeGrenadeProjectile")
		local tickcount = globals_tickcount()
		local tickinterval = globals_tickinterval()
		local curtime = globals_curtime()

		local molotovs = {}

		if grenade_timer or molotov_team then
			local molotovs_created_at_prev = molotovs_created_at
			molotovs_created_at = {}
			molotovs = entity_get_all("CInferno")
			for i=1, #molotovs do
				local molotov = molotovs[i]
				if is_molotov_burning(molotov) then
					molotovs_created_at[molotov] = molotovs_created_at_prev[molotov] ~= nil and molotovs_created_at_prev[molotov] or curtime
					table_insert(grenades, molotov)
				end
			end
		end
	
		for i=1, #grenades do
			local grenade = grenades[i]
			local class_name = entity_get_classname(grenade)

			local text, wx, wy
			local a_multiplier = 1
			if class_name == "CSmokeGrenadeProjectile" then
				local x, y, z = entity_get_prop(grenade, "m_vecOrigin")
				wx, wy = client_world_to_screen(ctx, x, y, z)
				local did_smoke_effect = entity_get_prop(grenade, "m_bDidSmokeEffect") == 1
				if wx ~= nil then

					if did_smoke_effect then
						local ticks_created = entity_get_prop(grenade, "m_nSmokeEffectTickBegin")
						if ticks_created ~= nil then
							local time_since_explosion = tickinterval * (tickcount - ticks_created)
							if time_since_explosion > 0 and smoke_duration-time_since_explosion > 0 then
								if grenade_timer then
									a_multiplier = 1 - time_since_explosion / smoke_duration
									text = string_format("%.1f  S", smoke_duration-time_since_explosion)
								end
								if smoke_radius then
									local r, g, b, a = ui_get(smoke_radius_color_reference)
									local radius = smoke_radius_units
									if 0.3 > time_since_explosion then
										radius = radius * 0.6 + (radius * (time_since_explosion / 0.3))*0.4
										a = a * (time_since_explosion / 0.3)
									end
									if 1.0 > smoke_duration-time_since_explosion then
										radius = radius * (((smoke_duration-time_since_explosion) / 1.0)*0.3 + 0.7)
									end
									draw_circle_3d(ctx, x, y, z, radius, r, g, b, a*math_min(1, a_multiplier*1.3), 9, 1, true)
								end
							end
						end
					end
				end
			elseif class_name == "CInferno" then
				if grenade_timer or molotov_team then
					local x, y, z = entity_get_prop(grenade, "m_vecOrigin")
					wx, wy = client_world_to_screen(ctx, x, y, z)
					if wx ~= nil then
						if grenade_timer then
							if molotovs_created_at[grenade] ~= nil then

								local time_since_created = curtime - molotovs_created_at[grenade]
								a_multiplier = math_max(0, 1 - time_since_created / molotov_duration)
								text = string_format("%.1f  S", math_max(0, molotov_duration - time_since_created))
							end
						end
						if molotov_team then
							local thrower = entity_get_prop(grenade, "m_hOwnerEntity")
							local is_safe = false
							if thrower ~= nil and tonumber(client_get_cvar("mp_friendlyfire")) == 0 and thrower ~= entity_get_local_player() and not entity_is_enemy(thrower) then
								is_safe = true
							end
							if is_safe then
								client_draw_text(ctx, wx-19, wy+5, 149, 184, 6, 255*a_multiplier, nil, 0, "✔")
							else
								client_draw_text(ctx, wx-19, wy+4, 230, 21, 21, 255*a_multiplier, nil, 0, "❌")
							end
						end
					end
				end
			end
			if wx ~= nil and text ~= nil then
				client_draw_text(ctx, wx, wy+20, 255, 255, 255, math_max(30, a_multiplier * 255), "c-", 150, text)
			end
		end
	end
end
client.set_event_callback("paint", on_paint)