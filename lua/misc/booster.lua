SMODS.Booster{
	key = "resident",
	atlas = "booster",
	weight = 0.5,
	kind = 'elle_Resident',
	cost = 6,
	config = { extra = 4, choose = 1 },
	ease_background_colour = function(self)
		ease_background_colour({
			new_colour = G.C.SET.elle_Resident,
			special_colour = darken(G.C.SET.elle_Resident,.5)
		})
	end,
	particles = function(self)
		G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
			timer = 0.015,
			scale = 0.1,
			initialize = true,
			lifespan = 3,
			speed = 0.2,
			padding = -1,
			attach = G.ROOM_ATTACH,
			colours = { G.C.WHITE, lighten(G.C.SET.elle_Resident, 0.2) },
			fill = true
		})
		G.booster_pack_sparkles.fade_alpha = 1
		G.booster_pack_sparkles:fade(1, 0)
	end,
	create_card = function(self, card, i)
		return {
			set = "elle_Resident",
			area = G.pack_cards,
			skip_materialize = true,
			--soulable = true
		}
	end,
	select_card = 'elle_resident_area'
}