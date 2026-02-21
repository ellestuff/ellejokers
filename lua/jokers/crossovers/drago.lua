local drago = SMODS.Joker {
	key = 'drago',
	set_badges = function(self, card, badges) if (self.discovered) then badges[#badges+1] = slimeutils.table_create_badge(elle_badges.friends) end end,
	config = { extra = { upgr_count = 12 } },
	loc_vars = function(self, info_queue, card)
		local ench = G.GAME.current_round.elle_drago_ench or 'm_bonus'

		info_queue[#info_queue+1] = {
			set = "Other", key = "elle_cameo", specific_vars = {"Drago","@dragothedemon.bsky.social"},
			slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=1} }
		}
		info_queue[#info_queue+1] = G.P_CENTERS[ench]
		return { vars = { localize({type = 'name_text', key = ench, set = 'Enhanced'}) } } end,
	rarity = 2,
	atlas = 'jokers',
	pos = { x = 0, y = 2 },
	cost = 6,
	blueprint_compat = false,
	slime_desc_icon = { atlas = "elle_cornericons", pos = {x=0,y=1} }
}

drago.calculate = function(self, card, context)
	if context.check_enhancement and context.other_card.config.center.key == "m_wild" then
		return{
			[G.GAME.current_round.elle_drago_ench] = true
		}
	end
end


local get_enchs_hook = SMODS.get_enhancements
function SMODS.get_enhancements(...)
	local list = get_enchs_hook(...)
	if #SMODS.find_card("j_elle_drago")>0 then list.m_wild = nil end
	return list
end


function ellejokers.reset_game_globals.drago(run_start)
	local pool = {}
	for _, v in ipairs(G.P_CENTER_POOLS.Enhanced) do
		if v.key ~= "m_wild" then pool[#pool+1] = v.key end
	end
	G.GAME.current_round.elle_drago_ench = SMODS.poll_enhancement({key = "elle_drago", guaranteed=true, options = pool})
end

local function get_wild_count()
	local c = 0
	if G.playing_cards then
		for _, playing_card in ipairs(G.playing_cards) do
			if SMODS.has_enhancement(playing_card, 'm_wild') then c = c + 1 end
		end
	end
	return c
end

drago.slime_upgrade = {
	card = "j_elle_cheshdrago",
	values = function(self, card) return {
		xmult = #SMODS.find_card("j_elle_cheshire", false)>0 and SMODS.find_card("j_elle_cheshire", false)[1].ability.extra.Xmult or 1,
		used = #SMODS.find_card("j_elle_cheshire", false)>0 and SMODS.find_card("j_elle_cheshire", false)[1].ability.extra.used or false
	} end,
	can_use = function(self, card)
		return #SMODS.find_card("j_elle_cheshire", false)>0 and (get_wild_count()>=card.ability.extra.upgr_count)
	end,
	loc_vars = function (self, card) return { card.ability.extra.upgr_count, get_wild_count() } end,
	calculate = function(self, card)
		local chesh = SMODS.find_card("j_elle_cheshire")[1]
		
		if chesh then
			G.E_MANAGER:add_event(Event({func = function()
				chesh:juice_up(.4,.4)
				SMODS.destroy_cards(chesh)
				SMODS.calculate_effect({ remove = true })
			return true end }))
		end
	end,
	bypass_lock = true
}