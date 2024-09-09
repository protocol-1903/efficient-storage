-- require "gui-styles"

local circuit_wire_connection_points = {
	green = {0.25, -0.15},
	red = {-0.15, 0.1}
}

circuit_wire_connection_points = {
	shadow = circuit_wire_connection_points,
	wire = circuit_wire_connection_points
}

circuit_wire_connection_points = {
	circuit_wire_connection_points,
	circuit_wire_connection_points,
	circuit_wire_connection_points,
	circuit_wire_connection_points
}

local nothing = {
	filename = "__efficient-storage__/graphics/entity/nothing.png",
	priority = "extra-high",
	size = 1
}

function blacklisted(p, prototype)
  blacklist = {
    "logo",
    "wreck",
    "crash",
    "dummy",
    "red-chest",
    "blue-chest",
    "dino-dig-site",
    "aerial-base",
    "ipod" -- ??? what the heck py ???
  }
  for _, check in pairs(blacklist) do
    if string.find(p, check) then
      return true
    end
  end
  return false
end

-- TODO internal inventory size calculations based on size of container and maximum stack size of inserters (special compatability required for inserter cranes varieties)
-- if inserter lib is installed, utilize to further refine calculations
-- also check smooth_ups and update_slots to determine how many ticks can pass before an update occurs
-- i.e. with 4 possible inserter positions, max stack size of 12, (assume no more than one isertion every 20 ticks), and 4 ticks between updates, that there will be a maximum of +- 48 items
-- if no stack size is less than double that number (96), only 1 slot is needed
-- if no stack size is less than that number (48) then 2 slots are needed

-- possibly have different internal prototypes for the different stack size min and max, then just overlay the normal container sprite as the combinator sprite
-- i like this idea :) especially for similarly sized entities with different internal maximum storages (wood, iron, steel chests). use the container storage needed (start with the biggest if empty), and overlay the proper sprite on top
-- then whneever you insert an item just check it against the proper container size to see if it is getting full

local container_sizes = {}

for p, prototype in pairs(data.raw["container"]) do
  if p:sub(0, 9) ~= "efficient" and not blacklisted(p, prototype) then

    log("Creating container for ".. p)

    if not prototype.selection_box then
      log("ERROR: container has no selection_box")
      goto endof
    end

    local size = math.abs(prototype.selection_box[1][1]) + math.abs(prototype.selection_box[2][1])

    container_sizes[size] = container_sizes[size] and container_sizes[size] + 1 or 1

    -- If the placeable_by item exists
    if data.raw.item[p] ~= nil then
      -- TODO upgrade case (upgrading wood to iron, etc)
      data:extend{
        {
          name = "efficient-" .. p .. "-combinator",
          subgroup = "storage",
          localised_name = {"entity-name.combinator", {"entity-name." .. p}},
          localised_description = {"entity-description." .. p},
          type = "constant-combinator",
          circuit_wire_connection_points = {prototype.circuit_wire_connection_point, prototype.circuit_wire_connection_point, prototype.circuit_wire_connection_point, prototype.circuit_wire_connection_point},
          circuit_wire_max_distance = prototype.circuit_wire_max_distance,
          collision_box = prototype.collision_box,
          selection_box = prototype.selection_box,
          max_health = prototype.max_health,
          flags = {"placeable-neutral", "player-creation", "not-flammable", "not-rotatable", "hide-alt-info"},
          icon = prototype.icon or nil,
          icon_size = prototype.icon_size or nil,
          icons = prototype.icons,
          icon_mipmaps = prototype.icon_mipmaps or nil,
          item_slot_count = 1,
          collision_mask = prototype.collision_mask,
          remove_decoratives = "true",
          sprites = prototype.picture, -- TODO figure out sprite placement for the ciruit wires
          activity_led_sprites = nothing, -- TODO add the circuit connection sprite to the containers (based on setting?)
          activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
          selection_priority = prototype.selection_priority and prototype.selection_priority + 1 or 51,
          placeable_by = {item = p, count = 1},
          minable = {mining_time = prototype.minable.mining_time}
        }
      }
    end

    ::endof::
  end
end

-- TODO create containers based on the sizes
for size, count in pairs(container_sizes) do
  data:extend{
    {
      type = "container",
      name = "efficient-container-size-" .. math.ceil(size),
      selection_box = {{-size/2, -size/2}, {size/2, size/2}},
      collision_box = {{-size/2, -size/2}, {size/2, size/2}},
      collision_mask = {"item-layer", "object-layer"},
      inventory_size = 2,
      enable_inventory_bar = false,
      inventory_type = "with_filters_and_bar",
      icon = "__efficient-storage__/graphics/entity/nothing.png",
      icon_size = 1,
      icon_mipmaps = nil, 
      picture = nothing,
      scale_info_icons = false,
      flags = {"placeable-neutral", "not-flammable", "not-upgradable"},
      placeable_by = {item = "inventory-shrinker", count = 0}
    }
  }
end

data:extend{ -- TODO selection tool to upgrade and downgrade containers
  {
    type = "selection-tool",
    name = "inventory-shrinker",
    selection_mode = {
      "buildable-type",
      "same-force",
      "entity-with-force"
    },
    alt_selection_mode = {
      "buildable-type",
      "same-force",
      "entity-with-force"
    },
    selection_color = {0, 0.8, 0, 1},
    alt_selection_color = {0, 0.8, 0.8, 1},
    reverse_selection_color = {1, 0, 0, 1},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    stack_size = 1,
    icon = "__efficient-storage__/graphics/icon/storage-unit.png",
    icon_size = 64,
    icon_mipmaps = 4,
  }
}


-- TODO

-- new image for selection tool
-- get localization working properly
-- fix not being able to manually remove units    DONE
-- check if biters can destroy units              DONE
-- mod compatability testing
-- MULTI ITEM STORAGE
-- fix bug with invalid storage (weird)
-- benchmark mod compared to normal storage
-- find beta testers
-- fix not being able to deconstruct storage units
-- check if robots can place/remove
-- fix containers not making smoke when upgrade planner is used
-- loader functionality