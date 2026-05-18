local cassie = SMODS.Joker {
	key = 'cassie',
	config = { extra = { mult_mod = 2, mult = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult_mod, card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 4, y = 4 },
	soul_pos = { x = 5, y = 3 },
	cost = 5,
	blueprint_compat = true,
	no_pool_flag = 'elle_cassie_death'
}

cassie.calculate = function(self, card, context)
	if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
		card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
		
		return { message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult_mod } },
			colour = G.C.MULT }
	end
	if context.joker_main then
		if card.ability.extra.mult ~= 0 then
			return { mult = card.ability.extra.mult }
		end
	end
end