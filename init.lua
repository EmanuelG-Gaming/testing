--require "sifter"
testing = {}

-- Helper functions
function testing:loaded_mod(name)
    local loaded = minetest.get_modpath(name) ~= nil
    return loaded
end

-- File paths
local path = minetest.get_modpath("testing") .. "/"
dofile(path.."items.lua")
dofile(path.."sifter.lua")


UnderConstruction = {}

-- Also known as a dialog
function UnderConstruction.get_form_specification(name)
    local notice = "This block is under construction."
    local content = {
	   "formspec_version[4]",
       "size[5, 2]",
       "label[0.375, 0.6;", name, "]",
	   "label[0.375, 1.4;", minetest.formspec_escape(notice), "]",
	}
		  
    return table.concat(content, "")
end
     
minetest.register_node("testing:wooden_crate", {
    description = "Wooden Crate",
    paramtype = "light",
    paramtype2 = "facedir",
    
    tiles = { "testing_wooden_crate.png" },
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1 },
    
    -- Actually show the disclaimer
    after_place_node = function(position, placer)
         local meta = minetest.get_meta(position)
         meta:set_string("formspec", UnderConstruction.get_form_specification("Wooden crate"))
    end
})


minetest.register_craft({
    output = "testing:wooden_crate",
    recipe = {
        { "group:wood", "group:wood" },
        { "group:wood", "group:wood" },
    },
})

minetest.register_node("testing:wooden_table", {
    description = "Wooden Table",
    drawtype = "mesh",
    mesh = "table.obj",
    paramtype = "light",
    paramtype2 = "facedir",
    
    tiles = { "default_wood.png" },
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1 },
})


minetest.register_craft({
    output = "testing:wooden_table",
    recipe = {
        { "group:wood", "group:wood", "group:wood" },
        { "group:wood", "group:wood", "group:wood" },
        { "group:wood",      "",      "group:wood" },
    },
})