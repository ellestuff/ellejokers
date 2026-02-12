local function calculate_mf_score(card)
	return card.ability.extra.base+(G.GAME.round_resets.ante-1)*card.ability.extra.ante_add
end

local mf = SMODS.Joker {
	key = 'magic_fingers',
	loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.cost, calculate_mf_score(card) } } end,
	config = { extra = { cost = 1, base = 100, ante_add = 50 } },
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 6, y = 0 },
	soul_pos = { x = 7, y = 1 },
	cost = 5
}


mf.slime_active = {
	calculate = function(self, card)
		local s = calculate_mf_score(card)
		ease_dollars(-1)
		card:juice_up(0.4)
		G.GAME.chips = G.GAME.chips + s

		--SMODS.calculate_effect({message = "+"..s, colour = G.C.PURPLE}, card)
		if G.GAME.chips >= G.GAME.blind.chips then
			G.STATE = G.STATES.HAND_PLAYED
			G.STATE_COMPLETE = true
			end_round()
		end
	end,
	
	can_use = function(self, card)
		return G.STATE == G.STATES.SELECTING_HAND and (G.GAME.dollars - G.GAME.bankrupt_at ) >= card.ability.extra.cost
	end,
	
	should_close = function(self, card) return G.GAME.chips >= G.GAME.blind.chips end
}