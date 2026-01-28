-- Slime Enhancement
SMODS.Enhancement {
	key = 'slime',
	atlas = 'enhancers',
	pos = { x = 0, y = 0 },
	config = { extra = { odds = 3, retriggers = 2 } },
	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_slime_card')
		return { vars = { numerator, denominator, card.ability.extra.retriggers } }
	end,
	calculate = function(self, card, context)
		if context.repetition and SMODS.pseudorandom_probability(card, 'elle_slime_card', 1, card.ability.extra.odds) then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra.retriggers
			}
		end
	end
}

-- Jess Enhancement
SMODS.Enhancement {
	key = 'jess',
	atlas = 'enhancers',
	pos = { x = 1, y = 0 },
	config = { extra = { retrigger_count = 1, req = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.retrigger_count, card.ability.extra.req } }
	end,
	calculate = function(self, card, context)
		if context.repetition and context.cardarea == G.play then
			local retriggers = 0
			for i,v in ipairs(G.play.cards) do
				if (SMODS.has_enhancement(v, "m_elle_jess") and not v.debuff) then retriggers = retriggers + 1 end
			end
			
			if SMODS.find_card("j_elle_jess")[1] then
				for i,v in ipairs(G.hand.cards) do
					if (SMODS.has_enhancement(v, "m_elle_jess") and not v.debuff) then retriggers = retriggers + 1 end
				end
			end
			
			retriggers = math.floor(retriggers/card.ability.extra.req)
			
			if retriggers > 0 then
				return {
					message = localize('k_again_ex'),
					repetitions = retriggers * card.ability.extra.retrigger_count
				}
			end
		end
	end
}