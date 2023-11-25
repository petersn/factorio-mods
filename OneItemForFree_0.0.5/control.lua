function show_item_picker_gui(player)
    if not player.gui.center.super_chest_frame then
        local frame = player.gui.center.add {
            type = "frame",
            name = "super_chest_frame",
            caption = "Select an item to be supplied infinitely by your limitless chest",
            direction = "vertical"
        }
        frame.add {
            type = "choose-elem-button",
            name = "super_chest_selection",
            elem_type = "item",
            elem_filters = { { filter = "name", name = "super-chest", invert = true } },
            tags = { super_chest_selection = true }
        }
    end
end

script.on_event(defines.events.on_gui_elem_changed, function(event)
    local player = game.players[event.player_index]
    local changed_element = event.element

    if changed_element.tags.super_chest_selection then
        local chosen_item = changed_element.elem_value  -- Get the chosen item name
        if chosen_item then
            global.player_choices[player.index] = chosen_item

            player.print("You have chosen " .. chosen_item .. " to be supplied infinitely by your limitless chest!")

            -- Close and destroy the GUI after an item is selected
            changed_element.parent.destroy()
        end
    end
end)

local function give_super_chest(player)
    player.get_main_inventory().insert { name = "super-chest", count = 1 }
    show_item_picker_gui(player)
end

script.on_event(defines.events.on_player_created, function(event)
    give_super_chest(game.players[event.player_index])
end)

script.on_init(function()
    global.player_choices = {}
    for _, player in pairs(game.players) do
        give_super_chest(player)
    end
end)

function set_filter(chest, chosen_item)
    if not chosen_item then
        return
    end
    local stacks = chest.prototype.get_inventory_size(defines.inventory.chest)
    local stack_size = game.item_prototypes[chosen_item].stack_size
    chest.infinity_container_filters = {
        {
            name = chosen_item,
            count = stacks * stack_size,
            mode = "exactly",
            index = 1
        }
    }
end

-- Check when the player places a chest, and set the infinite item if relevant
script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    if entity and entity.valid and entity.name == "super-chest" then
        local chosen_item = global.player_choices[event.player_index]
        set_filter(entity, chosen_item)
    end
end)

script.on_configuration_changed(function(data)
    if not (data.mod_changes and data.mod_changes["OneItemForFree"] and data.mod_changes["OneItemForFree"].old_version) then
        return
    end
    if global.super_chest_item_name then
        for _, data in global.super_chest_item_name do
            local chest = data.surface.find_entity("super-chest", data.position)
            if chest then
                set_filter(chest, data.chosen_item)
            end
        end
    end
    global.super_chest_item_name = nil
    global.players_given_super_chest = nil
end)
