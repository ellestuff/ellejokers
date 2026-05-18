SMODS.Joker {
	key = 'contract',
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime
		return { vars = { } }
	end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 6, y = 3 },
	blueprint_compat = true,
	cost = 5,
	calculate = function(self, card, context)
		if context.setting_blind then
			local target = pseudorandom_element(G.playing_cards,'elle_contract',{in_pool=function(v,args)
				return SMODS.has_enhancement(v,'c_base')
			end})

			if target then
				target:set_ability('m_elle_slime', nil, true)
				G.E_MANAGER:add_event(Event({func=function()
					target:juice_up()
				return true end}))
			end
		end
	end
}