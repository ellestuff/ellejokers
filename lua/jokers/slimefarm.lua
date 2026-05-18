SMODS.Joker {
	key = 'slimefarm',
	config = { extra = { retriggers = 1 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime

		return { vars = { card.ability.extra.retriggers } }
	end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 6, y = 3 },
	blueprint_compat = true,
	cost = 6,
	calculate = function(self, card, context)
		if context.repetition and context.other_card.elle_slime_trigger then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra.retriggers
			}
		end
	end,
	enhancement_gate = 'm_elle_slime'
}