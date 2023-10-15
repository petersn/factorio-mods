
global.players_given_super_chest = {}
global.player_choices = {}
global.super_chest_item_name = {}  -- Table to keep track of the item each chest is supplying infinitely

-- -- Give player a super chest on game start
-- script.on_event(defines.events.on_player_respawned, function(event)
--     local player = game.players[event.player_index]
--     player.insert{name="super-chest", count=1}
--     -- local inv = player.get_main_inventory()
--     -- inv.insert{name="super-chest", count=1}
--     -- Tell the player about the chest
--     player.print("You have been given a super chest!")
-- end)

-- -- Check when a chest is opened
-- script.on_event(defines.events.on_gui_opened, function(event)
--     local player = game.players[event.player_index]
--     local entity = event.entity
--     if entity and entity.name == "super-chest" then
--         -- If there's an item inside and it's not tracked, set it as the infinite item
--         if not global.super_chest_item_name[entity.unit_number] then
--             show_item_picker_gui(event.player_index)
--         end
--     end
-- end)

function show_item_picker_gui(player_index)
    local player = game.players[player_index]

    if not player.gui.center.super_chest_frame then
        -- Create a main GUI frame for our item picker
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

-- function close_item_picker_gui(player_index)
--     local player = game.players[player_index]
--     if player.gui.center.super_chest_frame then
--         player.gui.center.super_chest_frame.destroy()
--     end
-- end

-- script.on_event(defines.events.on_gui_closed, function(event)
--     close_item_picker_gui(event.player_index)
-- end)

-- Replenish the item
script.on_event(defines.events.on_tick, function(event)
    -- if event.tick % 5 == 0 or event.tick < 60 then
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
    -- end
end)

-- function player_mined_entity(event)
--     game.players[event.player_index].print("You mined!")
-- end

-- -- Function to call if the player mines something.
-- function player_mined_item(event)
--     -- Send a message to the player telling them about the item stack.
--     game.players[event.player_index].print("You mined " .. event.item_stack.name .. " x" .. event.item_stack.count)
-- end

-- -- Function to call if the player fast-transfers items.
-- function player_fast_transferred(event)
--     -- Send a message to the player telling them about the item stack.
--     game.players[event.player_index].print("You fast transferred " .. event.item_stack.name .. " x" .. event.item_stack.count)
-- end

-- script.on_event(defines.events.on_player_mined_entity, player_mined_entity)
-- script.on_event(defines.events.on_player_mined_item, player_mined_item)
-- script.on_event(defines.events.on_player_fast_transferred, player_fast_transferred)
