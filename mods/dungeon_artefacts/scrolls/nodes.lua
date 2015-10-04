

-- temporary water source, use param2 when playing it to determine duration
minetest.register_node("scrolls:temporary_water", {
	description = "Temporary Water Source",
	inventory_image = minetest.inventorycube("default_river_water.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_river_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		{
			name = "default_river_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	alpha = 160,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "scrolls:flowing_temporary_water",
    liquid_alternative_source = "scrolls:temporary_water",
	liquid_viscosity = 1,
	liquid_renewable = false,
	liquid_range = 5,
	post_effect_color = {a=120, r=30, g=76, b=90},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},

    on_construct = function(pos)
        local node = minetest.get_node(pos)
        if node.param2 < 1 then
            node.param2 = 5
            minetest.swap_node(pos, node)
        end
        minetest.get_node_timer(pos):start(3)
        minetest.log("action", "placed temporaty water with param2: " .. node.param2)
    end,

    on_timer = function(pos, elapsed)
        minetest.log("action", "timer run!")
        local node = minetest.get_node(pos)
        node.param2 = node.param2 - elapsed
        minetest.log("action", "temporaty water with param2: " .. node.param2)
        if node.param2 < 0 then
            minetest.log("action", "water removed")
            minetest.set_node(pos, {name = "air"})
            return false
        else
            minetest.swap_node(pos, node)
            return true
        end

    end,
})

minetest.register_node("scrolls:flowing_temporary_water", {
	description = "Flowing Temporary Water",
	inventory_image = minetest.inventorycube("default_river_water.png"),
	drawtype = "flowingliquid",
	tiles = {"default_river_water.png"},
	special_tiles = {
		{
			name = "default_river_water_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
		{
			name = "default_river_water_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
	},
	alpha = 160,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "scrolls:flowing_temporary_water",
    liquid_alternative_source = "scrolls:temporary_water",
	liquid_viscosity = 1,
	liquid_renewable = false,
	liquid_range = 5,
	post_effect_color = {a=120, r=30, g=76, b=90},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})