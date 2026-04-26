ellejokers.Resident {
	key = 'cheshire',
	pos = { x = 2, y = 1 },
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chip_mod, card.ability.extra.chips } }
	end,
	in_pool = function (self, args) return false end,
    elle_tail = { x = 4, y = 2 },
	calculate = function(self, card, context)
	end
}