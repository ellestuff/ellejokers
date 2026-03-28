-- Resident (Tarot)
SMODS.Consumable {
	key = 'resident',
	set = 'Tarot',
	cost = 4,
	atlas = 'consumables',
	pos = { x = 1, y = 0 },
	config = { extra = { }, max_highlighted = 2, mod_conv = "m_elle_slime" },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime
		return { vars = { card.ability.max_highlighted } }
	end
}

-- Jess (Tarot)
SMODS.Consumable {
	key = 'jess',
	set = 'Tarot',
	cost = 4,
	atlas = 'consumables',
	pos = { x = 2, y = 0 },
	config = { extra = { }, max_highlighted = 2, mod_conv = "m_elle_jess" },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_jess
		return { vars = { card.ability.max_highlighted } }
	end
}


-- Experiment (Spectral)
SMODS.Consumable {
	key = 'experiment',
	set = 'Spectral',
	cost = 7,
	atlas = 'consumables',
	pos = { x = 1, y = 1 },
	config = { extra = {max_highlighted = 2} },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.max_highlighted } }
	end,
	use = function(self, card, area, copier)
		local used_tarot = copier or card
		local edition = G.jokers.highlighted[1].edition.key

		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.4,
			func = function()
				play_sound('tarot1')
				used_tarot:juice_up(0.3, 0.5)
		return true end }))

		for i = 1, #G.hand.highlighted do
			local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.15,
				func = function()
					G.hand.highlighted[i]:flip()
					play_sound('card1', percent)
					G.hand.highlighted[i]:juice_up(0.3, 0.3)
					return true
				end
			}))
		end
		delay(0.2)
		for i = 1, #G.hand.highlighted do
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.1,
				func = function()
					G.hand.highlighted[i]:set_edition(edition,true)
					return true
				end
			}))
		end
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.1,
			func = function()
				G.jokers.highlighted[1].edition = nil
				G.jokers.highlighted[1]:juice_up()
				return true
			end
		}))
		for i = 1, #G.hand.highlighted do
			local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.15,
				func = function()
					G.hand.highlighted[i]:flip()
					play_sound('tarot2', percent, 0.6)
					G.hand.highlighted[i]:juice_up(0.3, 0.3)
					return true
				end
			}))
		end
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.2,
			func = function()
				G.hand:unhighlight_all()
				G.jokers:unhighlight_all()
				return true
			end
		}))
		delay(0.3)
	end,
	can_use = function(self, card)
		return #G.jokers.highlighted == 1 and G.jokers.highlighted[1].edition and G.jokers.highlighted[1].edition.key ~= "e_negative" and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.max_highlighted
	end,
	in_pool = function (self, args)
		return next(SMODS.Edition:get_edition_cards(G.jokers, true))
	end
}

-- Doppelgänger (Spectral)
SMODS.Consumable {
	key = 'doppel',
	set = 'Spectral',
	cost = 7,
	atlas = 'consumables',
	pos = { x = 2, y = 1 },
	config = { extra = { }, max_highlighted = 1, mod_conv = "m_elle_copycat" },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_copycat
		return { vars = { card.ability.max_highlighted } }
	end
}
