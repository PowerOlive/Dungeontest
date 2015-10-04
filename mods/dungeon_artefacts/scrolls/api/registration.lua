

scrolls.registered_spells = {}
scrolls.registered_spells_count = 0

-- wrapper for minetest.chat_send_player
-- takes a player object instead of a name as argument
-- if the object is not a player it won'T do anything
function scrolls.chat_if_player(player, message)
    if player.is_player and player:is_player() then
        local name = player:get_player_name()
        minetest.chat_send_player(name, message)
        return name
    end
end

-- Registers a spell and the associated scroll for it, will also register a status
-- if the definition contains one (which will automatically be used for the scroll)
function scrolls.register_spell(name, def)

    scrolls.registered_spells[name] = def;
    scrolls.registered_spells_count = scrolls.registered_spells_count + 1

    -- if definition contains a status, register it
    if def.status then
        local status = def.status
        status.description = status.description or def.description
        status.icon = status.icon or def.particle_image
        statuses.register_status(name, status)

        -- define self casting and casting as status setting functions
        def.on_self_cast = def.on_self_cast or function(caster, pointed_thing)
            statuses.apply_status(caster, {
                name = name,
                duration = (def.status_duration or 10)
            })
    		return true
        end

        def.on_cast = def.on_cast or function(caster, pointed_thing)

            if pointed_thing.type == "object" then
                local target
                if pointed_thing.ref.get_luaentity then
                    target = pointed_thing.ref:get_luaentity()
                else
                    scrolls.chat_if_player(caster, "Doesn't look like the scroll had any effect on it")
                    return false
                end

                statuses.apply_status(target, {
                    name = name,
                    duration = (def.status_duration or 10)
                })
                return true
            else
                scrolls.chat_if_player(caster, "You feel you might be using the scroll the wrong way")
                return false
            end
        end

    end

    local scroll = {
        description = "Scroll of " .. def.description,
        inventory_image = def.scroll_image or "scroll_of_generic_spell.png",
        groups = def.groups or {},
        liquids_pointable = def.liquids_pointable,

        on_use = function(itemstack, user, pointed_thing)
            local done = def.on_cast(user, pointed_thing)
            if done then
                local pos = (pointed_thing.type == "node" and pointed_thing.under)
                    or (pointed_thing.type == "object" and pointed_thing.ref.getpos and pointed_thing.ref:getpos())
                if pos then
                    scrolls.particle_effect(pos, def)
                end
                itemstack:take_item()
            end
            return itemstack
        end,

        on_place = function(itemstack, placer, pointed_thing)
            local done = def.on_self_cast(placer, pointed_thing)
            if done then
                scrolls.particle_effect(placer:getpos(), def)
                itemstack:take_item()
            end
            return itemstack
        end,
    }
    scroll.groups.scroll = 1

    minetest.register_craftitem(name, scroll)
end


function scrolls.cast(spell, caster, pointed_thing)
    local spell = scrolls.registered_spells[name]

    if spell.on_cast then
        return spell.on_cast(caster, pointed_thing)
    else
        return false
    end
end

function scrolls.self_cast(spellname, caster, pointed_thing)
    local spell = scrolls.registered_spells[spellname]

    if spell and spell.on_self_cast then
        scrolls.particle_effect(caster:getpos(), spell)
        return spell.on_self_cast(caster, pointed_thing)
    else
        return false
    end
end


function scrolls.particle_effect(pos, spell)
    -- spell might be the name or the spell definition
    local def
    if type(spell) == "table" then
        def = spell
    else
        def = scrolls.registered_spells[spell]
    end

    minetest.add_particlespawner(
       {
          amount = 50,
          time = 2,
          minpos = {x=pos.x-0.5,y=pos.y, z=pos.z-0.5},
          maxpos = {x=pos.x+0.5,y=pos.y+0.4,z=pos.z+0.5},
          minvel = {x=-0.1, y=0.2, z=-0.1},
          maxvel = {x=0.1,  y=0.4, z=0.1},
          minacc = {x=0, y=0, z=0},
          maxacc = {x=0, y=0.1,  z=0},
          minexptime = 1,
          maxexptime = 1.5,
          minsize = 0.8,
          maxsize = 1.25,
          collisiondetection = true,
          vertical = false,
          texture = def.particle_image or "altars_particle.png",
       })
end