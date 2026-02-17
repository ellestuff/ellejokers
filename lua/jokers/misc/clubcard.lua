local clubcard = SMODS.Joker {
	key = 'clubcard',
	blueprint_compat = false,
	loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.dollars } } end,
	config = { extra = { dollars = 1 } },
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 2, y = 1 },
	cost = 10
}

clubcard.calculate = function(self, card, context)
	if context.hand_drawn then
		for _, playing_card in ipairs(context.hand_drawn) do
			if playing_card:is_suit("Clubs") then
				card:juice_up()
				SMODS.calculate_effect({dollars = card.ability.extra.dollars}, playing_card)
			end
		end
	end
end