ellejokers.Resident {
	key = 'spearmint',
	pos = { x = 0, y = 3 },
	config = { extra = { } },
	resident_colour = HEX("81cefd"),
	in_pool = function (self, args) return false end
}

SMODS.DrawStep {
	key = 'elle_spearmint',
	order = 21,
	func = function(self)
		if self.config.center.key == "elle_r_elle_spearmint" and not slimeutils.card_obscured(self) then
			local spr = SMODS.shallow_copy(self.children.center.sprite_pos)

			self.children.center:set_sprite_pos({x=1,y=3})
			self.children.center:draw_shader('hologram', nil, nil, nil, self.children.center)
			self.children.center:set_sprite_pos(spr)
		end
	end,
	conditions = { vortex = false, facing = 'front' },
}