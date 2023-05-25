SiftingTable = {}
SiftingIndices = {}
SiftingKeys = {}
local recipeCount = 0;
local function register_sift_item(name, itemStack, itemDurability)
    local object = { stack = itemStack, durability = itemDurability }
    SiftingTable[name] = object
    table.insert(SiftingIndices, object)
    table.insert(SiftingKeys, name)
    
    recipeCount = recipeCount + 1
end

register_sift_item("default:gravel", ItemStack("default:flint"), 2)
register_sift_item("default:sand", ItemStack("testing:stone_grit"), 1)
register_sift_item("default:silver_sand", ItemStack("testing:stone_grit 2"), 1)
register_sift_item("default:desert_sand", ItemStack("testing:stone_grit"), 2)

local function swap_block(position, name)
    local block = minetest:get_node(position)
    
    if block.name == name then
         return
    end
    
    block.name = name
    minetest.swap_node(position, block)
end

minetest.register_node("testing:wooden_pylon", {
    description = "Wooden Pylon",
    tiles = { "default_wood.png" },
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1 },
    
    drawtype = "nodebox",
    paramtype = "light",
    
    node_box = {
        type = "fixed",
        fixed = {
            { -0.05, -0.5, -0.05,  0.05, 0.5, 0.05 },
        },
    },
})

local function sifter_guide_formspec(index)
    local entryCount = recipeCount
    local inputKey = SiftingKeys[index]
    local output = SiftingIndices[index]
    local content = {
        "size[8,8]",
        "label[3.2, 0.2; Sifting Guide]",
         
        "container[1, 1]",
        "item_image_button[1.0,2.5; 1,1;" .. inputKey .. "; input;]",
        "item_image_button[3.6,2.5; 1,1;" .. output.stack:get_name() .. "; output;]",
        "image[2.0,2.5;1.6,1;gui_furnace_arrow_bg.png^[transformR270]",
        "item_image[2.5, 1.8; 0.8, 0.8;testing:tin_mesh]",
        
        "label[1.6, 4.5; Minimum durability: " .. output.durability .. "]",
        "button[2,5.5;1,1;previous;<<]",
        "button[3,5.5;1,1;next;>>]",
        
        "label[1.75, 5; Index " .. index .." of " .. entryCount .. " entries]",
        "container_end[]",
    }
    
    return table.concat(content, "")
end
local function sifter_after_place(meta)
    meta:set_string("formspec", sifter_guide_formspec(1))
end
local function sifter_receive_fields(position, formName, fields, sender)
    local meta = minetest.get_meta(position)
    local index = meta:get_int("index")
    if index == 0 then
         index = 1
    end
    
    if fields.previous == "<<" then
         index = math.max(index - 1, 1)
    elseif fields.next == ">>" then
         index = math.min(index + 1, recipeCount)
    end
    
    meta:set_int("index", index)
    meta:set_string("formspec", sifter_guide_formspec(index))
end

