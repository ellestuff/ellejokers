ellejokers.Resident {
	key = 'marie',
	pos = { x = 3, y = 3 },
	config = { extra = { } },
	loc_vars = function(self, info_queue, card) end,
	calculate = function(self, card, context) end,
	resident_buttons = { },
	draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end,
    weight = 0.05,
	in_pool = function (self, args) return false end
}