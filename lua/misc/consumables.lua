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
	config = { extra = {max_highlighted = 3} },
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

--		[[ MoreFluff Stuff ]]
--	colour card crashes game :(
--[[if next(SMODS.find_mod('MoreFluff')) then
	SMODS.Consumable {
		object_type = "Consumable",
		set = "Colour",
		name = "col_ellepink",
		key = "ellepink",
		pos = { x = 1, y = 2 },
		config = {
			val = 0,
			partial_rounds = 0,
			upgrade_rounds = 3,
		},
		loc_txt = {
			name = "ellepink.",
			text = {
				"Converts a random card in",
				"hand to a {C:attention}Slimed Card{} for every",
				"{C:attention}#4#{} rounds this has been held",
				"{C:inactive}(Currently {C:attention}#1#{C:inactive}, {}[{C:attention}#2#{C:inactive}#3#{}]{C:inactive})"
			},
	  },
		cost = 4,
		atlas = "consumables",
		unlocked = true,
		discovered = true,
		display_size = { w = 71, h = 87 },
		pixel_size = { w = 71, h = 87 },
		can_use = function(self, card)
			return #G.hand.cards > 1
		end,
		use = function(self, card, area, copier)
			local rng_seed = "colours_ellepink"
			local blacklist = {}
			for i = 1, card.ability.val do
				local temp_pool = {}
				for k, v in pairs(G.hand.cards) do
					if not v.config.center_key == "m_elle_slimed" and not blacklist[v] then
						table.insert(temp_pool, v)
					end
				end
				local over = false
				if #temp_pool == 0 then
					break
				end
				local eligible_card = pseudorandom_element(temp_pool, pseudoseed(rng_seed))
				blacklist[eligible_card] = true
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() eligible_card:flip();play_sound('card1', 1);eligible_card:juice_up(0.3, 0.3);return true end }))
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.4,func = function() eligible_card:flip();play_sound('tarot2', percent);eligible_card:set_ability(G.P_CENTERS.m_elle_slimed, nil, true);return true end }))
				card:juice_up(0.3, 0.5)
			end
			delay(0.6)
		end,
		loc_vars = function(self, info_queue, card)
			local val, max = progressbar(card.ability.partial_rounds, card.ability.upgrade_rounds)
			return { vars = {card.ability.val, val, max, card.ability.upgrade_rounds} }
		end
	}
end]]
