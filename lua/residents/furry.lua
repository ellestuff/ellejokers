local furry = ellejokers.Resident {
	key = 'furry',
	pos = { x = 0, y = 1 },
	config = { extra = {mult_mod = 2, mult = 0, eaten = 0} },
	loc_vars = function(self, info_queue, card) return { vars = {
        localize(ellejokers.mod_data.config.nsfw and "elle_furry_eat" or "elle_furry_destroy"),
        card.ability.extra.mult_mod,
        localize(ellejokers.mod_data.config.nsfw and "elle_furry_eaten" or "elle_furry_destroyed"),
        card.ability.extra.eaten,
        card.ability.extra.mult
    }} end,
	in_pool = function (self, args) return false end
}

furry.calculate = function(self, card, context)
    if context.before and #G.hand.cards > 0 then
        local target = pseudorandom_element(G.hand.cards,"elle_furry_eat")
        SMODS.destroy_cards(target)
        card.ability.extra.eaten = card.ability.extra.eaten + 1
        
        return {
            message = "+1"
        }
    end

    if context.joker_main and card.ability.extra.mult ~= 0 then
        return {
            mult = card.ability.extra.mult
        }
    end

    if context.end_of_round and context.main_eval and card.ability.extra.eaten > 0 then
        local mod = card.ability.extra.eaten * card.ability.extra.mult_mod
        
        card.ability.extra.mult = card.ability.extra.mult + mod
        card.ability.extra.eaten = 0

        return {
            message = localize { type = 'variable', key = 'a_mult', vars = { mod } },
            colour = G.C.MULT
        }
    end
end

--[[ellejokers.Resident {
	key = 'chloe',
	set_badges = function(self, card, badges) if (self.discovered) then badges[#badges+1] = slimeutils.table_create_badge(elle_badges.mall) end end,
	config = { extra = { chip_mod = 8, chips = 0, count = 0, req = 25 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chip_mod, card.ability.extra.chips } }
	end,
	atlas = 'residents',
	pos = { x = 0, y = 0 },
	cost = 5,
    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            
            local face = context.other_card:is_face()
            if face then card.ability.extra.count = card.ability.extra.count + 1 end
            
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chip_mod } },
                colour = not face and G.C.CHIPS
            }
        end
        if context.end_of_round then
            card.ability.extra.chips = 0
        end
        if context.joker_main then
            if card.ability.extra.chips ~= 0 then
                return {
                    chips = card.ability.extra.chips,
                }
            end
        end
    end,
    slime_upgrade = {
        card = "r_elle_furry",
        can_use = function(self, card) return card.ability.extra.count>=card.ability.extra.req end,
        loc_vars = function(self, card) return { card.ability.extra.req, card.ability.extra.count } end,
        bypass_lock = true
    }
}]]