local my_utility = require("my_utility/my_utility");

local menu_elements_inferno = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_inferno_base")),
   
    inferno_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "inferno_mode")),
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "inferno_keybind")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hits_inferno_base")),

    min_hits              = slider_int:new(1, 20, 6, get_hash(my_utility.plugin_label .. "min_hits_to_cast_inferno_base")),
    
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_inferno_base")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.40, get_hash(my_utility.plugin_label .. "min_percentage_hits_inferno_base")),
    soft_score            = slider_float:new(2.0, 15.0, 6.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_inferno_base_soft")),
}

local function menu()
    
    if menu_elements_inferno.tree_tab:push("Inferno") then
        menu_elements_inferno.main_boolean:render("Enable Spell", "");

        local options =  {"Auto", "Keybind"};
        menu_elements_inferno.inferno_mode:render("Mode", options, "");

        menu_elements_inferno.keybind:render("Keybind", "");
        menu_elements_inferno.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

        menu_elements_inferno.min_hits:render("Min Hits", "");

        menu_elements_inferno.allow_percentage_hits:render("Allow Percentage Hits", "");
        if menu_elements_inferno.allow_percentage_hits:get() then
            menu_elements_inferno.min_percentage_hits:render("Min Percentage Hits", "", 1);
            menu_elements_inferno.soft_score:render("Soft Score", "", 1);
        end       

        menu_elements_inferno.tree_tab:pop();
    end
end

local my_target_selector = require("my_utility/my_target_selector");

local spell_id_inferno = 294198;
local spell_radius = 2.0
local spell_max_range = 6.0

local next_time_allowed_cast = 0.0;
local function logics(entity_list, target_selector_data, best_target)

    local menu_boolean = menu_elements_inferno.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_inferno);
                
    if not is_logic_allowed then
        return false;
    end;

    local player_position = get_player_position()
    local keybind_used = menu_elements_inferno.keybind:get_state();
    local inferno_mode = menu_elements_inferno.inferno_mode:get();
    if inferno_mode == 1 then
        if  keybind_used == 0 then   
            return false;
        end;
    end;

    local keybind_ignore_hits = menu_elements_inferno.keybind_ignore_hits:get();
    
	    ---@type boolean
        local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("keybind_used " .. keybind_used)
	
    
    local is_percentage_hits_allowed = menu_elements_inferno.allow_percentage_hits:get();
    local min_percentage = menu_elements_inferno.min_percentage_hits:get();
    if not is_percentage_hits_allowed then
        min_percentage = 0.0;
    end

    local min_hits_menu = menu_elements_inferno.min_hits:get();

    local spell_range = 6.0
	local spell_radius = 2.0
	local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)
    if not area_data.main_target then
        return false;
    end

    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage);

    if not is_area_valid and not keybind_can_skip  then
        return false;
    end

    if not area_data.main_target:is_enemy() then
        return false;
    end

    local constains_relevant = false;
    for _, victim in ipairs(area_data.victim_list) do
        if victim:is_elite() or victim:is_champion() or victim:is_boss() then
            constains_relevant = true;
            break;
        end
    end

    if not constains_relevant and area_data.score < menu_elements_inferno.soft_score:get() and not keybind_can_skip  then
        return false;
    end

    local cast_position = area_data.main_target:get_position();
    local cast_position_distance_sqr = cast_position:squared_dist_to_ignore_z(player_position);
    if cast_position_distance_sqr < 2.0 and not keybind_can_skip  then
        return false;
    end

    cast_spell.position(spell_id_inferno, cast_position, 0.3);
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.4;
        
    console.print("Sorcerer Plugin, Casted Inferno");
    return true;

end


    
    

return 
{
    menu = menu,
    logics = logics,   
}