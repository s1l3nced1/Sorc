local my_utility = require("my_utility/my_utility");

local menu_elements_sorc_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_teleport_base")),
   
    enable_teleport       = checkbox:new(false, get_hash(my_utility.plugin_label .. "enable_teleport_base")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "keybind_ignore_min_hits_base_tp")),
    
    min_hits              = slider_int:new(1, 20, 6, get_hash(my_utility.plugin_label .. "min_hits_to_cast_base_tp")),
    
    soft_score            = slider_float:new(2.0, 15.0, 6.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_soft_core_tp")),
    
    teleport_on_self      = checkbox:new(false, get_hash(my_utility.plugin_label .. "teleport_on_self_base")),
    
    short_range_tele      = checkbox:new(false, get_hash(my_utility.plugin_label .. "short_range_tele_base")),
    
    tele_gtfo             = checkbox:new(false, get_hash(my_utility.plugin_label .. "gtfo"))
}

local function menu()
    if menu_elements_sorc_base.tree_tab:push("Teleport") then
        menu_elements_sorc_base.main_boolean:render("Enable Spell", "");
        menu_elements_sorc_base.teleport_on_self:render("Cast on Spot", "Casts Teleport at where you stand");
        menu_elements_sorc_base.short_range_tele:render("Short Range Tele", "Stop teleport to random hill ufak");
        menu_elements_sorc_base.tele_gtfo:render("Tele Gtfo", "Gtfo at <90hp");
        menu_elements_sorc_base.tree_tab:pop();
    end
end

local my_target_selector = require("my_utility/my_target_selector");

local spell_id_tp = 288106;

local spell_radius = 2.5;
local spell_max_range = 10.0;

local next_time_allowed_cast = 0.0;

local function logics(entity_list, target_selector_data, best_target)
    
    local menu_boolean = menu_elements_sorc_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_tp);
                
    if not is_logic_allowed then
        return false;
    end

    if not local_player:is_spell_ready(spell_id_tp) then
        return false;
    end

    -- Tele Gtfo Logic
    if menu_elements_sorc_base.tele_gtfo:get() then
        local current_health = local_player:get_current_health();
        local max_health = local_player:get_max_health();
        local health_percentage = current_health / max_health;

        if health_percentage < 0.90 then
            local player_position = get_player_position();
            local safe_direction = vec3:new(1, 0, 0); -- Default safe direction
            local safe_distance = 10.0;  -- Distance Adjustments
            local safe_position = player_position + safe_direction * safe_distance;

            -- Adjust safe position height using utility function
            safe_position = utility.set_height_of_valid_position(safe_position);

            cast_spell.position(spell_id_tp, safe_position, 0.3);
            next_time_allowed_cast = get_time_since_inject() + 0.1;
            console.print("Sorcerer Plugin, Casted Teleport due to I need to GTFO");
            return true;
        end
    end

    local player_position = get_player_position();
    local enable_teleport = menu_elements_sorc_base.enable_teleport:get();
    
    -- Short Range Teleport Range
    local adjusted_spell_max_range = spell_max_range;
    if menu_elements_sorc_base.short_range_tele:get() then
        adjusted_spell_max_range = 5.0;
    end

    -- Cast on Spot
    if menu_elements_sorc_base.teleport_on_self:get() then
        cast_spell.self(spell_id_tp, 0.3);  
        next_time_allowed_cast = get_time_since_inject() + 0.4;
        console.print("Sorcerer Plugin, Casted Teleport on Spot");
        return true;
    end

    local keybind_ignore_hits = menu_elements_sorc_base.keybind_ignore_hits:get();
    local keybind_can_skip = keybind_ignore_hits and enable_teleport;

    local min_hits_menu = menu_elements_sorc_base.min_hits:get();

    local area_data = target_selector.get_most_hits_target_circular_area_heavy(player_position, adjusted_spell_max_range, spell_radius)
    if not area_data.main_target then
        return false;
    end

    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list);

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

    if not constains_relevant and area_data.score < menu_elements_sorc_base.soft_score:get() and not keybind_can_skip  then
        return false;
    end

    local cast_position = area_data.main_target:get_position();
    local cast_position_distance_sqr = cast_position:squared_dist_to_ignore_z(player_position);
    if cast_position_distance_sqr < 2.0 and not keybind_can_skip  then
        return false;
    end

    cast_spell.position(spell_id_tp, cast_position, 0.3);
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.4;

    console.print("Sorcerer Plugin, Casted Tp");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}

