-- shared code between memory units and fluid memory units

local function compactify(n)
	n = math.floor(n)
	
	local suffix = 1
	local new
	while n >= 1000 do
		new = math.floor(n / 100) / 10
		if n == new then
			return {'big-numbers.infinity'}
		else
			n = new
		end
		suffix = suffix + 1
	end
	
	if suffix ~= 1 and math.floor(n) == n then n = tostring(n) .. '.0' end
	
	return {'big-numbers.' .. suffix, n}
end

local function open_inventory(player)
	if not global.blank_gui_item then
		local inventory = game.create_inventory(1)
		inventory[1].set_stack('blank-gui-item')
		inventory[1].allow_manual_label_change = false
		global.empty_gui_item = inventory[1]
	end
	player.opened = nil
	player.opened = global.empty_gui_item
	return player.opened
end

local function update_display_text(unit_data, entity, localised_string)
	if unit_data.text then
		rendering.set_text(unit_data.text, localised_string)
	else
		unit_data.text = rendering.draw_text{
			surface = entity.surface,
			target = entity,
			text = localised_string,
			alignment = 'center',
			scale = 1.5,
			only_in_alt_mode = true,
			color = {r = 1, g = 1, b = 1}
		}
	end
end

local function update_combinator(combinator, signal, count)
	combinator.get_or_create_control_behavior().set_signal(1, {
		signal = signal,
		count = math.min(2147483647, count)
	})
end

local basic_item_types = {['item'] = true, ['capsule'] = true, ['gun'] = true, ['rail-planner'] = true, ['module'] = true}
local function check_for_basic_item(item)
	local items_with_metadata = global.items_with_metadata
	if not items_with_metadata then
		items_with_metadata = {}
		for item_name, prototype in pairs(game.item_prototypes) do
			if not basic_item_types[prototype.type] then
				items_with_metadata[item_name] = true
			end
		end
		global.items_with_metadata = items_with_metadata
	end
	return not items_with_metadata[item]
end

local function memory_unit_corruption(unit_number, unit_data)
	local entity = unit_data.entity
	local combinator = unit_data.combinator
	
	if entity.valid then entity.destroy() end
	if combinator.valid then combinator.destroy() end
	
	game.print{'memory-unit-corruption', unit_data.count, unit_data.item or 'nothing'}
	global.units[unit_number] = nil
end

local function validity_check(unit_number, unit_data, force)
	if not unit_data.entity.valid or not unit_data.combinator.valid then
		memory_unit_corruption(unit_number, unit_data)
		return true
	end
	
	return false
end

return {
	update_display_text = update_display_text,
	update_combinator = update_combinator,
	compactify = compactify,
	open_inventory = open_inventory,
	check_for_basic_item = check_for_basic_item,
	memory_unit_corruption = memory_unit_corruption,
	validity_check = validity_check
}