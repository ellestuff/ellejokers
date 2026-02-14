local vivian = SMODS.Joker {
	key = 'vivian',
	set_badges = function(self, card, badges) if (self.discovered) then badges[#badges+1] = slimeutils.table_create_badge(elle_badges.friends) end end,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_crossover", specific_vars = {"Reverie","@critterror.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=1,y=1} }
		}
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_vivian')
		return { vars = { numerator, denominator } }
	end,
	config = { extra = { odds = 8 } },
	rarity = 3,
	atlas = 'puritan',
	pos = { x = 1, y = ellejokers.mod_data.config.puritan and 1 or 0 },
	cost = 7,
	slime_desc_icon = { atlas = "elle_cornericons", pos = {x=1,y=1} }
}

vivian.calculate = function(self, card, context)
	if context.before and context.cardarea == G.jokers and SMODS.pseudorandom_probability(card, 'elle_vivian', 1, card.ability.extra.odds) then
		for k, v in ipairs(context.scoring_hand) do
			local ench = SMODS.poll_enhancement({
				key = "elle_vivian_card",
				guaranteed = true
			})
			
			v:set_ability(G.P_CENTERS[ench], nil, true)
		end
		
		return {}
	end
end