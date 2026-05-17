ellejokers.Resident {
	key = 'cheshire',
	atlas = 'furrychesh',
	pos = { x = 0, y = 1 },
	config = { extra = { xmult_mod = 0.1, xmult = 1, eaten = 0, active = true, anim_timer = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = {
			localize(ellejokers.mod_data.config.nsfw and "elle_furry_eat" or "elle_furry_destroy"):lower(),
			card.ability.extra.xmult_mod,
			localize(ellejokers.mod_data.config.nsfw and "elle_furry_eaten" or "elle_furry_destroyed"),
			card.ability.extra.eaten,
			card.ability.extra.xmult,
			localize(card.ability.extra.active and "elle_active_available" or "elle_active_used")
		}}
	end,
	in_pool = function (self, args) return false end,
	elle_tail = { x = 7, y = 1 },
	calculate = function(self, card, context)
		if card.ability.extra.active and context.setting_blind and not context.retrigger_joker then
				juice_card_until(card,function(card)
					return card.ability.extra.active and G.STATE ~= G.STATES.ROUND_EVAL
				end)
		end
		
		if context.joker_main then
			if not card.ability.extra.active and not context.retrigger_joker then
				G.E_MANAGER:add_event(Event({func = function()
					card.ability.extra.active = true
					juice_card_until(card,function(card)
						return card.ability.extra.active and G.STATE ~= G.STATES.ROUND_EVAL
					end)
				return true end}))
			end
			
			if card.ability.extra.xmult ~= 1 or (not card.ability.extra.active and not context.retrigger_joker) then
				return {
					mult = card.ability.extra.xmult ~= 1 and card.ability.extra.xmult or nil,
					extra = not card.ability.extra.active and not context.retrigger_joker and { message = localize("elle_active_refreshed") } or nil
				}
			end
		end

		if context.end_of_round and context.main_eval and card.ability.extra.eaten > 0 and not context.retrigger_joker then
			local mod = card.ability.extra.eaten * card.ability.extra.xmult_mod
			
			card.ability.extra.xmult = card.ability.extra.xmult + mod
			
			G.E_MANAGER:add_event(Event({func=function()
				card.ability.extra.eaten = 0

				if ellejokers.mod_data.config.nsfw then
					card.ability.extra.anim_timer = 0.5
					--play_sound("elle_burp") -- will uncomment once i've recorded myself burping :giggle_hehe:
				end
			return true end}))
			
			return { message = localize("k_upgrade_ex") }
		end
	end,
	update = function(self, card, dt) ellejokers.furry_sprite(card) end,
	resident_buttons = {
		{
			text = function() return localize(ellejokers.mod_data.config.nsfw and "elle_furry_eat" or "elle_furry_destroy") end,
			can_use = function(self, card) return card.ability.extra.active and #G.hand.highlighted == 1 end,
			use = function(self, card)
				card.ability.extra.active = false
				SMODS.destroy_cards(G.hand.highlighted[1])

				G.E_MANAGER:add_event(Event({func=function()
					card.ability.extra.eaten = card.ability.extra.eaten + 1
				return true end}))
				
				SMODS.calculate_effect({
					message = "+1",
					sound = "slice1"
				},card)
			end,
			colour = HEX("917bad"),
			scale = 1.6,
			close = true
		}
	},
	resident_colour = HEX("917bad"),
	set_ability = function(self, card, initial, delay_sprites) ellejokers.furry_sprite(card) end
}