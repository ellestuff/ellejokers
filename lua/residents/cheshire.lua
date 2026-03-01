ellejokers.Resident {
	key = 'cheshire',
	atlas = 'furrychesh',
	pos = { x = 0, y = 1 },
	config = { extra = { xmult_mod = 0.1, xmult = 1, eaten = 0, active = true } },
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
		if context.joker_main  then
			ret = {}
			
			if card.ability.extra.xmult ~= 1 then
				ret.mult = card.ability.extra.xmult
			end

			if not card.ability.extra.active then
				card.ability.extra.active = true
				ret.extra = { message = localize("elle_active_refreshed") }
			end
			
			return ret
		end

		if context.end_of_round and context.main_eval and card.ability.extra.eaten > 0 then
			local mod = card.ability.extra.eaten * card.ability.extra.xmult_mod
			
			card.ability.extra.xmult = card.ability.extra.xmult + mod
			card.ability.extra.eaten = 0
			

			return {
				message = localize { type = 'variable', key = 'a_xmult', vars = { mod } },
				colour = G.C.MULT
			}
		end
	end,
	resident_buttons = {
		{
			text = function() return localize(ellejokers.mod_data.config.nsfw and "elle_furry_eat" or "elle_furry_destroy") end,
			can_use = function(self, card) return card.ability.extra.active and #G.hand.highlighted == 1 end,
			use = function(self, card)
				card.ability.extra.active = false
				SMODS.destroy_cards(G.hand.highlighted[1])
				card.ability.extra.eaten = card.ability.extra.eaten + 1
				
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
	resident_colour = HEX("917bad")
}