local function invalid(unit_number)
	-- if not game.get_entity_by_unit_number(unit_number).valid or not storage.units[unit_number].container.valid then
    -- memory unit is corrupted, clear data
    
--     game.print{"storage-unit-corruption", storage.units[unit_number].get_inventory(defines.inventory.chest).get_item_count()}
    
--     if game.get_entity_by_unit_number(unit_number).valid then game.get_entity_by_unit_number(unit_number).destroy() end
--     if storage.units[unit_number].valid then storage.units[unit_number].destroy() end
--     storage.units[unit_number] = nil

-- 		return true
-- 	end
--   -- entities are valid, return false
-- 	return false
-- end

-- local function create_container_from_combinator(combinator, stored_data)
--   -- if invalid in some way return false so the calling method knows something went wrong
--   if not combinator.type == "combinator" or not combinator.name:sub(1, 9) == "efficient-" then return false end

--   combinator.operable = false
--   combinator.rotatable = false

--   container = combinator.surface.create_entity {
--     name = "efficient-container-size-" .. math.ceil(math.abs(combinator.selection_box["left_top"]["x"] - combinator.selection_box["right_bottom"]["x"])),
--     position = combinator.position,
--     force = combinator.force
--   }

--   container.minable = false
-- 	container.operable = false
-- 	container.destructible = false

--   if stored_data then
--     -- TODO transfer stored data from previous (?) entity
--   end
	
-- 	storage.units[combinator.unit_number] = {
-- 		container = container,
-- 		lag_id = math.random(0, 59),
--     updates_per_batch = 1
-- 	}

--   -- return positive unit creation
--   return true
end

script.on_init(function()
	storage.units = {}
	
  -- TODO picker dollies stuff
	-- if remote.interfaces["PickerDollies"] then
	-- 	remote.call("PickerDollies", "add_blacklist_name", "storage-unit", true)
	-- 	remote.call("PickerDollies", "add_blacklist_name", "storage-unit-combinator", true)
	-- end
end)

script.on_configuration_changed(function()
	storage.units = storage.units or {}
	
  -- TODO picker dollies stuff
	-- if remote.interfaces["PickerDollies"] then
	-- 	remote.call("PickerDollies", "add_blacklist_name", "storage-unit", true)
	-- 	remote.call("PickerDollies", "add_blacklist_name", "storage-unit-combinator", true)
	-- end

  -- check validity for all active entities
  local  corrupted_units = 0
	for unit_number, _ in pairs(storage.units) do
		if invalid(unit_number) then
      corrupted_units = corrupted_units + 1
		end
	end
  if corrupted_units ~= 0 then
    game.print{"storage-unit-corruption-total", i}
  end
end)

-- todo remove this
-- function set_filter(unit_data)
-- 	local inventory = unit_data.inventory
-- 	local item = unit_data.item
-- 	local combinator = unit_data.combinator
-- 	for i = 1, #inventory do
-- 		local stack = inventory[i]
-- 		if not inventory.set_filter(i, item) or (stack.valid_for_read and stack.name ~= item) then
-- 			combinator.surface.spill_item_stack(combinator.position, stack)
-- 			stack.clear()
-- 			inventory.set_filter(i, item)
-- 		end
-- 	end
-- end

-- todo handle more item types
local basic_item_types = {["item"] = true, ["capsule"] = true, ["gun"] = true, ["module"] = true}
-- local function detect_item(unit_data)
-- 	local inventory = unit_data.inventory
-- 	for name, count in pairs(inventory.get_contents()) do
-- 		if basic_item_types[prototypes.item[name].type] then
-- 			unit_data.item = name
-- 			unit_data.stack_size = prototypes.item[name].stack_size
-- 			unit_data.mean = unit_data.stack_size * #inventory / 2
-- 			set_filter(unit_data)
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- local function desired_stacks(stack_size)
--   if stack_size < 50 then
--     return false
--   else
--     return math.floor(100 / stack_size)
--   end
-- end

