-- netskie implementation test
SMODS.Joker {
	key = 'kingslime',
	config = { extra = { chips = 10, disguise_key = "j_elle_elle" } },
	loc_vars = function(self, info_queue, card)
		--[[info_queue[#info_queue+1] = G.P_CENTERS.m_elle_slime
		return { vars = { card.ability.extra.chips } }]]
		
		if card.area == G.Jokers or card.area.config.collection or card.in_disguise or not card.ability.extra.disguise_key then
			card.in_disguise = false
			return { vars = { card.ability.extra.chips } }
		end

		card.in_disguise = true
		
		local center = G.P_CENTERS[card.ability.extra.disguise_key]
		
		local vars = SMODS.shallow_copy(card.ability)
		card.ability = center.config
		
		local r = center.loc_vars and center:loc_vars(info_queue,card) or nil
		
		if not r then
			local ability = copy_table(center.config)
			ability.set = "Joker"
			ability.name = center.name
			ability.x_mult = center.config.Xmult or center.config.x_mult
			if ability.name == "To Do List" then
				ability.to_do_poker_hand = "High Card" -- fallback
			end

			r = {vars=Card.generate_UIBox_ability_table({ ability = ability, config = { center = center }, bypass_lock = true }, true)}
		end
		card.ability = vars
		r.key = r.key or center.key
		
		card.in_disguise = false
		return r
	end,
	set_ability = function(self, card, initial, delay_sprites)
		local c = pseudorandom_element(G.P_CENTER_POOLS["Joker"],"elle_netskietest")
		print(c.key)
		card.ability.extra.disguise_key = c.key
		card.base_cost = c.cost
		card:set_cost()
	end,
	update = function(self, card, dt)
		if card.ability.extra.disguise_key and card.area.config.collection then
			card.ability.extra.disguise_key = nil
		end
		
		local c = card.ability.extra.disguise_key and G.P_CENTERS[card.ability.extra.disguise_key] or self
		
		if card.children.center.atlas.key ~= c.atlas then
			local atlas = G.ASSET_ATLAS[c.atlas or "Joker"] or G.ANIMATION_ATLAS[c.atlas or "Joker"]
			card.children.center.atlas = atlas
			card.children.center:set_sprite_pos(c.pos)
			
			if c.soul_pos then
				card.children.floating_sprite.atlas = atlas
				card.children.floating_sprite:set_sprite_pos(c.soul_pos)
			end
		end
	end,
	add_to_deck = function(self,card,from_debuff)
		card.ability.extra.disguise_key = nil
		card.base_cost = self.cost
		card:set_cost()
	end,
	rarity = 1,
	atlas = 'jokers',
	pos = { x = 2, y = 0 },
	soul_pos = { x = 3, y = 0 },
	blueprint_compat = true,
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card,'m_elle_slime') and context.other_card:is_face() then
			context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
			return {
				message = localize("k_upgrade_ex")
			}
		end
	end,
	--enhancement_gate = 'm_elle_slime'
}