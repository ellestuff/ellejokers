SMODS.Tag {
	key = "rebecca",
	atlas = "tag",
	pos = {x=0,y=0},
	in_pool = function(self, args)
		return next(SMODS.find_card("j_elle_rebecca"))
	end,
	apply = function(self, tag, context)
		if context.type == 'immediate' then
            tag:yep('Restocked!', G.C.MONEY, function()
                G.GAME.elle_rebecca.reset_on_open = true
                return true
            end)
            tag.triggered = true
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

local rarity1 = {[1]=true,[2]=true,[3]=true}	-- Rarities to check for, formatted for easier checking
local rarity2 = {1,2,3} 						-- Rarities to pick from

-- Make the rarities equally likely
local pr_hook = SMODS.poll_rarity
function SMODS.poll_rarity(_pool_key, _rand_key, ...)
	local pr = pr_hook(_pool_key, _rand_key, ...)
	return (#SMODS.find_card("v_elle_mixup")>0 and rarity1[pr]) and pseudorandom_element(rarity2, "elle_rarity_mix") or pr
end

-- 1 in 20 chance for shop Jokers to be Legendary
local gcp_hook = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    if #SMODS.find_card("v_elle_breakthrough")>0 and _type == 'Joker' and _append == 'sho' and pseudorandom('ellerar'..G.GAME.round_resets.ante.._append, 1, 20)==1 then _legendary = true end
    return gcp_hook(_type, _rarity, _legendary, _append)
end