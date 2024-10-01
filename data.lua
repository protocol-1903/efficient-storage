data:extend{ -- TODO selection tool to upgrade and downgrade containers
  {
    type = "selection-tool",
    name = "container-shrinker",
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
    icons = {
      {
        icon = data.raw.item["steel-chest"].icon,
        icon_size = 64,
        scale = 0.9,
        shift = {5, 6}
      },
      {
        icon = data.raw.item["steel-chest"].icon,
        icon_size = 64,
        scale = 0.4,
        shift = {-10, 24}
      },
      {
        icon = "__efficient-storage__/graphics/icon/icon.png",
        icon_size = 64,
        scale = 1.1,
        shift = {6.4, 6.4}
      },
    },
    entity_type_filters = { "container" },
    alt_entity_type_filters = { "container" },
    reverse_entity_type_filters = { "constant-combinator" },
    alt_reverse_entity_type_filters = { "constant-combinator" },
    flags = { "spawnable", "only-in-cursor", "not-stackable", "hidden" }
  },
  {
    type = "shortcut",
    name = "give-container-shrinker",
    action = "spawn-item",
    associated_control_input = "give-container-shrinker",
    item_to_spawn = "container-shrinker",
    icon = {
      layers = {
        {
          filename = data.raw.item["steel-chest"].icon,
          width = 64,
          height = 64,
          scale = 0.9,
          shift = {-32-5, -32-6}
        },
        {
          filename = data.raw.item["steel-chest"].icon,
          width = 64,
          height = 64,
          scale = 0.4,
          shift = {-32-10, -32-24}
        },
        {
          filename = "__efficient-storage__/graphics/icon/icon.png",
          width = 64,
          height = 64,
          scale = 1.1,
          shift = {-32-6.4, -32-6.4}
        },
      },
    }
  },
  {
    type = "custom-input",
    name = "give-container-shrinker",
    key_sequence = "ALT + S",
    action = "spawn-item",
    item_to_spawn = "container-shrinker"
  }
}