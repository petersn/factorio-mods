
script.on_init(function()
    global.players_given_super_chest = {}
    global.player_choices = {}
    global.super_chest_item_name = {}
end)

function show_item_picker_gui(player_index)
    local player = game.players[player_index]

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
            caption = "",
            elem_type = "item",
            elem_filters = {{filter="name", name="super-chest", invert=true}}
        }
    end
end

script.on_event(defines.events.on_gui_elem_changed, function(event)
    local player = game.players[event.player_index]
    local changed_element = event.element

    if changed_element.name == "super_chest_selection" then
        local chosen_item = changed_element.elem_value  -- Get the chosen item name

        if chosen_item then
            global.player_choices[player.index] = chosen_item

            player.print("You have chosen " .. chosen_item .. " to be supplied infinitely by your limitless chest!")

            -- Close and destroy the GUI after an item is selected
            if player.gui.center.super_chest_frame then
                player.gui.center.super_chest_frame.destroy()
            end
        end
    end
end)

-- Check when the player places a chest, and set the infinite item if relevant
script.on_event(defines.events.on_built_entity, function(event)
    local player = game.players[event.player_index]
    local entity = event.created_entity
    if entity and entity.name == "super-chest" then
        local chosen_item = global.player_choices[player.index]
        if chosen_item then
            global.super_chest_item_name[entity.unit_number] = chosen_item
        end
    end
end)

-- Make it so the player can mine super chests, by emptying them on pickup.
script.on_event(defines.events.on_pre_player_mined_item, function(event)
    local entity = event.entity
    if entity and entity.name == "super-chest" then
        local inv = entity.get_inventory(defines.inventory.chest)
        inv.clear()
    end
end)

script.on_event(defines.events.on_tick, function(event)
    -- Try to find any players who haven't been given a super chest, and give them one if relevant.
    for _, player in pairs(game.players) do
        if not global.players_given_super_chest[player.index] then
            local inv = player.get_main_inventory()
            if inv ~= nil then
                -- Check if the player already has a super chest.
                -- FIXME: I shouldn't need to do this check!
                local has_super_chest = false
                for item_name, _ in pairs(inv.get_contents()) do
                    if item_name == "super-chest" then
                        has_super_chest = true
                        break
                    end
                end
                if not has_super_chest then
                    inv.insert{name="super-chest", count=1}
                    global.players_given_super_chest[player.index] = true
                    show_item_picker_gui(player.index)
                end
            end
        end
    end
    for _, surface in pairs(game.surfaces) do
        local chests = surface.find_entities_filtered{name="super-chest"}
        for _, chest in pairs(chests) do
            local item_name = global.super_chest_item_name[chest.unit_number]
            if item_name then
                local inv = chest.get_inventory(defines.inventory.chest)
                local insert_count = inv.get_insertable_count(item_name)
                if insert_count > 0 then
                    inv.insert{name=item_name, count=insert_count}
                end
            end
        end
    end
end)