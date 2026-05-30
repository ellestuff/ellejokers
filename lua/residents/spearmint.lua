ellejokers.Resident {
	key = 'spearmint',
	pos = { x = 0, y = 3 },
	config = { extra = { } },
	resident_colour = HEX("81cefd"),
	in_pool = function (self, args) return false end,
	draw = function(self, card, layer)
		if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' and not slimeutils.card_obscured(card) then
			card.children.center:draw_shader('hologram', nil, card.ARGS.send_to_shader)
		end
	end,
}