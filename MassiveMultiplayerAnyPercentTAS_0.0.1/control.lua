-- Define the number of characters to create
local NUM_CHARACTERS = 20

-- Store references to the created characters
local characters = {}

local have_initted = false

-- Function to create characters when game starts
function do_init()
    local nt = game.json_to_table("[1, 2, 3]")

    local surface = game.surfaces["nauvis"]

    for i = 1, NUM_CHARACTERS do
        local character = surface.create_entity({
            name = "character",
            position = {
                x = 5.0,
                y = i,
            },
            force = "player"
        })
        table.insert(characters, character)
    end
end

-- Function to order characters to move
function on_tick_handler()
    if not have_initted then
        do_init()
        have_initted = true
    end
    for _, character in pairs(characters) do
        if character and character.valid then
            character.walking_state = {walking = true, direction = defines.direction.north}
        end
    end
end

script.on_event(defines.events.on_tick, on_tick_handler)
