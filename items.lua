SiftingMeshes = {}

local function register_sifting_mesh(name, object)
    minetest.register_craftitem(name, {
    	 description = object.description,
         inventory_image = object.inventory_image,
         durability = object.durability or 0,
         
         groups = { mesh = 1 },
    })
    SiftingMeshes[name] = object
end

minetest.register_craftitem("testing:tin_stick", {
	description = "Tin Stick",
	inventory_image = "testing_tin_stick.png",
	durability = 1,
})
minetest.register_craftitem("testing:stone_grit", {
	description = "Stone Grit",
	inventory_image = "testing_stone_grit.png",
})

register_sifting_mesh("testing:string_mesh", {
	description = "String Mesh",
	inventory_image = "testing_string_mesh.png",
	durability = 1,
})
register_sifting_mesh("testing:tin_mesh", {
	description = "Tin Mesh",
	inventory_image = "testing_tin_mesh.png",
	durability = 3,
})

minetest.register_craft({
    output = "testing:tin_stick 4",
    recipe = {
        { "default:tin_ingot" },
    },
})

minetest.register_craft({
    output = "testing:string_mesh",
    recipe = {
        { "farming:string", "farming:string" },
        { "farming:string", "farming:string" },
    },
})

if (testing:loaded_mod("animalia")) then
    minetest.register_craft({
        output = "testing:string_mesh",
        recipe = {
            { "animalia:feather", "animalia:feather", "animalia:feather" },
            { "animalia:feather", "animalia:feather", "animalia:feather" },
            { "animalia:feather", "animalia:feather", "animalia:feather" },
        },
    })
end

minetest.register_craft({
    output = "testing:tin_mesh",
    recipe = {
        { "testing:tin_stick", "testing:tin_stick", "testing:tin_stick" },
    },
})

minetest.register_craft({
    output = "default:stone",
    recipe = {
        { "testing:stone_grit", "testing:stone_grit", "testing:stone_grit" },
        { "testing:stone_grit", "testing:stone_grit", "testing:stone_grit" },
        { "testing:stone_grit", "testing:stone_grit", "testing:stone_grit" },
    },
})