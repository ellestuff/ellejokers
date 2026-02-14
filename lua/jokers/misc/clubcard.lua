local clubcard = SMODS.Joker {
	key = 'clubcard',
	blueprint_compat = false,
	config = { extra = { dollars = 1 } },
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 2, y = 1 },
	cost = 10
}

clubcard.loc_vars = function(self, info_queue, card)
	local clubcount = 0
	if G.playing_cards then
		for _, playing_card in ipairs(G.playing_cards) do
			if playing_card:is_suit("Clubs") then clubcount = clubcount + 1 end
		end
	end
	return { vars = { card.ability.extra.dollars, card.ability.extra.dollars * clubcount } }
end

clubcard.calc_dollar_bonus = function(self, card)
	local clubcount = 0
	for _, playing_card in ipairs(G.playing_cards) do
		if playing_card:is_suit("Clubs") then clubcount = clubcount + 1 end
	end
	return clubcount > 0 and card.ability.extra.dollars * clubcount or nil
end