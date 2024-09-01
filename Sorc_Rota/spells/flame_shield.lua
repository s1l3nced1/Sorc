local my_utility = require("my_utility/my_utility");

local menu_elements_sorc_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_flame_shield")),
    hp_usage_shield       = slider_float:new(0.0, 1.0, 0.30, get_hash(my_utility.plugin_label .. "%_in_which_flame_shield_will_cast")),
    cast_when_ice_armor_down = checkbox:new(true, get_hash(my_utility.plugin_label .. "cast_when_ice_armor_down"))
}

local function menu()
    if menu_elements_sorc_base.tree_tab:push("Flame Shield") then
        menu_elements_sorc_base.main_boolean:render("Enable Spell", "")

        if menu_elements_sorc_base.main_boolean:get() then
            menu_elements_sorc_base.hp_usage_shield:render("Min cast HP Percent", "", 2)
            menu_elements_sorc_base.cast_when_ice_armor_down:render("Cast when Ice Armor is down", "")
        end

        menu_elements_sorc_base.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;
local spell_id_flame_shield = 167341

local function is_ice_armor_active()
    local local_player = get_local_player()
    local buff_name_check = "Sorcerer_IceArmor"

    if not local_player then return false end

    local buffs = local_player:get_buffs()
    if not buffs then return false end

    for _, buff in ipairs(buffs) do
        if buff:name() == buff_name_check then
            return true
        end
    end
    return false
end

local function logics()
    local menu_boolean = menu_elements_sorc_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean,
                next_time_allowed_cast,
                spell_id_flame_shield);

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local player_current_health = local_player:get_current_health();
    local player_max_health = local_player:get_max_health();
    local health_percentage = player_current_health / player_max_health;
    local menu_min_percentage = menu_elements_sorc_base.hp_usage_shield:get();

    local should_cast_flame_shield = health_percentage <= menu_min_percentage or menu_elements_sorc_base.hp_usage_shield:get() >= 1.0

    if menu_elements_sorc_base.cast_when_ice_armor_down:get() then
        should_cast_flame_shield = should_cast_flame_shield or not is_ice_armor_active()
    end

    if should_cast_flame_shield then
        if cast_spell.self(spell_id_flame_shield, 0.0) then
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.1;
            return true;
        end;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}