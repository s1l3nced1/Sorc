local my_utility = require("my_utility/my_utility");

local menu_elements_sorc_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_ice_armor")),
    hp_usage_shield       = slider_float:new(0.0, 1.0, 0.30, get_hash(my_utility.plugin_label .. "%_in_which_shield_will_cast"))
}

local function menu()
    if menu_elements_sorc_base.tree_tab:push("Ice Armor") then
        menu_elements_sorc_base.main_boolean:render("Enable Spell", "")

       if menu_elements_sorc_base.main_boolean:get() then
        menu_elements_sorc_base.hp_usage_shield:render("Min cast HP Percent", "", 2)
       end

       menu_elements_sorc_base.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;
local spell_id_ice_armor = 297039

local function is_flame_shield_active()
    local local_player = get_local_player()
    local buff_name_check = "Sorcerer_FlameShield"

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
                spell_id_ice_armor);

    if not is_logic_allowed then
        return false;
    end;

    -- Check if Flame Shield is active
    if is_flame_shield_active() then
        return true;
    end

    local local_player = get_local_player();
    local player_current_health = local_player:get_current_health();
    local player_max_health = local_player:get_max_health();
    local health_percentabe = player_current_health / player_max_health;
    local menu_min_percentage = menu_elements_sorc_base.hp_usage_shield:get();

    if health_percentabe > menu_min_percentage and menu_elements_sorc_base.hp_usage_shield:get() < 1.0 then
        return false;
    end;

    if cast_spell.self(spell_id_ice_armor, 0.0) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.1;
        return true;
    end;

    return false;
end

return
{
    menu = menu,
    logics = logics,
}