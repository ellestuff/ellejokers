local twy = SMODS.Joker {
	key = 'twy',
	set_badges = function(self, card, badges) if (self.discovered) then badges[#badges+1] = slimeutils.table_create_badge(elle_badges.poly) end end,
	config = { extra = { odds = 4 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_cameo", specific_vars = {"Twylight","@twylightstar.bsky.social"},
			slime_desc_icon = { atlas = "elle_crossover_icon", pos = {x=0,y=1}, scale = 50/34 }
		}
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_twy')
		return { vars = { numerator, denominator } }
	end,
	rarity = 4,
	atlas = 'legendary',
	pos = { x = 1, y = 0 },
	cost = 20,
	unlocked = false,
	slime_desc_icon = { atlas = "elle_crossover_icon", pos = {x=0,y=1}, scale = 50/34 }
}

twy.calculate = function(self, card, context)
	if context.end_of_round and context.main_eval and SMODS.pseudorandom_probability(card, 'elle_twy', 1, card.ability.extra.odds) and #G.hand.cards > 0 then
		-- Find viable Jokers
		local candidates = {}
		for k, v in ipairs(G.jokers.cards) do
			local j = G.jokers.cards[k]
			if (j ~= card and not (j.edition and j.edition.key == "e_negative")) then candidates[#candidates+1] = j end
		end
		-- If there are non-negative jokers
		if #candidates > 0 then
			-- Destroy the cards in hand
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				for k, v in ipairs(G.hand.cards) do
					v:juice_up(.4,.4)
					v:start_dissolve({HEX("FFAE36")}, nil, 1.6)
				end
			return true end }))
			
			-- Set Joker to negative
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				local j = pseudorandom_element(candidates, 'elle_twy_target')
				j:set_edition("e_negative", true)
				j:juice_up(.4,.4)
				card:juice_up(.4,.4)
			return true end }))
			
			return {
				remove = true,
				message = "Negative!",
				colour = G.C.DARK_EDITION
			}
		end
	end
end

local soul_layers = {
	{x=2,y=0},
	{x=2,y=1},
}

twy.soul_pos = {
	x = 2, y = 1,
	draw = function(card, scale_mod, rotate_mod)
		local spr = card.children.floating_sprite
		
		spr:set_sprite_pos(soul_layers[1])
		spr:draw_shader( -- Shadow
			'dissolve', 0, nil, nil,
			card.children.center,
			scale_mod*.75, rotate_mod*.75,
			spr.role.offset.x,
			spr.role.offset.y + 0.03*math.sin(1.8*G.TIMERS.REAL),
			nil, 0.3)
		spr:draw_shader('dissolve', nil, nil, nil,
			card.children.center, scale_mod*.75, rotate_mod*.75)
		
		spr:set_sprite_pos(soul_layers[2])
		spr:draw_shader( -- Shadow
			'dissolve', 0, nil, nil,
			card.children.center,
			scale_mod*1.5, rotate_mod*1.5,
			spr.role.offset.x,
			spr.role.offset.y + 0.03*math.sin(1.8*G.TIMERS.REAL),
			nil, 0.6)
		spr:draw_shader('dissolve', nil, nil, nil,
			card.children.center, scale_mod*1.5, rotate_mod*1.5)
	end
}