local function register_sifter(name, object)
    minetest.register_node(name, {
        description = object.description,
        tiles = object.tiles,
        groups = object.groups,
        
        is_ground_content = false,
        drawtype = "nodebox",
        paramtype = "light",
    
        node_box = {
            type = "fixed",
            fixed = {
                { -0.5, -0.5, -0.5,  -0.4, 0.5, -0.4 },
                { 0.4, -0.5, -0.5,  0.5, 0.5, -0.4 },
                { 0.4, -0.5, 0.4,  0.5, 0.5, 0.5 },
                { -0.5, -0.5, 0.4,  -0.4, 0.5, 0.5 },
            
                { -0.5, 0.4, -0.5,  0.5, 0.5, -0.4 },
                { 0.4, 0.4, -0.5,  0.5, 0.5, 0.5 },
                { 0.5, 0.4, 0.4,  -0.5, 0.5, 0.5 },
                { -0.4, 0.4, 0.4,  -0.5, 0.5, -0.5 },
            },
        },
        selection_box = { -0.5, -0.5, -0.5,  0.5, 0.5, 0.5 },
        
        on_punch = function(position, node, puncher, pointed)
             local stack = puncher:get_wielded_item()
         
             for key, value in pairs(SiftingMeshes) do
                 if stack:get_name() == key then
                     swap_block(position, name .. "_with_" .. string.gsub(key, "testing:", ""))
                     puncher:set_wielded_item(ItemStack(stack:get_name() .. " " .. (stack:get_count() - 1)))
                     
                     local meta = minetest.get_meta(position)
                     meta:set_string("infotext", object.description .. " with " .. SiftingMeshes[key].description .. "\n" .. "Base durability: " .. object.durability .. "\n" .. "Mesh durability: " .. SiftingMeshes[key].durability)
                     sifter_after_place(meta)
                     
                     break;
                 end
             end
             return stack;
        end,
        
        after_place_node = function(position, placer)
             local meta = minetest.get_meta(position)
             meta:set_string("infotext", object.description .. "\n" .. "Base durability: " .. object.durability)
             sifter_after_place(meta)
        end,
        on_receive_fields = sifter_receive_fields,
    })
    
    for key, value in pairs(SiftingMeshes) do
        minetest.register_node(name .. "_with_" .. string.gsub(key, "testing:", ""), {
	        tiles = object.tiles,
            groups = object.groups,
    
            drop = {
             	items = {
    	              {items = { name }},
                      {items = { key }},
                 },
            },
    
            is_ground_content = false,
            drawtype = "nodebox",
            paramtype = "light",
    
            node_box = {
             	type = "fixed",
                 fixed = {
                    { -0.5, -0.5, -0.5,  -0.4, 0.5, -0.4 },
                    { 0.4, -0.5, -0.5,  0.5, 0.5, -0.4 },
                    { 0.4, -0.5, 0.4,  0.5, 0.5, 0.5 },
                    { -0.5, -0.5, 0.4,  -0.4, 0.5, 0.5 },
            
                    { -0.5, 0.4, -0.5,  0.5, 0.5, -0.4 },
                    { 0.4, 0.4, -0.5,  0.5, 0.5, 0.5 },
                    { 0.5, 0.4, 0.4,  -0.5, 0.5, 0.5 },
                    { -0.4, 0.4, 0.4,  -0.5, 0.5, -0.5 },
            
                    { -0.5, 0.42, -0.5,  0.5, 0.44, 0.5 },
                 },
             },
             selection_box = { -0.5, -0.5, -0.5,  0.5, 0.5, 0.5 },
    
             on_punch = function(pos, node, puncher, pointed)
                    local stack = puncher:get_wielded_item()
                    local inventory = puncher:get_inventory()   
                    local meta = minetest.get_meta(pos)
                    local durable = nil
    
                    for key2, value2 in pairs(SiftingTable) do
                         if stack:get_name() == key2 then
                               local sifting = SiftingTable[key2]
                               if sifting.durability <= object.durability + SiftingMeshes[key].durability then
                                    inventory:add_item("main", sifting.stack)
                                    puncher:set_wielded_item(ItemStack(stack:get_name() .. " " .. (stack:get_count() - sifting.stack:get_count())))
                               else
                                    durable = sifting
                               end
                               
                               break
                          end
                     end
                     
                     if durable ~= nil then
                          local clickerName = clicker:get_player_name()
                          minetest.chat_send_player(clickerName, "The selected item's durability " .. "(" .. durable.durability .. ")" .. " is greater than the sifter's total durability " .. "(" .. (object.durability + SiftingMeshes[key].durability) .. ").")
                     end
                     
                     return stack;
             end,
             on_receive_fields = sifter_receive_fields,
         })
     end
end


register_sifter("testing:wooden_sifter", {
	description = "Wooden Sifter",
    tiles = { "default_wood.png" },
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1 },
    
    durability = 1,
}) 

register_sifter("testing:tin_sifter", {
	description = "Tin Sifter",
    tiles = { "default_tin_block.png" },
    groups = { cracky = 2 },
    
    durability = 3,
})

minetest.register_craft({
    output = "testing:wooden_pylon",
    recipe = {
        { "group:stick" },
        { "group:stick" },
        { "group:stick" },
    },
})

minetest.register_craft({
    output = "testing:wooden_sifter",
    recipe = {
        { "group:stick", "group:wood", "group:stick" },
        { "group:wood",                "",      "group:wood" },
        { "group:stick", "group:wood", "group:stick" },
    },
})

minetest.register_craft({
    output = "testing:tin_sifter",
    recipe = {
        { "testing:tin_stick", "default:tin_ingot", "testing:tin_stick" },
        { "default:tin_ingot",        "",           "default:tin_ingot" },
        { "testing:tin_stick", "default:tin_ingot", "testing:tin_stick" },
    },
})