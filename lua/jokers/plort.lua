SMODS.Joker {
	key = 'plort',
	config = { extra = { money = 1 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime

		return { vars = { card.ability.extra.money } }
	end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 6, y = 3 },
	blueprint_compat = true,
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card,'m_elle_slime') then
			return {
				dollars = card.ability.extra.money
			}
		end
	end,
	enhancement_gate = 'm_elle_slime'
}