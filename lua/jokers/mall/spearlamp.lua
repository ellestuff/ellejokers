-- Add lamp variants here :3
ellejokers.lamps = {
	{
		badge = elle_badges.mall
	},
	{
		key_suffix = "_vivi",
		icon = { atlas = "elle_cornericons", pos = {x=1,y=1} },
		crossover = {
			set = "Other", key = "elle_crossover", specific_vars = {"Vivian","@critterror.bsky.social"},
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

local spearlamp = SMODS.Joker {
	key = 'spearlamp',
	set_badges = function(self, card, badges)
		if (self.discovered) then
			
			local var = ellejokers.lamps[card.ability.extra.variant]
			if var.badge then
				badges[#badges+1] = slimeutils.table_create_badge(var.badge)
			end
		end
	end,
	config = { extra = { variant = 1 } },
	loc_vars = function(self, info_queue, card)
		local var = ellejokers.lamps[card.ability.extra.variant]
		
		info_queue[#info_queue+1] = var.crossover

		info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime

		card.config.center.slime_desc_icon = var.icon
		
		return { vars = { }, key = self.key..(var.key_suffix or "") }
	end,
	atlas = 'lamps',
	pos = { x = 0, y = 0 },
	rarity = 2,
	cost = 6
}

spearlamp.calculate = function(self, card, context)
	if context.check_enhancement and (context.other_card.config.center.key == "m_steel" or context.other_card.config.center.key == "m_elle_slime") then
		return{
			m_steel = true,
			m_elle_slime = true
		}
	end
end

spearlamp.set_ability = function(self, card, initial, delay_sprites)
	-- 1 in 5 chance of silly lamp
	if pseudorandom("elle_do_lamp_tf",1,5)==1 then card.ability.extra.variant = pseudorandom("elle_lamp_tf",2,#ellejokers.lamps) end
	card.children.center:set_sprite_pos({x=card.ability.extra.variant-1 or 0,y=0})
end

spearlamp.set_sprites = function(self, card, front)
	local var = card and card.ability and card.ability.extra and card.ability.extra.variant or 1
	card.children.center:set_sprite_pos({x=var-1 or 0,y=0})
end

spearlamp.load = function(self, card, card_table, other_card)
	local var = card and card.ability and card.ability.extra and card.ability.extra.variant or 1
	card.children.center:set_sprite_pos({x=var-1 or 0,y=0})
end

spearlamp.add_to_deck = function(self, card, from_debuff)
	if card.ability.extra.variant ~= 1 then check_for_unlock({type = "elle_lamp"}) end
end