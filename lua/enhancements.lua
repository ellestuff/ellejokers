-- Slime Enhancement
SMODS.Enhancement {
	key = 'slime',
	atlas = 'enhancers',
	pos = { x = 0, y = 0 },
	config = { extra = { odds = 3, retriggers = 2 } },
	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'elle_slime_card')
		return { vars = { numerator, denominator, card.ability.extra.retriggers } }
	end,
	calculate = function(self, card, context)
		if context.repetition and SMODS.pseudorandom_probability(card, 'elle_slime_card', 1, card.ability.extra.odds) then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra.retriggers
			}
		end
	end
}

-- Jess Enhancement
SMODS.Enhancement {
	key = 'jess',
	atlas = 'enhancers',
	pos = { x = 1, y = 0 },
	config = { extra = { retrigger_count = 1, req = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.retrigger_count, card.ability.extra.req } }
	end,
	calculate = function(self, card, context)
		if context.repetition and context.cardarea == G.play then
			local retriggers = 0
			for i,v in ipairs(G.play.cards) do
				if (SMODS.has_enhancement(v, "m_elle_jess") or (SMODS.find_card("j_elle_jessclip")[1] and v:is_suit('Hearts', true))) and not v.debuff then retriggers = retriggers + 1 end
			end
			
			-- Jess Joker
			if SMODS.find_card("j_elle_jess")[1] then
				for i,v in ipairs(G.hand.cards) do
					if (SMODS.has_enhancement(v, "m_elle_jess") and not v.debuff) then retriggers = retriggers + 1 end
				end
			end
			
			retriggers = math.floor(retriggers/card.ability.extra.req)
			
			if retriggers > 0 then
				return {
					message = localize('k_again_ex'),
					repetitions = retriggers * card.ability.extra.retrigger_count
				}
			end
		end
	end
}

local function get_copycat_target(card)
	local pos = nil
	local target = nil
	
	for i, v in ipairs(card.area.cards) do
		pos = v == card and i or pos
		if pos and not target and not SMODS.get_enhancements(v)["m_elle_copycat"] then target = v end -- Doesn't use has_enhancement as it's used in a hook in that func
	end
	
	return pos, target
end

-- Copycat Enhancement
SMODS.Enhancement {
	key = 'copycat',
	atlas = 'enhancers',
	pos = { x = 1, y = 1 },
	config = { extra = { } },
	
	replace_base_card = true,
	no_rank = true,
	no_suit = true,
	always_scores = true,
	
	loc_vars = function(self, info_queue, card) return { vars = { } } end,
	calculate = function(self, card, context)
		if (card.area and card.area.cards) then
			local pos, target = get_copycat_target(card)
			
			if target then
				-- thanks to @somethingcom515 for the code
				local eval, post = eval_card(target, context)
				local ret = {}
				for k, v in pairs(eval) do
					if type(v) == 'table' and (k == 'playing_card' or k == 'enhancement' or k == 'end_of_round') then
						if not v.card or v.card == target then v.card = card end
						table.insert(ret, v)
					end
				end
				
				--if ret ~= {} then print(ret) end
				
				ret.card = card
				
				return SMODS.merge_effects(ret)
			end
		end
	end
}

local has_enhancement_hook = SMODS.has_enhancement
function SMODS.has_enhancement(card, key, ...)
    local r = has_enhancement_hook(card, key, ...)
	
	-- Messy ass jank code
    local enhancements = SMODS.get_enhancements(card)
    if enhancements["m_elle_copycat"] then
		local pos, target = get_copycat_target(card)
		if target and target.config.center.key == key then return true end
	end
    
	return r
end