--------------------------------------------------------------------------------------------------- update unit
function update_unit(unit_data, unit_number, forced)
  -- -- if invalid, end
	-- if invalid(unit_number) then return end
	
	-- local changed = false

  -- -- for each different item type in the inventory
  -- for i, item in pairs(storage.units[unit_number].container.get_inventory(defines.inventory.chest).get_contents()) do
  --   local stack_size = prototypes.item[item.name].stack_size
  --   local count = item.count
  --   local count_from_max = stack_size * desired_stacks(stack_size) or nil
  -- end

  -- unit_data.count = unit_data.count or 0
  
  -- local count_from_max = (prototypes.entity[unit_data.combinator.name:sub(11,-12)].get_inventory_size(defines.inventory.chest) - #unit_data.inventory) * unit_data.stack_size - unit_data.count
  -- local inventory_difference = inventory_count - unit_data.mean

  -- -- check for a difference, if so something has changed so the display needs to be updated later
  -- if unit_data.previous_inventory_count ~= inventory_count then changed = true end

  -- if count_from_max ~= 0 and inventory_difference > 0 and changed then
  --   -- more than halfway full and not full internally, so remove some

  --   -- if trying to push more than it can, then push the maximum possible
  --   if inventory_difference > count_from_max then inventory_difference = count_from_max end
  --   unit_data.inventory.remove{name = unit_data.item, count = inventory_difference}
  --   unit_data.count = unit_data.count + inventory_difference
  --   inventory_count = inventory_count - inventory_difference

  --   unit_data.inventory.sort_and_merge()
  -- elseif unit_data.count > 0 and inventory_difference < 0 then
  --   -- less than halfway full and not empty internally, so add some

  --   -- if trying to pull more than it can, then pull the maximum possible
  --   if unit_data.count < -inventory_difference then inventory_difference = -unit_data.count end
  --   unit_data.container.insert{name = unit_data.item, count = -inventory_difference}
  --   unit_data.count = unit_data.count + inventory_difference
  --   inventory_count = inventory_count - inventory_difference
    
	-- 	unit_data.inventory.sort_and_merge()
  -- end
  -- -- otherwise do nothing!
	
  -- -- if changed or forced, then update the combinator and display
	-- if forced or changed then
  --   unit_data.previous_inventory_count = inventory_count
  
  --   -- update combinator
  --   unit_data.combinator.get_or_create_control_behavior().get_section(1).set_slot(1,{
  --     value = {
  --       type = "item",
  --       name = unit_data.item,
  --       -- quality = nil -- TODO add quality support
  --     },
  --     max = unit_data.count + inventory_count
  --   })

  --   -- update floating text
  --   if not unit_data.text then
  --     unit_data.text = rendering.draw_text {
  --       surface = unit_data.combinator.surface,
  --       target = unit_data.combinator,
  --       text = "",
  --       alignment = "center",
  --       scale = 1.5,
  --       only_in_alt_mode = true,
  --       color = {r = 1, g = 1, b = 1}
  --     }
  --   end

  --   local n = math.floor(unit_data.count)
    
  --   -- calculate the minimum display size
  --   local suffix = 1
  --   while n >= 1000 do
  --     n = math.floor(n / 100) / 10
  --     suffix = suffix + 1
  --   end
    
  --   -- add .0 to n if there is no decimal
  --   if suffix ~= 1 and math.floor(n) == n then n = tostring(n) .. ".0" end
    
  --   unit_data.text.text = {"big-numbers." .. suffix, n}
	-- end
end

script.on_event(defines.events.on_tick, function(event)
	-- for unit_number, unit_data in pairs(storage.units) do
  --   -- all of the fancy math says to run when lag_id = event.tick, but also increase rates when updates_per_batch increases
	-- 	if unit_data.lag_id % math.floor(60 / unit_data.updates_per_batch) == event.tick % math.floor(60 / unit_data.updates_per_batch) then
	-- 		update_unit(unit_number)
	-- 	end
	-- end
end)

--------------------------------------------------------------------------------------------------- on combinator constructed
local function on_created(event)
	-- local combinator = event.created_entity or event.entity
	-- if entity.name:sub(0,9) ~= "efficient" then return end
	-- local position = combinator.position
	-- local surface = combinator.surface
	-- local force = combinator.force

	-- local container = surface.create_entity{
	-- 	name = "efficient-container-size-" .. math.ceil(math.abs(combinator.selection_box["left_top"]["x"] - combinator.selection_box["right_bottom"]["x"])),
	-- 	position = {position.x, position.y},
	-- 	force = force
	-- }
	-- container.operable = false
	-- container.destructible = false
	
	-- local unit_data = {
	-- 	combinator = combinator,
	-- 	count = 0,
	-- 	container = container,
	-- 	inventory = container.get_inventory(defines.inventory.chest),
	-- 	lag_id = math.random(0, updates_per_tick - 1)
	-- }
	-- storage.units[combinator.unit_number] = unit_data

	-- local stack = event.stack
	-- local tags = stack and stack.valid_for_read and stack.type == "item-with-tags" and stack.tags
	-- if tags and tags.name then
	-- 	unit_data.count = tags.count
	-- 	unit_data.item = tags.name
	-- 	unit_data.stack_size = prototypes.item[tags.name].stack_size
	-- 	unit_data.mean = unit_data.stack_size * #unit_data.inventory / 2
	-- 	set_filter(unit_data)
	-- 	update_unit(unit_data, combinator.unit_number, true)
	-- end
end

-- register event to script handler
script.on_event(defines.events.on_built_entity, on_created, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_robot_built_entity, on_created, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.script_raised_built, on_created, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.script_raised_revive, on_created, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- on combinator cloned
script.on_event(defines.events.on_entity_cloned, function(event)
	-- local combinator = event.source
	-- if combinator.name:sub(0,9) ~= "efficient" then return end
	-- local destination = event.destination
	
	-- local unit_data = storage.units[combinator.unit_number]
	-- local position = destination.position
	-- local surface = destination.surface
	
	-- local container = unit_data.container

	-- if container.valid then
	-- 	container = container.clone{position = {position.x, position.y}, surface = surface}
	-- else
	-- 	container = surface.create_entity{
	-- 		name = "efficient-container-size-" .. math.ceil(math.abs(combinator.selection_box["left_top"]["x"] - combinator.selection_box["right_bottom"]["x"])),
	-- 		position = {position.x, position.y},
	-- 		force = combinator.force
	-- 	}
	-- 	container.destructible = false
	-- 	container.operable = false
	-- end
	
	-- local item = unit_data.item
	-- unit_data = {
	-- 	container = container,
	-- 	item = item,
	-- 	count = unit_data.count,
	-- 	combinator = destination,
	-- 	mean = unit_data.mean,
  --   stack_size = unit_data.stack_size,
	-- 	inventory = container.get_inventory(defines.inventory.chest),
	-- 	lag_id = math.random(0, updates_per_tick - 1)
	-- }
	-- storage.units[destination.unit_number] = unit_data
               
	-- if item then
	-- 	set_filter(unit_data)
	-- 	update_unit(storage.units[destination.unit_number], destination.unit_number, true)
	-- end
end, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- on combinator destroyed      TODO reset to a generic box whenever the container is destroyed and insert the appropriate number of items
local function on_destroyed(event)
  -- -- check if correct container
	-- if event.entity.name:sub(0,9) ~= "efficient" then return end
	
  -- -- clear event buffer
	-- if event.buffer and unit_data.item and unit_data.count ~= 0 then
  --   event.buffer.clear()
  -- end
	
  -- -- unassign unit_number from storage and replace the corresponding container with a basic one
	-- unit_data = storage.units[event.entity.unit_number]

  -- if unit_data.count ~= nil and unit_data.count > 0 and event.entity then
  --   local new_entity = event.entity.surface.create_entity{
  --     name = event.entity.name:sub(11,-12),
  --     position = {event.entity.position.x, event.entity.position.y},
  --     force = event.entity.force
  --   }
  --   new_entity.insert{name = unit_data.item, count = unit_data.count}
  -- end

  -- local unit_number = unit_data.combinator.unit_number

  -- unit_data.container.destroy()
  -- unit_data.combinator.destroy()
  -- storage.units[unit_number] = nil
end

-- register event to script handler
script.on_event(defines.events.on_entity_died, on_destroyed, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.script_raised_destroy, on_destroyed, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_player_mined_entity, on_destroyed, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- pre combinator mined
local function pre_mined(event)
	-- local combinator = event.entity
  -- -- check if correct container
	-- if combinator.name:sub(0,9) ~= "efficient" then return end
	
	-- unit_data = storage.units[combinator.unit_number]
	
  -- -- if an item filter exists
	-- if unit_data.item then
		
  --   -- store information to be collected in on_destroyed event
	-- 	if unit_data.inventory.get_item_count() > 0 then
	-- 		unit_data.count = unit_data.count + unit_data.inventory.remove{name = unit_data.item, count = unit_data.inventory.get_item_count()}
	-- 	end
	-- end
end

-- register event to script handler
script.on_event(defines.events.on_pre_player_mined_item, pre_mined, {{filter = "type", type = "constant-combinator"}})
script.on_event(defines.events.on_robot_pre_mined, pre_mined, {{filter = "type", type = "constant-combinator"}})

--------------------------------------------------------------------------------------------------- deconstruction planner
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  -- -- if container and not already efficient storage
  -- if event.entity.valid and event.entity.type == "constant-combinator" and event.entity.name:sub(0,9) == "efficient" then

  --   unit_data = storage.units[event.entity.unit_number]

  --   local container = event.entity.surface.create_entity{
  --     name = event.entity.name:sub(11, -12),
  --     position = event.entity.position,
  --     force = event.entity.force or nil,
  --     player = game.get_player(event.player_index) or nil
  --   }
  --   -- if container is nil
  --   if container == nil then error("tried to create normal container but got nil (deconstruction event)") end

  --   if unit_data.count ~= nil and unit_data.count + unit_data.inventory.get_item_count() > 0 then
  --     container.get_inventory(defines.inventory.chest).insert{name = unit_data.item, count = unit_data.count + unit_data.inventory.get_item_count()}
  --   end
  --   container.order_deconstruction(event.entity.force or nil, game.get_player(event.player_index) or nil)

  --   local unit_number = unit_data.combinator.unit_number

  --   unit_data.container.destroy()
  --   unit_data.combinator.destroy()
  --   storage.units[unit_number] = nil
  -- end
end, {{filter = "type", type = "constant-combinator"}})















-- TODO undo and redo stack. both will be annoying if handled















------------------------------------------------------------------------------------------------- upgrade planner
script.on_event(defines.events.on_player_selected_area, function(event)
  -- if not correct tool, end
  if event.item ~= "container-shrinker" then return end

  -- for each entity in selection
  for e, entity in pairs(event.entities) do

    -- if container and not already efficient storage
    if entity.type == "container" and entity.name:sub(0,9) ~= "efficient" and prototypes.entity["efficient-" .. entity.name .. "-combinator"] then
      
      -- get item contents
      local contents = entity.get_inventory(defines.inventory.chest).get_contents()

      local combinator = event.surface.create_entity{
        name = "efficient-" .. entity.name .. "-combinator",
        position = entity.position,
        player = game.get_player(event.player_index),
        force = entity.force
      }
      combinator.operable = false
      combinator.destructible = false

      local container = event.surface.create_entity{
        name = "efficient-container-size-" .. math.ceil(combinator.selection_box.right_bottom.x - combinator.selection_box.left_top.x),
        position = entity.position,
        player = game.get_player(event.player_index),
        force = entity.force
      }
      container.operable = false
      container.destructible = false

      -- connect red and green wires on the combinator to the container, and preexisting connections
      for _, connector in pairs(container.get_wire_connectors(true)) do
        -- add old connections


        -- connect to combinator
        connector.connect_to(combinator.get_wire_connector(connector.wire_connector_id, true))
      end

      -- get rid of old container
      entity.destroy{}

      local unit_data = {
        container = container,
        lag_index = math.random(0, 59),
        update_count = 1
      }
      storage.units[combinator.unit_number] = unit_data

      update_unit(unit_data, combinator.unit_number, force)

    elseif entity.type == "container" and entity.name:sub(1, 9) ~= "efficient" then
      game.print({"messages.invalid-shrink", entity.name})
    end
  end
end)

------------------------------------------------------------------------------------------------- downgrade planner
function downgrade_event(event)
  -- if not correct tool, end
  if event.item ~= "container-shrinker" then return end

  -- for each entity in selection
  for e, entity in pairs(event.entities) do

    -- if container and not already efficient storage
    if entity.valid and entity.type == "constant-combinator" and entity.name:sub(0,9) == "efficient" then

      unit_data = storage.units[entity.unit_number]

      local container = event.surface.create_entity{
        name = entity.name:sub(11, -12),
        position = entity.position,
        force = entity.force or nil,
        player = game.get_player(event.player_index) or nil
      }
      -- if container is nil
      if container == nil then error("tried to create normal container but got nil (downgrade event)") end
      
      if unit_data.count ~= nil and unit_data.count + unit_data.inventory.get_item_count() > 0 then
        container.get_inventory(defines.inventory.chest).insert{name = unit_data.item, count = unit_data.count + unit_data.inventory.get_item_count()}
      end

      local unit_number = unit_data.combinator.unit_number

      unit_data.container.destroy()
      unit_data.combinator.destroy()
      storage.units[unit_number] = nil
    end
  end
end

script.on_event(defines.events.on_player_reverse_selected_area, downgrade_event)
script.on_event(defines.events.on_player_alt_reverse_selected_area, downgrade_event)


--[[ data stored in storage.units[unit_number] = {
  container,
  lag_id
}

everything else can be found at runtime and does not need to be stored
  even better, the lag_id and container id could maybe be stored inside the combinator itself

  ]]