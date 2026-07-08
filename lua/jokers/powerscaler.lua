local powerscaler = SMODS.Joker {
	key = 'powerscaler',
	blueprint_compat = true,
	config = { extra = { xmult_mod = .75 } },
	loc_vars = function(self, info_queue, card) 
		return { vars = { card.ability.extra.xmult_mod, G.GAME.elle_upgrade_count*card.ability.extra.xmult_mod + 1 } }
	end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 5, y = 1 },
	cost = 9
}

powerscaler.calculate = function(self, card, context)
	if context.slime_upgrade then
		return { message = localize("k_upgrade_ex") }
	end

	if context.joker_main and card.ability.extra.xmult ~= 1 then
		return { xmult = G.GAME.elle_upgrade_count*card.ability.extra.xmult_mod + 1 }
	end
end

local igo_hook = Game.init_game_object
function Game:init_game_object()
	local g = igo_hook(self)
	g.elle_upgrade_count = 0
	return g
end

ellejokers.calculate.powerscaler = function(context)
	if context.slime_upgrade then
		G.GAME.elle_upgrade_count = G.GAME.elle_upgrade_count + 1
	end
end