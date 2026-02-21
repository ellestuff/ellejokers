local batcreditcard = SMODS.Joker {
	key = 'bat_credit_card',
	blueprint_compat = false,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {set = "Other", key = "elle_upgr_no_shop"}
		return { vars = { card.ability.extra.bankrupt_at, card.ability.extra.recover } }
	end,
	config = { extra = { bankrupt_at = 30, recover = .5 } },
	rarity = 2,
	atlas = 'jokers',
	pos = { x = 7, y = 4 },
	cost = 10,
	in_pool = function(self) return false end,
	unlocked = false
}

batcreditcard.add_to_deck = function(self, card, from_debuff)
	G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.bankrupt_at
end

batcreditcard.remove_from_deck = function(self, card, from_debuff)
	G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.bankrupt_at
end

batcreditcard.calc_dollar_bonus = function (self, card)
	if G.GAME.dollars < 0 then return math.floor(-G.GAME.dollars * card.ability.extra.recover) end
end

-- Add upgrade to credit card
SMODS.Joker:take_ownership('credit_card', {
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval and G.GAME.dollars <= -math.floor(card.ability.extra/2) then
			card.ability.upgr_count = (card.ability.upgr_count or 0) + 1
		end
	end,
	slime_upgrade = {
		card = "j_elle_bat_credit_card",
		can_use = function(self, card) return (card.ability.upgr_count or 0)>=3 end,
		loc_vars = function(self, card)
			return { 3, card.ability.upgr_count or 0, math.floor(card.ability.extra/2) }
		end
	}
}, true)