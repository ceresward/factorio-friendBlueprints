script.on_event(defines.events.on_player_selected_area, 
    function(event)
        if event.item == 'friends-blueprint' and #event.entities > 0 then
            -- Emulates vanilla blueprint behavior by doing the following:
            -- 1) Create a new blueprint and puts it in the player's hand
            -- 2) Copy blueprint entities from the selection area into the blueprint (adjusting for position)
            -- 3) Open blueprint GUI (currently disabled b/c it's weird opening the GUI while the blueprint is buildable
            --    in the player's hand, and I don't know how to get around that yet)

            -- This block can help debug properties that the selected entities have
            -- for i, entity in ipairs(event.entities) do
            --     log(serpent.block({
            --         name=entity.name,
            --         type=entity.type,
            --         -- minable=entity.minable,
            --         prototype={
            --             flags=entity.prototype.flags,
            --         --     collision_mask=entity.prototype.collision_mask,
            --             items_to_place_this = entity.prototype.items_to_place_this
            --         --     selectable_in_game = entity.prototype.selectable_in_game
            --         }
            --     }))
            -- end
            
            -- Calculate the entity area (smallest BoundingBox that covers all entity positions), and also its center
            local entity_area = { left_top={}, right_bottom={} }
            for i,entity in ipairs(event.entities) do
                if i == 1 then
                    entity_area.left_top.x = entity.position.x
                    entity_area.left_top.y = entity.position.y
                    entity_area.right_bottom.x = entity.position.x
                    entity_area.right_bottom.y = entity.position.y
                else
                    entity_area.left_top.x = math.min(entity_area.left_top.x, entity.position.x)
                    entity_area.left_top.y = math.min(entity_area.left_top.y, entity.position.y)
                    entity_area.right_bottom.x = math.max(entity_area.right_bottom.x, entity.position.x)
                    entity_area.right_bottom.y = math.max(entity_area.right_bottom.y, entity.position.y)
                end
            end
            entity_area.center = {
                x = (entity_area.left_top.x + entity_area.right_bottom.x) / 2,
                y = (entity_area.left_top.y + entity_area.right_bottom.y) / 2
            }

            local blueprint_entities = {}
            for i,entity in ipairs(event.entities) do
                if entity.prototype.items_to_place_this then
                    table.insert(blueprint_entities, {
                        entity_number = i,
                        name = entity.name,
                        position = {
                            -- Position in blueprint should be relative to the center of the entity area
                            x = entity.position.x - entity_area.center.x,
                            y = entity.position.y - entity_area.center.y
                        },
                        variation = entity.graphics_variation,
                        direction = entity.direction
                        -- TODO: try and identify other properties that may need to be copied over
                    })
                end
            end
            
            local player = game.get_player(event.player_index)
            player.cursor_stack.set_stack{name='blueprint'}
            player.cursor_stack.set_blueprint_entities(blueprint_entities)
            -- player.opened = player.cursor_stack

            -- TODO: ideas for improvement
            -- A. Instead of trying to build the blueprint entity data myself, do something like this:
            --    1. Iterate through selected entities to discover selected forces
            --    2. Iterate through discovered forces, using create_blueprint > get_blueprint_entities > clear_blueprint to capture blueprint entity data for that force
            --    3. Concatenate discovered blueprint entities during iteration, and once done, simply call set_blueprint_entities to set the final data on the blueprint
            -- B. Revisit how blueprints are opened.  Look at LuaGameScript.create_inventory(); should be able to use it to create and open a blueprint from outside the cursor.
            --    That would fix the 'weirdness' with opening the blueprint.  When the blueprint GUI is closed, it can be transferred to the cursor, just like with regular blueprints

        end
    end
)

-- This script can help debug which entity properties are missing as compared to vanilla blueprints
-- script.on_event(defines.events.on_player_cursor_stack_changed,
--     function(event)
--         local player = game.get_player(event.player_index)
--         if player.cursor_stack and player.cursor_stack.is_blueprint then
--             log(serpent.block(player.cursor_stack.get_blueprint_entities()))
--         end
--     end
-- )
