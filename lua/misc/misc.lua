SMODS.Tag {
	key = "rebecca",
	atlas = "tag",
	pos = {x=0,y=0},
	in_pool = function(self, args)
		return next(SMODS.find_card("j_elle_rebecca"))
	end,
	loc_vars = function (self, info_queue, tag)
		info_queue[#info_queue+1] = G.P_CENTERS.j_elle_rebecca
	end,
	apply = function(self, tag, context)
		if context.type == 'immediate' then
			tag:yep('Restocked!', G.C.MONEY, function()
				G.GAME.elle_popup_shops.rebecca.reset_on_open = true
				return true
			end)
			tag.triggered = true
		end
	end
}

SMODS.Tag {
	key = "spamton",
	atlas = "tag",
	pos = {x=0,y=1},
	in_pool = function(self, args)
		return next(SMODS.find_card("j_elle_spamton"))
	end,
	loc_vars = function (self, info_queue, tag)
		info_queue[#info_queue+1] = G.P_CENTERS.j_elle_spamton
		return { vars = { colours = {HEX("ffaec9"),HEX("fff200")} } }
	end,
	apply = function(self, tag, context)
		if context.type == 'immediate' then
			tag:yep('Restocked!', G.C.MONEY, function()
				G.GAME.elle_popup_shops.spamton.reset_on_open = true
				return true
			end)
			tag.triggered = true
		end
	end
}

SMODS.Tag {
	key = "resident",
	min_ante = 2,
	atlas = "tag",
	pos = { x = 1, y = 1 },
	loc_vars = function(self, info_queue, tag)
		info_queue[#info_queue + 1] = G.P_CENTERS.p_elle_resident
	end,
	apply = function(self, tag, context)
		if context.type == 'new_blind_choice' then
			local lock = tag.ID
			G.CONTROLLER.locks[lock] = true
			tag:yep('+', G.C.SECONDARY_SET.elle_Resident, function()
				local booster = SMODS.create_card { key = 'p_elle_resident', area = G.play }
				booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
				booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
				booster.T.w = G.CARD_W * 1.27
				booster.T.h = G.CARD_H * 1.27
				booster.cost = 0
				booster.from_tag = true
				G.FUNCS.use_card({ config = { ref_table = booster } })
				booster:start_materialize()
				G.CONTROLLER.locks[lock] = nil
				return true
			end)
			tag.triggered = true
			return true
		end
	end
}

SMODS.Sticker {
	key = "protected",
	atlas = "stickers",
	badge_colour = HEX("fd5f55"),
	rate = 0,
	calculate = function(self, card, context)
		if card.area == G.jokers and ((context.joker_type_destroyed and context.card == card) or context.selling_self or (context.setting_ability and context.other_card == card and not context.unchanged)) then
			-- KILL.
			G.STATE = G.STATES.GAME_OVER
			if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then
				G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
			end
			G:save_settings()
			G.FILE_HANDLER.force = true
			G.STATE_COMPLETE = false
		end
	end
}

-- Voucher behaviour is in the hooks below
SMODS.Voucher {
	key = "mixup",
	atlas = "vouchers",
	pos = {x=0,y=0},
	cost = 10
}
SMODS.Voucher {
	key = "breakthrough",
	atlas = "vouchers",
	pos = {x=1,y=0},
	cost = 10,
	requires = {"v_elle_mixup"}
}

SMODS.Voucher {
	key = 'sleepshopper',
	atlas = "vouchers",
	pos = { x = 0, y = 1 },
	config = { extra = { rate = 4 } },
	redeem = function(self, card)
		G.E_MANAGER:add_event(Event({
			func = function()
				G.GAME.elle_resident_rate = card.ability.extra.rate
				return true
			end
		}))
	end
}

SMODS.Voucher {
	key = 'friendship',
	atlas = "vouchers",
	requires = {"v_elle_slumber"},
	pos = { x = 1, y = 1 },
	config = { extra = { slots = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.slots } }
	end,
	redeem = function(self, card)
		G.E_MANAGER:add_event(Event({
			func = function()
				G.elle_resident_area:change_size(1)
				return true
			end
		}))
	end
}

local rarity1 = {[1]=true,[2]=true,[3]=true}	-- Rarities to check for, formatted for easier checking
local rarity2 = {1,2,3} 						-- Rarities to pick from

-- Make the rarities equally likely
local pr_hook = SMODS.poll_rarity
function SMODS.poll_rarity(_pool_key, _rand_key, ...)
	local pr = pr_hook(_pool_key, _rand_key, ...)
	return (G.GAME.used_vouchers["v_elle_mixup"] and rarity1[pr]) and pseudorandom_element(rarity2, "elle_rarity_mix") or pr
end

-- 1 in 20 chance for shop Jokers to be Legendary
local gcp_hook = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
	if G.GAME.used_vouchers["v_elle_breakthrough"] and _type == 'Joker' and _append == 'sho' and pseudorandom('ellerar'..G.GAME.round_resets.ante.._append, 1, 20)==1 then _legendary = true end
	return gcp_hook(_type, _rarity, _legendary, _append)
end

function ellejokers.table_keys(t)
	local r = {}
	for k,_ in pairs(t) do
		r[#r+1] = k
	end
	return r
end

-- Borrowed from https://github.com/real-niacat/Aquillarri/blob/70b99dc8dec14a0e4e8c4ca5e56c259fa8bb32fd/items/p_utils.lua#L236-L241
function ellejokers.get_movable_pixel_pos(mov)
    return {
        (G.ROOM.T.x + mov.VT.x + mov.VT.w * 0.5) * (G.TILESIZE * G.TILESCALE),
        (G.ROOM.T.y + mov.VT.y + mov.VT.h * 0.5) * (G.TILESIZE * G.TILESCALE),
    }
end