local powerscaler = SMODS.Joker {
	key = 'powerscaler',
	blueprint_compat = true,
	config = { extra = { xmult = 1, xmult_mod = 1 } },
	loc_vars = function(self, info_queue, card) 
		return { vars = { card.ability.extra.xmult_mod, card.ability.extra.xmult } }
	end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 5, y = 1 },
	cost = 9
}

powerscaler.calculate = function(self, card, context)
	if context.slime_upgrade and context.card.area == G.jokers then
		card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
		return { message = localize("k_upgrade_ex") }
	end

	if context.joker_main and card.ability.extra.xmult ~= 1 then
		return { xmult = card.ability.extra.xmult }
	end
end