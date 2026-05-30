ellejokers.Resident {
	key = 'mint',
	pos = { x = 4, y = 0 },
	loc_vars = function(self, info_queue, card)
		local colours = { G.C.SUITS[card.ability.extra.suit] }
		
		for i = 1, 6 do
			colours[#colours+1] = mix_colours(self.resident_colour,G.P_CENTERS.elle_r_elle_sarah.resident_colour,(i-1)/5)
		end
		
		return {
			vars = {
				card.ability.extra.suit,
				card.ability.extra.rank,
				card.ability.extra.xmult,
				colours = colours
			},
			bio_key = G.P_CENTERS.elle_r_elle_cheshire.discovered and self.key.."_chesh" or nil
		}
	end,
	config = { extra = { suit = 'Spades', rank = 'Ace', xmult = 1.3 } },
	resident_colour = HEX("65e6d4"),
	in_pool = function (self, args) return false end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) and ellejokers.sarah_get_id(context.other_card) == SMODS.Ranks[card.ability.extra.rank].id then
			return { xmult = card.ability.extra.xmult }
		end
	end,
	resident_buttons = {
		{
			text = "Edit",
			can_use = function(self, card) return G.STATE ~= G.STATES.HAND_PLAYED end,
			use = function(self,card) G.FUNCS.overlay_menu({ definition = ellejokers.create_UIbox_sarah(card) }) end,
			colour = HEX("65e6d4"),
			scale = 1.6,
			close = true
		}
	}
}