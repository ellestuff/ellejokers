-- copied from entropy lol
local function get_by_sortid(id)
	for i, v in pairs(G.jokers.cards) do
		if v.sort_id == id then return v end
	end
end

ellejokers.Resident {
	key = 'p41',
	pos = { x = 2, y = 1 },
	config = { extra = { count = 2, targets = {} } },
	resident_colour = HEX("40aeff"),
	loc_vars = function(self, info_queue, card)
		local ret = { vars = { "#", card.ability.extra.count }, bio_key = G.P_CENTERS.elle_r_elle_cheshire.discovered and self.key.."_chesh" or nil }

		-- Copied from VanillaRemade Brainstorm
		if card.area and card.area == G.elle_resident_area and #card.ability.extra.targets>0 then
			local nodelist = {}
			
			for i, v in ipairs(card.ability.extra.targets) do
				local j = get_by_sortid(v)
				if j and j.area == G.jokers then
					nodelist[#nodelist+1] = {
						n = G.UIT.R,
						config = { ref_table = card, align = "m", colour = mix_colours(G.C.BLUE, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
						nodes = {
							{ n = G.UIT.T, config = { text = ' ' .. localize({type = 'name_text', key = j.config.center_key, set = 'Joker'}) .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
						}
					}
				end
			end
			
			local main_end = {
				{
					n = G.UIT.C,
					config = { align = "bm", minh = 0.4, padding = 0.1 },
					nodes = nodelist
				}
			}
			if #nodelist>0 then ret.main_end = main_end end
		end
		
		return ret
	end,
	calculate = function(self, card, context)
		ret = {}
		if context.setting_blind and not context.retrigger_joker then
			card.ability.extra.targets = {}

			list = {}
			for i, v in ipairs(G.jokers.cards) do
				if v.config.center.blueprint_compat then list[#list+1] = v end
			end
			
			for i = 1, card.ability.extra.count do
				local ret = pseudorandom_element(list,"elle_prototypes",{in_pool = function(v, args)
					return v.config.center.blueprint_compat
				end})
				if ret then
					card.ability.extra.targets[#card.ability.extra.targets+1] = ret.sort_id
					for j, v in ipairs(list) do
						if v == ret then list[j]=nil break end
					end
				end
			end
			
			SMODS.calculate_effect({ message_card = card,
				message = localize("elle_41_activate"),
			}, card)
		end
	
		for _, v in ipairs(card.ability.extra.targets) do
			ret[#ret+1] = SMODS.blueprint_effect(card, get_by_sortid(v), context)
		end
		return SMODS.merge_effects(ret)
	end,
	elle_tail = {x = 4, y = 1},
}