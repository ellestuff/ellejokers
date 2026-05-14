if not FLUFF.is_rewrite then return end -- Only continue if playing with the MoreFluff rewrite

SMODS.Atlas {
	key = "morefluff",
	path = "crossmod/morefluff.png",
	px = 71,
	py = 95
}

FLUFF.Colour({
	key = "jessblue",
	name = "col_jessblue",
	atlas = "morefluff",
	pos = { x = 1, y = 1 },
	config = {
		upgrade_rounds = 1,
        enhancement = "m_elle_jess"
	},
	slime_desc_icon = {
		atlas = "elle_cornericons",
		pos = {x=1,y=0}
	},
	mf_art_credit = "Multi + ellestuff."
})

FLUFF.Colour({
	key = "ellepink",
	name = "col_ellepink",
	atlas = "morefluff",
	pos = { x = 2, y = 1 },
	config = {
		upgrade_rounds = 1,
        enhancement = "m_elle_slime"
	},

	mf_art_credit = "Multi + ellestuff."
})

SMODS.Consumable({
	set = "Rotarot",
	key = "rot_lucid",
	pos = { x = 0, y = 0 },
	config = {
		max_highlighted = 2,
		mod_conv = "m_elle_lime",
	},
	cost = 3,
	atlas = "morefluff",
	unlocked = true,
	discovered = true,
	mf_rotate_by = math.pi / 4,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_elle_lime

		return { vars = { card.ability.max_highlighted } }
	end,
})

SMODS.Consumable({
	set = "Rotarot",
	key = "rot_jess",
	pos = { x = 1, y = 0 },
	config = {
		max_highlighted = 4,
		mod_conv = "m_elle_less",
	},
	cost = 3,
	atlas = "morefluff",
	unlocked = true,
	discovered = true,
	mf_rotate_by = math.pi / 4,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_elle_less

		return { vars = { card.ability.max_highlighted } }
	end,
})

SMODS.Enhancement {
	key = 'lime',
	atlas = 'morefluff',
	pos = { x = 0, y = 1 },
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	calculate = function(self, card, context)
	end
}

SMODS.Enhancement {
	key = 'less',
	pos = { x = 1, y = 0 },
	config = { extra_slots_used = -.5, extra = {handper = 1} },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.handper, 1+card.ability.extra_slots_used }, key = card.fake_card and 'm_elle_less2' }
	end,
	display_size = { w = 71 * 0.7, h = 95 * 0.7 },
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			local count = 0
			
			for i, v in ipairs(G.hand.cards) do
				if SMODS.has_enhancement(v, "m_elle_less") then count = count + 1 end
			end

			return {
				mult = count*card.ability.extra.handper
			}
		end
	end
}

ellejokers.Resident {
	key = "triangle",
	atlas = "morefluff",
	pos = {x=0,y=2},
	resident_colour = HEX('ff6868'),
	mf_art_credit = "notmario",
	config = { extra = { charges = 0, rotarot_bonus = 3, can_destroy = true } },
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra.rotarot_bonus,
			card.ability.extra.charges,
			(card.ability.extra.charges ~= 1) and "s" or "",
		} }
	end,
	resident_buttons = {
		{
			text = function() return localize("b_use") end,
			can_use = function(self, card)
				if #G.consumeables.highlighted ~= 1 then return false end
				local set = G.consumeables.highlighted[1].ability.set
				-- we do the is_colour check for Gold
				return (set == "Tarot") or (set == "Rotarot") or 
					(FLUFF.is_colour(G.consumeables.highlighted[1]) and (card.ability.extra.charges) > 0)
			end,
			use = function(self, card)
				if FLUFF.is_colour(G.consumeables.highlighted[1]) then
					for _ = 1, card.ability.extra.charges do
						trigger_colour_end_of_round(G.consumeables.highlighted[1])
					end
					card.ability.extra.charges = 0
				else
					for _, other_card in ipairs(G.consumeables.highlighted) do
						local set = other_card.ability.set
						if set == "Rotarot" then
							card.ability.extra.charges = card.ability.extra.charges + card.ability.extra.rotarot_bonus
						else
							card.ability.extra.charges = card.ability.extra.charges + 1
						end
						SMODS.calculate_individual_effect({ message = localize "elle_triangle_destroyed", colour = G.C.RED }, card, "message", nil, nil)
					end

					SMODS.destroy_cards(G.consumeables.highlighted)
				end
			end,
			colour = HEX("ff6868"),
			scale = 1.6,
			close = true
		}
	},
}