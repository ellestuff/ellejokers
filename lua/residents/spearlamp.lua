-- Add lamp variants here :3
ellejokers.lamps = {
	{
		key_suffix = "_vivi",
		icon = { atlas = "elle_cornericons", pos = {x=1,y=1} },
		crossover = {
			set = "Other", key = "elle_crossover", specific_vars = {"Reverie","@critterror.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=1,y=1} }
		},
		badge = elle_badges.friends
	},
	{
		key_suffix = "_jess",
		icon = { atlas = "elle_cornericons", pos = {x=1,y=0} },
		crossover = {
			set = "Other", key = "elle_crossover", specific_vars = {"Jess","@soup587.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=1,y=0} }
		},
		badge = elle_badges.poly
	},
	{
		key_suffix = "_drago",
		icon = { atlas = "elle_cornericons", pos = {x=0,y=1} },
		crossover = {
			set = "Other", key = "elle_crossover", specific_vars = {"Drago","@dragothedemon.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=1} }
		},
		badge = elle_badges.friends
	}
}

local lamp = ellejokers.Resident {
	key = 'spearlamp',
	atlas = 'lamps',
	pos = { x = 0, y = 0 },
	loc_vars = function(self, info_queue, card)
		local lamp = ellejokers.lamps[card.ability.extra.variant-1] or {}
		
		info_queue[#info_queue+1] = lamp.crossover

		card.config.center.slime_desc_icon = lamp.icon

		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_vivian')
		return {
			vars = { card.ability.extra.count, self.config.extra.count, numerator, denominator },
			key = self.key..(lamp.key_suffix or ""),
			bio_key = card.ability.extra.variant>1 and self.key..(ellejokers.mod_data.config.nsfw and "_cameo_nsfw" or "_cameo") or nil
		}
	end,
	config = { extra = { count = 2, odds = 8, variant = 1 } },
	resident_colour = HEX("81cefd"),
	set_ability = function(self, card, initial, delay_sprites)
		-- 1 in 5 chance of silly lamp
		if pseudorandom("elle_do_lamp_tf",1,5)==1 then card.ability.extra.variant = pseudorandom("elle_lamp_tf",1,#ellejokers.lamps)+1 end
		if not slimeutils.card_obscured(card) then
			card.children.center:set_sprite_pos({x = card.ability.extra.variant-1, y = ellejokers.mod_data.config.nsfw and 1 or 0})
	end end,
	add_to_deck = function(self, card, from_debuff)
		if card.ability.extra.variant ~= 1 then check_for_unlock({type = "elle_lamp"}) end
	end,
	update = function(self, card, dt)
		if not slimeutils.card_obscured(card) then
			card.children.center:set_sprite_pos({x = card.ability.extra.variant-1, y = ellejokers.mod_data.config.nsfw and 1 or 0})
	end end
}

function lamp:calculate(card,context)
	-- Don't retrigger these!!!!
	if not context.retrigger_joker then
		-- Pick lamp card, can just be the card's table since it doesn't have to be saved after scoring
		if context.before then
			card.ability.extra.target = pseudorandom_element(context.scoring_hand,"e_lamp")
		end

		-- Forget the card
		if context.final_scoring_step then
			G.E_MANAGER:add_event(Event({func = function()
				card.ability.extra.target = nil
			return true end}))
		end

		-- Card scaling :)
		if context.end_of_round and context.main_eval then
			local reset = SMODS.pseudorandom_probability(card,'elle_lamp_reset',1,card.ability.extra.odds)
			card.ability.extra.count = reset and self.config.extra.count or card.ability.extra.count + self.config.extra.count
			return {message = localize(reset and 'k_reset' or 'k_upgrade_ex')}
		end
	end
	
	if context.repetition and context.cardarea == G.play and context.other_card == card.ability.extra.target then
		return {
			repetitions = card.ability.extra.count
		}
	end
end

SMODS.Shader {
	key = "lamp_shader",
	path = "lamp_shader.fs"
}

SMODS.ScreenShader {
	key = 'lamp_shader',
	shader = 'elle_lamp_shader',
	order = -1,
	send_vars = function(self)
		local lamp = SMODS.find_card('elle_r_elle_spearlamp')[1]
		local w,h = love.graphics.getDimensions()
		return {
			dims = {w,h},
			pos = ellejokers.get_movable_pixel_pos(lamp.ability.extra.target)
		}
	end,
	should_apply = function(self)
		local lamp = SMODS.find_card('elle_r_elle_spearlamp')[1]
		return lamp and lamp.ability.extra.target or false
	end
}