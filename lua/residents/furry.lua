function ellejokers.furry_sprite(card)
	if not slimeutils.card_obscured(card) then
		local y = card.children.center.sprite_pos.y

		local x = 0

		if ellejokers.mod_data.config.nsfw then
			x = card.ability.extra.anim_timer and card.ability.extra.anim_timer>0 and 6 or 1+math.min(card.ability.extra.eaten,4)
		end

		card.children.center:set_sprite_pos({x = x, y = y})
	end
end

local furry = ellejokers.Resident {
	key = 'furry',
	atlas = 'furrychesh',
	pos = { x = 0, y = 0 },
	config = { extra = {mult_mod = 2, mult = 0, eaten = 0, count = 0, req = 10, anim_timer = 0} },
	loc_vars = function(self, info_queue, card) return { vars = {
		localize(ellejokers.mod_data.config.nsfw and "elle_furry_eat" or "elle_furry_destroy"),
		card.ability.extra.mult_mod,
		localize(ellejokers.mod_data.config.nsfw and "elle_furry_eaten" or "elle_furry_destroyed"),
		card.ability.extra.eaten,
		card.ability.extra.mult
	},bio_key = G.P_CENTERS.elle_r_elle_cheshire.discovered and self.key.."_chesh" or nil} end,
	in_pool = function (self, args) return false end,
	elle_tail = { x = 7, y = 0 },
	resident_colour = HEX("ffa747"),
	slime_upgrade = {
		card = "elle_r_elle_cheshire",
		can_use = function(self, card) return #SMODS.find_card("j_elle_cassie")>0 and card.ability.extra.count>=card.ability.extra.req end,
		loc_vars = function(self, card) return {
			localize(ellejokers.mod_data.config.nsfw and "elle_furry_eat" or "elle_furry_destroy"),
			card.ability.extra.req,
			card.ability.extra.count
		} end,
		calculate = function(self, card)
			G.GAME.pool_flags.elle_cassie_death = true
			SMODS.destroy_cards(SMODS.find_card("j_elle_cassie")[1])
		end,
		values = function(self, card) return {
			xmult = 1+(card.ability.extra.mult/card.ability.extra.mult_mod*G.P_CENTERS.elle_r_elle_cheshire.config.extra.xmult_mod),
			eaten = card.ability.extra.eaten
		} end
	},
	update = function(self, card, dt) ellejokers.furry_sprite(card) end,
	set_ability = function(self, card, initial, delay_sprites) ellejokers.furry_sprite(card) end
}

furry.calculate = function(self, card, context)
	if context.before and #G.hand.cards > 0 then
		local target = pseudorandom_element(G.hand.cards,"elle_furry_eat")
		SMODS.destroy_cards(target)
		G.E_MANAGER:add_event(Event({func=function()
			card.ability.extra.eaten = card.ability.extra.eaten + 1
			card.ability.extra.count = card.ability.extra.count + 1
		return true end}))

		return {
			message = "+1",
			sound = "slice1"
		}
	end

	if context.joker_main and card.ability.extra.mult ~= 0 then
		return {
			mult = card.ability.extra.mult
		}
	end

	if context.end_of_round and context.main_eval and card.ability.extra.eaten > 0 and not context.retrigger_joker then
		local mod = card.ability.extra.eaten * card.ability.extra.mult_mod
		
		card.ability.extra.mult = card.ability.extra.mult + mod
		
		G.E_MANAGER:add_event(Event({func=function()
			card.ability.extra.eaten = 0

			if ellejokers.mod_data.config.nsfw then
				card.ability.extra.anim_timer = 0.5
				--play_sound("elle_burp")
			end
		return true end}))

		return {
			message = localize { type = 'variable', key = 'a_mult', vars = { mod } },
			colour = G.C.MULT
		}
	end
end