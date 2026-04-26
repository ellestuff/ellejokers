SMODS.Blind {
	key = "awoken",
	atlas = "blinds",
	dollars = 5, 
	mult = 2, 
	pos = { x = 0, y = 0 },
	in_pool = function(self) return G.elle_resident_area and #G.elle_resident_area.cards>0 end,
	boss_colour = HEX("e461a2"),
	phase_refresh = true,
	boss = {},
	recalc_debuff = function(self, card, from_blind)
		return card.ability.set == 'elle_Resident'
	end
}