local my_utility = require("my_utility/my_utility")

local menu_elements_teleport_ench =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "base_teleport_ench_base_main_bool")),
    cast_on_self        = checkbox:new(false, get_hash(my_utility.plugin_label .. "base_teleport_ench_cast_on_self_bool")),
    short_range_tp      = checkbox:new(false, get_hash(my_utility.plugin_label .. "base_teleport_ench_short_range_tp_bool")), -- New checkbox
}

local function menu()
    
    if menu_elements_teleport_ench.tree_tab:push("teleport_ench") then
        menu_elements_teleport_ench.main_boolean:render("Enable Spell", "")
        menu_elements_teleport_ench.cast_on_self:render("Cast on Spot", "Casts Teleport at where you stand")
        menu_elements_teleport_ench.short_range_tp:render("Short Range Tele", "Stop teleport to random hill ufak")
        menu_elements_teleport_ench.tree_tab:pop()
    end
end

local spell_id_teleport_ench = 959728

local spell_data_teleport_ench = spell_data:new(
    5.0,                        -- radius
    8.0,                        -- range
    1.0,                        -- cast_delay
    0.7,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_teleport_ench,     -- spell_id
    spell_geometry.circular,    -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local next_time_allowed_cast = 0.0
local_player = get_local_player()

local function logics(target)
    local_player = get_local_player()
    local menu_boolean = menu_elements_teleport_ench.main_boolean:get()
    local cast_on_self = menu_elements_teleport_ench.cast_on_self:get()
    local short_range_tp = menu_elements_teleport_ench.short_range_tp:get()

    -- Short Range Teleport Range
    if short_range_tp then
        spell_data_teleport_ench.range = 5.0
    else
        spell_data_teleport_ench.range = 8.0
    end
    

    
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_teleport_ench)

    local current_orb_mode = orbwalker.get_orb_mode()

    if not menu_boolean then
        return false
    end

    if current_orb_mode == orb_mode.none then
        return false
    end

    if not local_player:is_spell_ready(spell_id_teleport_ench) then
        return false
    end

    if cast_on_self then
        if cast_spell.self(spell_id_teleport_ench, 0.5) then
            local current_time = get_time_since_inject()
            next_time_allowed_cast = current_time + 2.9

            console.print("Casted Teleport Enchantment on Spot")
            return true
        end
    else
        if cast_spell.target(target, spell_data_teleport_ench, false) then
            local current_time = get_time_since_inject()
            next_time_allowed_cast = current_time + 1.0

            console.print("Casted Teleport Enchantment on Target")
            return true
        end
    end
            
    return false
end

return 
{
    menu = menu,
    logics = logics,   
    menu_elements_teleport_ench = menu_elements_teleport_ench,
}
