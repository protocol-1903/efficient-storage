local update_slots = 4

local function is_storage_unit(entity)
  if entity.name:sub(0,9) == "efficient" then return true
  else return false
  end
end

local function validity_check(unit_number, unit_data, force)
	if not unit_data.combinator.valid or not unit_data.container.valid then
    -- memory unit is corrupted, clear data
    
    if unit_data.combinator.valid then unit_data.combinator.destroy() end
    if unit_data.container.valid then unit_data.container.destroy() end
    
    game.print{'storage-unit-corruption', unit_data.count, unit_data.item or 'nothing'}
    global.units[unit_number] = nil

		return false
	end
	return true
end

local function compactify(n)
	n = math.floor(n)
	
  -- calculate the minimum display size
	local suffix = 1
	while n >= 1000 do
		n = math.floor(n / 100) / 10
		suffix = suffix + 1
	end
	
  -- add .0 to n if there is no decimal
	if suffix ~= 1 and math.floor(n) == n then n = tostring(n) .. '.0' end
	
	return {'big-numbers.' .. suffix, n}
end

local function setup()
	global.units = global.units or {}
	
  -- TODO picker dollies stuff
	-- if remote.interfaces["PickerDollies"] then
	-- 	remote.call("PickerDollies", "add_blacklist_name", "storage-unit", true)
	-- 	remote.call("PickerDollies", "add_blacklist_name", "storage-unit-combinator", true)
	-- end
end

script.on_init(setup)
script.on_configuration_changed(function()
	setup()

  -- check validity for all active entities
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.item and validity_check(unit_number, unit_data) then
			local prototype = game.item_prototypes[unit_data.item]

			if prototype then
        -- entity is valid
				unit_data.stack_size = prototype.stack_size
				unit_data.mean = unit_data.stack_size * #unit_data.inventory / 2
			else
        -- entity is corrupted, remove and report to player
        
        if unit_data.combinator.valid then unit_data.combinator.destroy() end
        if unit_data.container.valid then unit_data.container.destroy() end
        
        game.print{'memory-unit-corruption', unit_data.count, unit_data.item or 'nothing'}
        global.units[unit_number] = nil
			end
		end
	end
end)

function set_filter(unit_data)
	local inventory = unit_data.inventory
	local item = unit_data.item
	local combinator = unit_data.combinator
	for i = 1, #inventory do
		local stack = inventory[i]
		if not inventory.set_filter(i, item) or (stack.valid_for_read and stack.name ~= item) then
			combinator.surface.spill_item_stack(combinator.position, stack)
			stack.clear()
			inventory.set_filter(i, item)
		end
	end
end

local basic_item_types = {['item'] = true, ['capsule'] = true, ['gun'] = true, ['module'] = true}
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

