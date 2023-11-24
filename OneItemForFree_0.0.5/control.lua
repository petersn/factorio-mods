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
            elem_filters = {{filter="name", name="super-chest", invert=true}},
            tags = {super_chest_selection = true}
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

-- Check when the player places a chest, and set the infinite item if relevant
script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    if entity and entity.valid and entity.name == "super-chest" then
        local chosen_item = global.player_choices[event.player_index]
        if chosen_item then
            local stacks = entity.prototype.get_inventory_size(defines.inventory.chest)
            local stack_size = game.item_prototypes[chosen_item].stack_size
            entity.infinity_container_filters = {
                {
                    name = chosen_item,
                    count = stacks * stack_size,
                    mode = "exactly",
                    index = 1
                }
            }
        end
    end
end)
