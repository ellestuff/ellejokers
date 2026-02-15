local combat = SMODS.Joker {
	key = 'combat',
	blueprint_compat = false,
	config = { extra = { hp = 10, max_hp = 10, heal = 4, xblind = 0.9, odds = 2 } },
	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_combat')
		return { vars = {
			card.ability.extra.xblind,
			numerator, denominator,
			card.ability.extra.heal,
			card.ability.extra.hp,
			card.ability.extra.max_hp,
		}
	} end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 6, y = 5 },
	cost = 10
}

combat.calculate = function (self, card, context)
	if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
		return {
			message = "Heal!",
			func = function()
				card.ability.extra.hp = math.min(card.ability.extra.hp + card.ability.extra.heal, card.ability.extra.max_hp)
			end
		}
	end
end

combat.slime_active = {
	calculate = function(self, card)
		if SMODS.pseudorandom_probability(card, 'elle_combat', 1, card.ability.extra.odds) then
			card.ability.extra.hp = card.ability.extra.hp - 1
			card:juice_up(0.4)
			SMODS.calculate_effect({message = "-1 HP", colour = G.C.RED}, card)
		else
			G.GAME.blind.chips = G.GAME.blind.chips * card.ability.extra.xblind
			G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
			SMODS.juice_up_blind()
			SMODS.calculate_effect({message = "X"..card.ability.extra.xblind, colour = G.C.FILTER}, card)
		end

		if G.GAME.chips >= G.GAME.blind.chips then
			G.STATE = G.STATES.HAND_PLAYED
			G.STATE_COMPLETE = true
			end_round()
		end

		if card.ability.extra.hp <= 0 then
			card:juice_up(.4,.4)
			card:start_dissolve({HEX("fd5f55")}, nil, 1.6)
			SMODS.destroy_cards(card)
			SMODS.calculate_effect({ remove = true }, card)
		end
	end,
	
	can_use = function(self, card)
		return G.STATE == G.STATES.SELECTING_HAND and card.ability.extra.hp > 0 and G.GAME.chips < G.GAME.blind.chips
	end,
	
	should_close = function(self, card) return G.GAME.chips >= G.GAME.blind.chips or card.ability.extra.hp <= 0 end
}

--#region Shader stuff
local bubbles = love.graphics.newImage( love.image.newImageData(NFS.newFileData( ellejokers.mod_data.path .. "assets/extra_images/bubbles.png") ) )

SMODS.Shader {
	key = 'combat',
	path = 'combat.fs',
	
	send_vars = function(self, sprite, card)
		return {
			dims = {61,11},
			pos = {5,79},
			hpFac = sprite.ability.extra.hp/sprite.ability.extra.max_hp,
			bubbles = bubbles
		}
	end
} 

SMODS.DrawStep {
	key = "elle_combat",
	order = 1,
	func = function(self, layer)
		if self.config.center_key == "j_elle_combat" then
			self.children.center:draw_shader('elle_combat', nil, self.ARGS.send_to_shader)
		end
	end,
	conditions = { vortex = false, facing = 'front' }
}
--#endregion