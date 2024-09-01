local my_utility = require("my_utility/my_utility");

local menu_elements_spear_base = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_lightning_spear")),
}

local function menu()
    
    if menu_elements_spear_base.tree_tab:push("Lightning Spear") then
        menu_elements_spear_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_spear_base.tree_tab:pop()
    end
end

local spell_id_spear = 292074
local next_time_allowed_cast = 0.0;
local function logics(target)

    local menu_boolean = menu_elements_spear_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_spear);

    if not is_logic_allowed then
    return false;
    end;

    local target_position = target:get_position();

    cast_spell.position(spell_id_spear, target_position, 0.02)
    local current_time = get_time_since_inject();
    next_time_allowed_cast = current_time + 0.02;
        
    console.print("Sorcerer Plugin, Casted Spear");
    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}