local function detect_item(unit_data)
	local inventory = unit_data.inventory
	for name, count in pairs(inventory.get_contents()) do
		if check_for_basic_item(name) then
			unit_data.item = name
			unit_data.stack_size = game.item_prototypes[name].stack_size
			unit_data.mean = unit_data.stack_size * #inventory / 2
			set_filter(unit_data)
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------------------------- update unit
function update_unit(unit_data, unit_number, force)
  -- if invalid, end
	if not validity_check(unit_number, unit_data, force) then return end
	
	local changed = false
	
	if unit_data.item == nil then changed = detect_item(unit_data) end
  
  -- if there is no filter, then end
	if unit_data.item == nil then return end
	
	local inventory_count = unit_data.inventory.get_item_count(unit_data.item)

  unit_data.count = unit_data.count or 0
  
  local count_from_max = (game.entity_prototypes[unit_data.combinator.name:sub(11,-12)].get_inventory_size(defines.inventory.chest) - #unit_data.inventory) * unit_data.stack_size - unit_data.count
  local inventory_difference = inventory_count - unit_data.mean

  -- check for a difference, if so something has changed so the display needs to be updated later
  if unit_data.previous_inventory_count ~= inventory_count then changed = true end

  if count_from_max ~= 0 and inventory_difference > 0 and changed then
    -- more than halfway full and not full internally, so remove some

    -- if trying to push more than it can, then push the maximum possible
    if inventory_difference > count_from_max then inventory_difference = count_from_max end
    unit_data.inventory.remove{name = unit_data.item, count = inventory_difference}
    unit_data.count = unit_data.count + inventory_difference
    inventory_count = inventory_count - inventory_difference

    unit_data.inventory.sort_and_merge()
  elseif unit_data.count > 0 and inventory_difference < 0 then
    -- less than halfway full and not empty internally, so add some

    -- if trying to pull more than it can, then pull the maximum possible
    if unit_data.count < -inventory_difference then inventory_difference = -unit_data.count end
    unit_data.container.insert{name = unit_data.item, count = -inventory_difference}
    unit_data.count = unit_data.count + inventory_difference
    inventory_count = inventory_count - inventory_difference
    
		unit_data.inventory.sort_and_merge()
  end
  -- otherwise do nothing!
	
  -- if changed or force, then update the combinator and display
	if force or changed then
    unit_data.previous_inventory_count = inventory_count
  
    -- update combinator
    unit_data.combinator.get_or_create_control_behavior().set_signal(1, {
      signal = {type = "item", name = unit_data.item},
      count = math.min(2147483647, unit_data.count + inventory_count)
    })

    -- update floating text
    if unit_data.text then
      rendering.set_text(unit_data.text, compactify(unit_data.count + inventory_count))
    else
      unit_data.text = rendering.draw_text{
        surface = unit_data.combinator.surface,
        target = unit_data.combinator,
        text = compactify(unit_data.count + inventory_count),
        alignment = 'center',
        scale = 1.5,
        only_in_alt_mode = true,
        color = {r = 1, g = 1, b = 1}
      }
    end
	end
end

-- dynamic polling rate???
script.on_nth_tick(15, function(event)
	local smooth_ups = event.tick % update_slots
	
	for unit_number, unit_data in pairs(global.units) do
		if unit_data.lag_id == smooth_ups then
			update_unit(unit_data, unit_number)
		end
	end
end)

--------------------------------------------------------------------------------------------------- on combinator constructed
local function on_created(event)
	local combinator = event.created_entity or event.entity
	if not is_storage_unit(combinator) then return end
	local position = combinator.position
	local surface = combinator.surface
	local force = combinator.force

	local container = surface.create_entity{
		name = "efficient-container-size-" .. math.ceil(math.abs(combinator.selection_box["left_top"]["x"] - combinator.selection_box["right_bottom"]["x"])),
		position = {position.x, position.y},
		force = force
	}
	container.operable = false
	container.destructible = false
	
	local unit_data = {
		combinator = combinator,
		count = 0,
		container = container,
		inventory = container.get_inventory(defines.inventory.chest),
		lag_id = math.random(0, update_slots - 1)
	}
	global.units[combinator.unit_number] = unit_data

	local stack = event.stack
	local tags = stack and stack.valid_for_read and stack.type == "item-with-tags" and stack.tags
	if tags and tags.name then
		unit_data.count = tags.count
		unit_data.item = tags.name
		unit_data.stack_size = game.item_prototypes[tags.name].stack_size
		unit_data.mean = unit_data.stack_size * #unit_data.inventory / 2
		set_filter(unit_data)
		update_unit(unit_data, combinator.unit_number, true)
	end
end

-- register event to script handler
script.on_event(defines.events.on_built_entity, on_created, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_robot_built_entity, on_created, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.script_raised_built, on_created, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.script_raised_revive, on_created, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- on combinator cloned
script.on_event(defines.events.on_entity_cloned, function(event)
	local combinator = event.source
	if not is_storage_unit(combinator) then return end
	local destination = event.destination
	
	local unit_data = global.units[combinator.unit_number]
	local position = destination.position
	local surface = destination.surface
	
	local container = unit_data.container

	if container.valid then
		container = container.clone{position = {position.x, position.y}, surface = surface}
	else
		container = surface.create_entity{
			name = "efficient-container-size-" .. math.ceil(math.abs(combinator.selection_box["left_top"]["x"] - combinator.selection_box["right_bottom"]["x"])),
			position = {position.x, position.y},
			force = combinator.force
		}
		container.destructible = false
		container.operable = false
	end
	
	local item = unit_data.item
	unit_data = {
		container = container,
		item = item,
		count = unit_data.count,
		combinator = destination,
		mean = unit_data.mean,
    stack_size = unit_data.stack_size,
		inventory = destination.get_inventory(defines.inventory.chest),
		lag_id = math.random(0, update_slots - 1)
	}
	global.units[destination.unit_number] = unit_data
               
	if item then
		set_filter(unit_data)
		update_unit(global.units[destination.unit_number], destination.unit_number, true)
	end
end, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- on combinator destroyed      TODO reset to a generic box whenever the container is destroyed and insert the appropriate number of items
local function on_destroyed(event)
  -- check if correct container
	if not is_storage_unit(event.entity) then return end
	
  -- clear event buffer
	if event.buffer and unit_data.item and unit_data.count ~= 0 then
    event.buffer.clear()
  end
	
  -- unassign unit_number from global and replace the corresponding container with a basic one
	unit_data = global.units[event.entity.unit_number]

  if unit_data.count ~= nil and unit_data.count > 0 and event.entity then
    local new_entity = event.entity.surface.create_entity{
      name = event.entity.name:sub(11,-12),
      position = {event.entity.position.x, event.entity.position.y},
      force = event.entity.force
    }
    new_entity.insert{name = unit_data.item, count = unit_data.count}
  end

  local unit_number = unit_data.combinator.unit_number

  unit_data.container.destroy()
  unit_data.combinator.destroy()
  global.units[unit_number] = nil
end

-- register event to script handler
script.on_event(defines.events.on_entity_died, on_destroyed, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.script_raised_destroy, on_destroyed, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_player_mined_entity, on_destroyed, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- pre combinator mined
local function pre_mined(event)
	local combinator = event.entity
  -- check if correct container
	if not is_storage_unit(combinator) then return end
	
	unit_data = global.units[combinator.unit_number]
	
  -- if an item filter exists
	if unit_data.item then
		
    -- store information to be collected in on_destroyed event
		if unit_data.inventory.get_item_count() > 0 then
			unit_data.count = unit_data.count + unit_data.inventory.remove{name = unit_data.item, count = unit_data.inventory.get_item_count()}
		end
	end
end

-- register event to script handler
script.on_event(defines.events.on_pre_player_mined_item, pre_mined, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_robot_pre_mined, pre_mined, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined, {{filter = "type", type = "constant-combinator"}})

------------------------------------------------------------------------------------------------- upgrade planner
script.on_event(defines.events.on_player_selected_area, function(event)
  -- if not correct tool, end
  if event.item ~= "inventory-shrinker" then return end

  -- for each entity in selection
  for e, entity in pairs(event.entities) do

    -- if container and not already efficient storage
    if entity.type == "container" and not is_storage_unit(entity) and game.entity_prototypes["efficient-" .. entity.name .. "-combinator"] ~= nil then
      
      -- if has only one item type (will do multi item storage later)
      local counts = entity.get_inventory(defines.inventory.chest).get_contents()
      local items = {}

      for item, _ in pairs(counts) do
        items[#items+1] = item
      end
      
      if #items <= 1 then
        local item = items[1] or nil
        local count = counts[item] or nil
        
        local name = entity.name
        local position = entity.position
        local surface = event.surface
        local player = game.get_player(event.player_index)
        local force = player.force

        entity.destroy{raise_destroy = true}

        local combinator = surface.create_entity{
          name = "efficient-" .. name .. "-combinator",
          position = position,
          player = player,
          force = force
        }

        local container = surface.create_entity{
          name = "efficient-container-size-" .. math.ceil(math.abs(combinator.selection_box["left_top"]["x"] - combinator.selection_box["right_bottom"]["x"])),
          position = position,
          player = player,
          force = force
        }
        container.operable = false
        container.destructible = false

        local unit_data = {
          container = container,
          item = item,
          count = count,
          combinator = combinator,
          stack_size = item and game.item_prototypes[item].stack_size or nil,
          mean = item and game.item_prototypes[item].stack_size * #container.get_inventory(defines.inventory.chest) / 2 or nil,
          inventory = container.get_inventory(defines.inventory.chest),
          lag_id = math.random(0, update_slots - 1)
        }
        global.units[combinator.unit_number] = unit_data

        update_unit(unit_data, combinator.unit_number, force)

      else
        -- TODO multi item storage
        game.print("Cannot shrink! Too many item types! Remove some items.\nOr wait for an update :)")
      end
    elseif entity.type == "container" and entity.name:sub(1, 9) ~= "efficient" then
      game.print("Cannot shrink, " .. entity.name .. " is invalid")
    end
  end
end)

------------------------------------------------------------------------------------------------- downgrade planner
function downgrade_event(event)
  -- if not correct tool, end
  if event.item ~= "inventory-shrinker" then return end

  -- for each entity in selection
  for e, entity in pairs(event.entities) do

    -- if container and not already efficient storage
    if entity.valid and entity.type == "constant-combinator" and is_storage_unit(entity) then

      unit_data = global.units[entity.unit_number]

      local container = event.surface.create_entity{
        name = entity.name:sub(11, -12),
        position = entity.position,
        force = entity.force or nil,
        player = game.get_player(event.player_index) or nil
      }
      
      if unit_data.count ~= nil and unit_data.count + unit_data.inventory.get_item_count() > 0 then
        container.get_inventory(defines.inventory.chest).insert{name = unit_data.item, count = unit_data.count + unit_data.inventory.get_item_count()}
      end

      local unit_number = unit_data.combinator.unit_number

      unit_data.container.destroy()
      unit_data.combinator.destroy()
      global.units[unit_number] = nil
    end
  end
end

script.on_event(defines.events.on_player_reverse_selected_area, downgrade_event)
script.on_event(defines.events.on_player_alt_reverse_selected_area, downgrade_event)