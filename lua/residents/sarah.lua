function ellejokers.create_UIbox_sarah(card)
	local key = SMODS.Suits[card.ability.extra.suit].card_key.."_"..SMODS.Ranks[tostring(card.ability.extra.rank)].card_key

	local c = SMODS.create_card({ key = "c_base", front = key })
	c.no_ui = true
	c.states.drag.can = false

	local test = {
		a = {'a','b','c'}
	}

	local suit_o
	for i, v in ipairs(SMODS.Suit.obj_buffer) do
		suit_o = v == card.ability.extra.suit and i or suit_o
	end

	local rank_o
	for i, v in ipairs(SMODS.Rank.obj_buffer) do
		rank_o = v == card.ability.extra.rank and i or rank_o
	end

	local t = {
		{ n = G.UIT.R, config = { minw=4, padding=-.1 }, nodes = {
			{ n = G.UIT.C, config = {padding = .1}, nodes = {
				{ n = G.UIT.C, config = { align = "cm" }, nodes = {{ n=G.UIT.O, config = {object = c} }}},
				{ n = G.UIT.C, config = { padding = -.1}, nodes = {
					{ n = G.UIT.C, config = { padding = .2 }, nodes = {
						{ n = G.UIT.R, config = { colour= G.C.WHITE, r = 0.1, minh=.5, align = 'cm' }, nodes = {
							{ n = G.UIT.T, config = {ref_table = card.ability.extra, ref_value = "suit", scale = .3, colour = G.C.UI.TEXT_DARK, func='elle_sarah_uitext' }},
							{ n = G.UIT.T, config = {text = ' act as ', scale = .3, colour = G.C.UI.TEXT_DARK }},
							{ n = G.UIT.T, config = {ref_table = card.ability.extra, ref_value = "rank", scale = .3, colour = G.C.IMPORTANT }},
							{ n = G.UIT.T, config = {text = 's', scale = .3, colour = G.C.IMPORTANT }}
						}},
						-- create_option_cycle({opt_callback = "elle_sarah_uisuit",
						-- 	options = SMODS.Suit.obj_buffer,
						-- 	current_option = suit_o,
						-- 	w = 3,
						-- 	no_pips = true,
						-- 	scale = 0.8,

						-- 	card = card,
						-- 	display_card = c
						-- }),
						SMODS.GUI.dropdown_select({
							options = SMODS.Suit.obj_buffer,
							close_on_select = true,
							max_menu_h = 4,
							callback = "elle_sarah_uisuit",
							minw = 2,
							display_card = c,
							ref_table = card.ability.extra,
							ref_value = "suit",
							align = "cl",
						}),
						SMODS.GUI.dropdown_select({
							options = SMODS.Rank.obj_buffer,
							close_on_select = true,
							max_menu_h = 4,
							callback = "elle_sarah_uirank",
							minw = 2,
							display_card = c,
							ref_table = card.ability.extra,
							ref_value = "rank",
							align = "cl",
						}),
						-- create_option_cycle({opt_callback = "elle_sarah_uirank",
						-- 	options = SMODS.Rank.obj_buffer,
						-- 	current_option = rank_o,
						-- 	w = 3,
						-- 	no_pips = true,
						-- 	scale = 0.8,

						-- 	card = card,
						-- 	display_card = c
						-- })
						{ n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.ORANGE, button = "exit_overlay_menu", shadow = true}, nodes={
							{ n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
								{ n=G.UIT.T, config={text = "Back", scale = 0.5, colour = G.C.UI.TEXT_LIGHT} }
	}}}}}}}}}}}}}
	return create_UIBox_generic_options({
		no_back = true,
		contents = t
	})
end

function G.FUNCS.elle_sarah_uitext(e)
	e.config.colour = G.C.SUITS[e.config.ref_table[e.config.ref_value]]
end

function G.FUNCS.elle_sarah_uisuit(e)
	G.E_MANAGER:add_event(Event({func = function()
		e.config.args_table.display_card:juice_up(.3,.3)
		SMODS.change_base(e.config.args_table.display_card, e.config.args_table.ref_table["suit"])
	return true end}))
end

function G.FUNCS.elle_sarah_uirank(e)
	G.E_MANAGER:add_event(Event({func = function()
		e.config.args_table.display_card:juice_up(.3,.3)
		SMODS.change_base(e.config.args_table.display_card, nil, e.config.args_table.ref_table["rank"])
	return true end}))
end

ellejokers.Resident {
	key = 'sarah',
	pos = { x = 3, y = 0 },
	config = { extra = { suit = 'Spades', rank = 'Ace' } },
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra.suit,
			card.ability.extra.rank,
			colours = {
				G.C.SUITS[card.ability.extra.suit]
			}
		}}
	end,
	resident_colour = HEX("81cefd"),
	resident_buttons = {
		{
			text = "Edit",
			can_use = function(self, card) return G.STATE ~= G.STATES.HAND_PLAYED end,
			use = function(self,card) G.FUNCS.overlay_menu({ definition = ellejokers.create_UIbox_sarah(card) }) end,
			colour = HEX("81cefd"),
			scale = 1.6,
			close = true
		}
	},
	set_ability = function(self, card, initial, delay_sprites)
		card.ability.extra.suit = pseudorandom_element(SMODS.Suit.obj_buffer,'elle_sarah_suit')
		card.ability.extra.rank = pseudorandom_element(SMODS.Rank.obj_buffer,'elle_sarah_rank')
	end,
	slime_upgrade = {
		card = "elle_r_elle_mint",
		can_use = function(self, card) return true end, -- idk what the actual condition should be
		loc_vars = function(self, card) return {} end,
		values = function(self, card) return {
			suit = card.ability.extra.suit,
			rank = card.ability.extra.rank
		} end
	}
}

-- Get actual ID, for use in Mint
local sarah_bypass = false
function ellejokers.sarah_get_id(card)
	sarah_bypass = true
	local r = card:get_id()
	sarah_bypass = false
	return r
end

-- Prevents Flush Fives
local during_hand_calc = false
local eph_hook = evaluate_poker_hand
function evaluate_poker_hand(_cards)
	during_hand_calc = true
	local text, loc_disp_text, poker_hands, scoring_hand, disp_text = eph_hook(_cards)
	during_hand_calc = false
	return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end

local gid_hook = Card.get_id
function Card:get_id()
	if not sarah_bypass and not during_hand_calc then
		local r
		-- Sarah
		if next(SMODS.find_card('elle_r_elle_sarah')) then
			for i,v in ipairs(SMODS.find_card('elle_r_elle_sarah')) do
				if self:is_suit(v.ability.extra.suit) then
					r = SMODS.Ranks[v.ability.extra.rank].id
				end
			end
		end

		-- Mint
		if next(SMODS.find_card('elle_r_elle_mint')) then
			for i,v in ipairs(SMODS.find_card('elle_r_elle_mint')) do
				if self:is_suit(v.ability.extra.suit) and SMODS.pseudorandom_probability(v, 'elle_mint_trigger',1,v.ability.extra.odds,nil,true) then
					r = SMODS.Ranks[v.ability.extra.rank].id
				end
			end
		end
		return r or gid_hook(self)
	end
	return gid_hook(self)
end