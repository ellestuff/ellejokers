ellejokers.Resident {
	key = 'p23',
	pos = { x = 1, y = 1 },
	config = { extra = { } },
	resident_colour = HEX("fd5f55"),
	loc_vars = function(self, info_queue, card)
		return { vars = {
			"#" -- Needed to add a # to the card name
		}, bio_key = G.P_CENTERS.elle_r_elle_cheshire.discovered and self.key.."_chesh" or nil }
	end,
	calculate = function(self, card, context)
		if context.elle_add_card then
			local pool = {}
			for _,v in pairs(G.discard.cards) do
				if not v.elle_extra_scoring_card then
					pool[#pool+1] = v
				end
			end

			if #pool > 0 then
				local c = pseudorandom_element(pool,"elle_p23")
				c.elle_extra_scoring_card = true
				ellejokers.extra_scoring_cards[#ellejokers.extra_scoring_cards + 1] = c
				return {
					message = localize("elle_23_activate")
				}
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