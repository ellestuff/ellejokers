local jessingit = SMODS.Joker {
	key = 'jessingit',
	set_badges = function(self, card, badges) if (self.discovered) then badges[#badges+1] = slimeutils.table_create_badge(elle_badges.poly) end end,
	config = { extra = { xmult = 1.5 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_cameo", specific_vars = {"Jess","@soup587.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=1,y=0} }
		}
		info_queue[#info_queue+1] = G.P_CENTERS.m_elle_jess
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 6, y = 3 },
	cost = 9,
	blueprint_compat = true,
	enhancement_gate = 'm_elle_jess',
	slime_desc_icon = { atlas = "elle_cornericons", pos = {x=1,y=0} }
}

jessingit.calculate = function (self, card, context)
	if context.individual and context.cardarea == G.hand and not context.end_of_round and SMODS.has_enhancement(context.other_card, "m_elle_jess") then
		if context.other_card.debuff then
			return {
				message = localize('k_debuffed'),
				colour = G.C.RED
			}
		else
			local alljess = true
			for _, v in ipairs(context.scoring_hand) do
				alljess = alljess and SMODS.has_enhancement(v, "m_elle_jess")
			end

			if alljess then
				return {
					x_mult = card.ability.extra.xmult
				}
			end
		end
	end
end