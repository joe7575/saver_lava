-- derived from bucket/init.lua
local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

local function on_place(itemstack, user, pointed_thing)
	-- Must be pointing to node
	if pointed_thing.type ~= "node" then
		return
	end

	local node = minetest.get_node_or_nil(pointed_thing.under)
	local ndef = node and minetest.registered_nodes[node.name]

	-- Call on_rightclick if the pointed node defines it
	if ndef and ndef.on_rightclick and
			not (user and user:is_player() and
			user:get_player_control().sneak) then
		return ndef.on_rightclick(
			pointed_thing.under,
			node, user,
			itemstack)
	end

	local lpos

	-- Check if pointing to a buildable node
	if ndef and ndef.buildable_to then
		-- buildable; replace the node
		lpos = pointed_thing.under
	else
		-- not buildable to; place the liquid above
		-- check if the node above can be replaced

		lpos = pointed_thing.above
		node = minetest.get_node_or_nil(lpos)
		local above_ndef = node and minetest.registered_nodes[node.name]

		if not above_ndef or not above_ndef.buildable_to then
			-- do not remove the bucket with the liquid
			return itemstack
		end
	end

	if check_protection(lpos, user
			and user:get_player_name()
			or "", "place default:lava_source") then
		return
	end

	-------------------------------- Start Modification
	if lpos.y > 0 then
		minetest.set_node(lpos, {name = "safer_lava:lava"})
	else
		minetest.set_node(lpos, {name = "default:lava_source", param2 = 1})
	end
	-------------------------------- End Modification
	return ItemStack("bucket:bucket_empty")
end


minetest.override_item("bucket:bucket_lava", {
		on_place = on_place,
})

minetest.register_node("safer_lava:lava", {
	description = "Lava",
	drawtype = "liquid",
	tiles = {
		{
			name = "default_lava_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
		{
			name = "default_lava_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	paramtype = "light",
	light_source = default.LIGHT_MAX - 1,
	is_ground_content = false,
	drop = "",
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {crumbly = 3, falling_node = 1, not_in_creative_inventory = 1},
})
