local spam = SMODS.Joker {
	key = 'spamton',
	config = { extra = { cost = { reroll = 4 }, cards = { jokers = {}, consumables = {}, booster = {} } } },
	loc_vars = function(self, info_queue, card) return { vars = { colours = {HEX("ffaec9"),HEX("fff200")} } } end,
	rarity = 2,
	atlas = 'jokers',
	pos = { x = 6, y = 4 },
	cost = 5
}

-- Open shop
spam.slime_active = {
	calculate = function(self, card)
		G.FUNCS.overlay_menu({ definition = create_UIbox_spamton() })
	end,
	can_use = function(self, card) return true end,
	should_close = function(self, card) return true end,
	name = function(self, card) return localize("elle_joker_open") end
}

-- Restock shop
spam.calculate = function(self, card, context)
	if (context.ante_change) then
		G.GAME.elle_popup_shops.spamton.reset_on_open = true
		return { message = localize("elle_shop_restock") }
	end
end