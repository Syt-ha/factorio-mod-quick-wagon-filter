local function applyFilterToInventory(outputInventory, filterItem)
    for i = 1, #outputInventory do
        outputInventory.set_filter(i, filterItem)
    end
end

local function applyFilterToEntireTrain(initialWagon, filterItem)
    local connectedWagons = initialWagon.train and initialWagon.train.cargo_wagons

    if connectedWagons then
        for i = 1, #connectedWagons do
            applyFilterToInventory(connectedWagons[i].get_output_inventory(), filterItem)
        end
    end
end

-- Create GUI
local function wagonFilterCreateWindow(player)
    local gui = player.gui.relative
    local anchor = {gui=defines.relative_gui_type.container_gui, position=defines.relative_gui_position.right}

    -- New frame
    local frame = gui.add{
        type = "frame",
        name = "quick-wagon-filter-frame",
        caption = {"quick-wagon-filter.frame-title"},
        direction = "vertical",
        anchor = anchor,
    }

    -- Item filter picker
    frame.add{
        type = "choose-elem-button",
        name = "quick-wagon-filter-selector",
        elem_type = "item",
        caption = {"quick-wagon-filter.select-item"},
    }

    -- Validation button for "this wagon"
    frame.add{
        type = "button",
        name = "quick-wagon-filter-apply",
        caption = {"quick-wagon-filter.apply-one"},
    }

    -- Validation button for the whole train
    frame.add{
        type = "button",
        name = "quick-wagon-filter-apply-all",
        caption = {"quick-wagon-filter.apply-all"},
    }
end

script.on_event(defines.events.on_gui_click, function(event)
    local element = event.element
    local player = game.players[event.player_index]

    if element.name == "quick-wagon-filter-apply" or element.name == "quick-wagon-filter-apply-all" then
        local selector = element.parent["quick-wagon-filter-selector"]
        local outputInventory = player.opened.get_output_inventory()

        if element.name == "quick-wagon-filter-apply" then
            applyFilterToInventory(outputInventory, selector.elem_value)
        end
        if element.name == "quick-wagon-filter-apply-all" then
            applyFilterToEntireTrain(player.opened, selector.elem_value)
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.players[event.player_index]
    local frame = player.gui.relative["quick-wagon-filter-frame"]
    if frame then
        frame.destroy()
    end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.players[event.player_index]

    if event.entity and event.entity.valid and event.entity.type == "cargo-wagon" then
        wagonFilterCreateWindow(player)
    end
end)