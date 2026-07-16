ellejokers.Resident {
	key = 'gantra',
	pos = { x = 3, y = 3 },
	soul_pos = { x = 4, y = 3 },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_cameo", specific_vars = {"That Azazel Fire","@thatazazelfire.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=0} }
		}
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_vivian')

		return { vars = {
			numerator, denominator,
			localize(ellejokers.mod_data.config.nsfw and "elle_gantra_absorb" or "elle_furry_destroy"):lower(),
			card.ability.extra.xchips_mod,
			card.ability.extra.xchips
		}}
	end,
	config = { extra = { odds = 2, xchips = 1, xchips_mod = 0.25} },
	resident_colour = HEX("8e335b"),
	resident_visitor = true,
	slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=0} },
	calculate = function(self,card,context)
		if context.individual and context.cardarea == G.play and context.other_card.elle_slime_trigger and SMODS.pseudorandom_probability(card, 'elle_gantra', 1, card.ability.extra.odds) then
			card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.xchips_mod
			
			return {
				message = localize("k_upgrade_ex"),
				message_card = card,
				pre_func = function()
					SMODS.destroy_cards(context.other_card)
				end
			}
		end

		if context.joker_main then
			if card.ability.extra.xchips ~= 1 then
				return {
					xchips = card.ability.extra.xchips
				}
			end
		end
	end
}