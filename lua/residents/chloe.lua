ellejokers.Resident {
	key = 'chloe',
	pos = { x = 2, y = 0 },
	config = { extra = { chip_mod = 1, chips = 0, count = 0, req = 20 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chip_mod, card.ability.extra.chips } }
	end,
	slime_upgrade = {
		card = "elle_r_elle_furry",
		can_use = function(self, card) return card.ability.extra.count>=card.ability.extra.req end,
		loc_vars = function(self, card) return { card.ability.extra.req, card.ability.extra.count } end
	},
	calculate = function(self, card, context)
		if context.discard and not context.other_card.debuff and not context.blueprint then
			card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
			
			local face = context.other_card:is_face()
			if face then card.ability.extra.count = card.ability.extra.count + 1 end
			
			return {
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chip_mod } },
				colour = not face and G.C.CHIPS
			}
		end
		if context.joker_main then
			if card.ability.extra.chips ~= 0 then
				return {
					chips = card.ability.extra.chips,
				}
			end
		end
	end,
	resident_colour = HEX("ffa747")
}