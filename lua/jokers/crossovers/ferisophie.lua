local feri = SMODS.Joker {
	key = 'ferisophie',
	set_badges = function(self, card, badges) if (self.discovered) then
		badges[#badges+1] = slimeutils.table_create_badge(elle_badges.friends)
		badges[#badges+1] = slimeutils.table_create_badge(elle_badges.mall)
	end end,
	config = { extra = { active_mult = 0, mult_mod = 1, charges = 0, active = false } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_crossover", specific_vars = {"That Azazel Fire","@thatazazelfire.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=0} }
		}
		info_queue[#info_queue+1] = {set = "Other", key = "elle_upgr_no_shop"}
		return { vars = { card.ability.extra.mult_mod, card.ability.extra.active and card.ability.extra.active_mult or (card.ability.extra.mult_mod * card.ability.extra.charges) } }
	end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 7, y = 3 },
	cost = 10,
	blueprint_compat = true,
	slime_desc_icon = { atlas = "elle_crossover_icon", pos = {x=0,y=0}, scale = 50/34 },
	in_pool = function(self) return false end,
	no_doe = true
}

feri.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play then
		if context.other_card:is_suit("Hearts") then
			SMODS.calculate_effect({ message = localize{ type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult_mod } }, func = function()
				card.ability.extra.charges = card.ability.extra.charges+1
				card:juice_up(.1,.1)
			end}, card)
		end
		if card.ability.extra.active then
			context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) +
				card.ability.extra.active_mult
			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.MULT
			}
		end
	end
	if context.final_scoring_step and card.ability.extra.active then
		card.ability.extra.active = false
		card.ability.extra.active_mult = 0
	end
end

feri.slime_active = {
	calculate = function(self, card)
		card.ability.extra.active = true
		card.ability.extra.active_mult = card.ability.extra.mult_mod * card.ability.extra.charges
		card.ability.extra.charges = 0
		G.E_MANAGER:add_event(Event({func = function()
			card:juice_up(.4,.4)
			SMODS.calculate_effect({ message = localize("elle_joker_activate") }, card)
			juice_card_until(card, function() return not G.RESET_JIGGLES and card.ability.extra.active end, true)
		return true end }))
	end,
	can_use = function(self, card) return card.ability.extra.charges > 0 and G.STATE == G.STATES.SELECTING_HAND and not card.ability.extra.active end,
	should_close = function(self, card) return true end
}
