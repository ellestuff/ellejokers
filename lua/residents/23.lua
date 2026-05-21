ellejokers.Resident {
	key = 'p23',
	pos = { x = 1, y = 1 },
	config = { extra = { count = 2 } },
	resident_colour = HEX("fd5f55"),
	loc_vars = function(self, info_queue, card)
		return { vars = {
			"#", -- Needed to add a # to the card name
			card.ability.extra.count
		}, bio_key = G.P_CENTERS.elle_r_elle_cheshire.discovered and self.key.."_chesh" or nil }
	end,
	calculate = function(self, card, context)
		if context.elle_add_card then
			local count = 0 -- Track whether to do return message
			
			for i = 1, card.ability.extra.count do
				local c = pseudorandom_element(G.discard.cards,"elle_p23",{in_pool = function(v)
					return not v.elle_extra_scoring_card
				end})
				if c then
					c.elle_extra_scoring_card = true
					ellejokers.extra_scoring_cards[#ellejokers.extra_scoring_cards + 1] = c
					count = count + 1
				else break end
			end
			if count > 0 then
				return { message = localize("elle_prototype_activate") }
			end
		end
	end
}

--[[SMODS.other_calculation_keys[#SMODS.other_calculation_keys+1] = 'elle_add_cards'

local cie_hook = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
	if key == 'elle_add_cards' then
		return {[key] = amount}
	end

	return cie_hook(effect, scored_card, key, amount, from_edition)
end]]