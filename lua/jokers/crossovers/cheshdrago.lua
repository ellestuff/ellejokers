local cheshdrago = SMODS.Joker {
	key = 'cheshdrago',
	set_badges = function(self, card, badges) if (self.discovered) then
		badges[#badges+1] = slimeutils.table_create_badge(elle_badges.friends)
		badges[#badges+1] = slimeutils.table_create_badge(elle_badges.mall)
	end end,
	config = { extra = { xmult = 1, xmult_mod = .25, used = false } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_crossover", specific_vars = {"Drago","@dragothedemon.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=1} }
		}
		info_queue[#info_queue+1] = G.P_CENTERS.m_wild
		info_queue[#info_queue+1] = {set = "Other", key = "elle_upgr_no_shop"}
		return { vars = { card.ability.extra.xmult_mod, card.ability.extra.xmult, card.ability.extra.used and "Inactive" or "Active" } } end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 6, y = 3 },
	cost = 6,
	blueprint_compat = true,
	slime_desc_icon = { atlas = "elle_crossover_icon", pos = {x=1,y=0}, scale = 50/34 },
	in_pool = function(self) return false end,
	no_doe = true
}

cheshdrago.calculate = function(self, card, context)
	if context.before then card.ability.extra.used = false end
	
	-- XMult stuff
	if context.joker_main and card.ability.extra.xmult ~= 1 then
		return { xmult = card.ability.extra.xmult }
	end
end

cheshdrago.slime_active = {
	calculate = function(self, card)
		local _card = G.hand.highlighted[1]
		
		card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
		G.E_MANAGER:add_event(Event({func = function()
			card:juice_up(.4,.4)
			_card:start_dissolve({HEX("625F86")}, nil, 1.6)
			SMODS.destroy_cards(_card)
		return true end }))
		
		card.ability.extra.used = true
		
		SMODS.calculate_effect({ message_card = card,
			remove = true,
			message = "+X"..card.ability.extra.xmult_mod,
			colour = G.C.RED
		}, card)
	end,
	can_use = function(self, card)
		return #G.hand.highlighted == 1 and SMODS.has_enhancement(G.hand.highlighted[1], 'm_wild') and not card.ability.extra.used
	end,
	should_close = function(self, card) return true end
}