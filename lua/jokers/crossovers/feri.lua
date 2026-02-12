local feri = SMODS.Joker {
	key = 'feri',
	set_badges = function(self, card, badges) if (self.discovered) then badges[#badges+1] = slimeutils.table_create_badge(elle_badges.friends) end end,
	config = { extra = { mult = 2, upgrade = {req = 20, count = 0} } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_crossover", specific_vars = {"That Azazel Fire","@thatazazelfire.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=0} }
		}
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 2,
	atlas = 'jokers',
	pos = { x = 6, y = 5 },
	cost = 6,
	blueprint_compat = true,
	slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=0} }
}

feri.calculate = function(self, card, context)
	if context.individual and context.cardarea == G.play and context.other_card:is_suit("Hearts") then
		context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) +
			card.ability.extra.mult
		if #SMODS.find_card("j_elle_fallen", false)>0 then card.ability.extra.upgrade.count = card.ability.extra.upgrade.count + 1 end
		return {
			message = localize('k_upgrade_ex'),
			colour = G.C.MULT
		}
	end
end

feri.slime_upgrade = {
	card = "j_elle_ferisophie",
	values = function(self, card) return {charges = #SMODS.find_card("j_elle_fallen", false)>0 and SMODS.find_card("j_elle_fallen", false)[1].ability.extra.charges*4 or 0} end,
	can_use = function(self, card) return #SMODS.find_card("j_elle_fallen", false)>0 and (card.ability.extra.upgrade.count>=card.ability.extra.upgrade.req) end,
	loc_vars = function (self, card) return { card.ability.extra.upgrade.req, card.ability.extra.upgrade.count } end,
	calculate = function(self, card)
		local soph = SMODS.find_card("j_elle_fallen")[1]
		
		if soph then
			G.E_MANAGER:add_event(Event({func = function()
				soph:juice_up(.4,.4)
				SMODS.destroy_cards(soph)
				SMODS.calculate_effect({ remove = true })
			return true end }))
		end
	end
}