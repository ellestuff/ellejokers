SMODS.Joker {
	key = 'flare',
	config = { extra = { odds = 8 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime
		info_queue[#info_queue+1] = ellejokers.burn_desc()

		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_flare')
		return { vars = { numerator, denominator } }
	end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 6, y = 3 },
	blueprint_compat = true,
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card,'m_elle_slime') and SMODS.pseudorandom_probability(card, 'elle_flare', 1, card.ability.extra.odds) then
			local target = context.other_card
			return {
				message = localize("elle_burn"),
				pre_func = function()			-- woah
					ellejokers.add_burn(target)	-- second use for pre_func found
				end								--		- @nh6574
			}
		end
	end,
	enhancement_gate = 'm_elle_slime'
}