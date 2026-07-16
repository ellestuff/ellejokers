SMODS.Joker {
	key = 'kingslime',
	config = { extra = { chips = 10 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime
		return { vars = { card.ability.extra.chips } }
	end,
	rarity = 2,
	atlas = 'jokers',
	pos = { x = 2, y = 0 },
	blueprint_compat = true,
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card,'m_elle_slime') and context.other_card:is_face() then
			context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
			return {
				message = localize("k_upgrade_ex")
			}
		end
	end,
	enhancement_gate = 'm_elle_slime'
}