SMODS.Joker {
	key = 'insomniac',
	config = { extra = { mult = 15 } },
	loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.mult } } end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 0, y = 0 },
	blueprint_compat = true,
	cost = 5,
	calculate = function(self, card, context)
		if context.joker_main and #G.elle_resident_area.cards == 0 then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}