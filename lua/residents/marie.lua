ellejokers.marie_rarities = {"Common", "Uncommon", "Rare"}

function ellejokers.get_marie_pool()
	local pool = {}

	local pool_check = {}

	for _,v in ipairs(ellejokers.marie_rarities) do
		local p = SMODS.get_clean_pool('Joker',v)
		for _,v2 in ipairs(p) do
			pool_check[v2] = true
		end
	end

	for i,j in ipairs(G.P_CENTER_POOLS.Joker) do
		local inpool = not j.no_collection and j.discovered and pool_check[j.key] and not j.elle_no_marie
		pool[#pool+1] = inpool and j or nil
	end

	return pool
end

local pool = {}

function ellejokers.create_UIbox_marie(card)
	G.GAME.elle_popup_shop_open = "marie"

	local deck_tables = {}

	G.elle_marie_collection = {}
	for j = 1, 3 do
		G.elle_marie_collection[j] = CardArea(
			G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
			5*G.CARD_W,
			0.95*G.CARD_H, 
			{card_limit = 5, type = 'title', highlight_limit = 1, highlighted_limit = 1, collection = true, elle_marie = true, elle_marie_card = card})
		table.insert(deck_tables, 
		{n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
			{n=G.UIT.O, config={object = G.elle_marie_collection[j]}}
		}}
		)
	end

	pool = ellejokers.get_marie_pool()

	for i = 1, 5 do
		for j = 1, #G.elle_marie_collection do
			local center = pool[i+(j-1)*5]
			local card = Card(G.elle_marie_collection[j].T.x + G.elle_marie_collection[j].T.w/2, G.elle_marie_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
			card.states.focus.can = true
			G.elle_marie_collection[j]:emplace(card)
		end
	end

	local joker_options = {}
	for i = 1, math.ceil(#pool/(5*#G.elle_marie_collection)) do
		table.insert(joker_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#pool/(5*#G.elle_marie_collection))))
	end

	local t = {
		{n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}, 
		{n=G.UIT.R, config={align = "cm"}, nodes={
			create_option_cycle({options = joker_options, w = 4.5, cycle_shoulders = true, opt_callback = 'elle_marie_collection_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
		}},
		{ n=G.UIT.R, config={align = "cm", minw = 7.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.ORANGE, button = "exit_overlay_menu", shadow = true}, nodes={
			{ n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
				{ n=G.UIT.T, config={text = "Back", scale = 0.5, colour = G.C.UI.TEXT_LIGHT} }
	}}}}}

	return create_UIBox_generic_options({
		no_back = true,
		contents = t
	})
end

G.FUNCS.elle_marie_collection_page = function(args)
	if not args or not args.cycle_config then return end

	for j = 1, #G.elle_marie_collection do
		for i = #G.elle_marie_collection[j].cards,1, -1 do
			local c = G.elle_marie_collection[j]:remove_card(G.elle_marie_collection[j].cards[i])
			c:remove()
			c = nil
		end
	end
	for i = 1, 5 do
		for j = 1, #G.elle_marie_collection do
			local center = pool[i+(j-1)*5 + (5*#G.elle_marie_collection*(args.cycle_config.current_option - 1))]
			if not center then break end
			local card = Card(G.elle_marie_collection[j].T.x + G.elle_marie_collection[j].T.w/2, G.elle_marie_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
			card.sticker = get_joker_win_sticker(center)
			G.elle_marie_collection[j]:emplace(card)
		end
	end
end

ellejokers.Resident {
	key = 'marie',
	pos = { x = 1, y = 3 },
	config = { extra = { active = true } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.j_ring_master
		return {vars = {localize(card.ability.extra.active and "elle_active_available" or "elle_active_used")}}
	end,
	resident_buttons = {{
		can_use = function(self, card) return card.ability.extra.active end,
		use = function(self,card) G.FUNCS.overlay_menu({ definition = ellejokers.create_UIbox_marie(card) }) end,
		colour = HEX("ff53a9"),
		scale = 2,
		close = true
	}},
	draw = function(self, card, layer)
		if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
			card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
		end
	end,
	weight = 0.05,
	discovered = true,
	in_pool = function (self, args) return false end,
	calculate = function(self, card, context)
		if (context.ante_change and not context.blueprint) then
			card.ability.extra.active = true
			return { message = localize("elle_active_available") }
		end
	end
}

local ch_hook = CardArea.can_highlight
function CardArea:can_highlight()
	return self.config.type == 'title' and self.config.elle_marie or ch_hook(self)
end

local ath_hook = CardArea.add_to_highlighted
function CardArea:add_to_highlighted(card, silent)
	if self.config.elle_marie then
		-- Iterate through all areas
		for i, v in ipairs(G.elle_marie_collection) do
			if #v.highlighted >= v.config.highlighted_limit then 
				v:remove_from_highlighted(v.highlighted[1])
			end
		end
		self.highlighted[#self.highlighted+1] = card
		card:highlight(true)
		if not silent then play_sound('cardSlide1') end
	else
		ath_hook(self,card,silent)
	end
end

local function create_marie_button_ui(card,marie)
	local button = {{
		n = G.UIT.R,
		config = {
			align = "cm"
		},
		nodes = {
			{ n = G.UIT.R,
			config = {
				colour = HEX("ff53a9"),
				align = 'cm',
				padding = 0.15,
				r = 0.08,
				hover = true,
				shadow = true,
				button = 'elle_marie_button',
				ref_card = card
			},
			nodes = {
				{ n = G.UIT.R, config = {minh=.15}},
				{ n = G.UIT.R, nodes = {
					{ n = G.UIT.T, config = { text = localize("b_select"), scale = 0.4 } }
				}}
			}
	}}}}

	return UIBox{
		definition = {
			n = G.UIT.ROOT,
			config = {
				colour = G.C.CLEAR,
				padding = 0.1,
				align = "cm"
			},
			nodes = button
		},
		config = {
			align = 'bm',
			major = card,
			parent = card,
			offset = { x = 0, y = -.5 }
		}
	}
end

function G.FUNCS.elle_marie_button(e)
	local card = e.config.ref_card
	local canbuy = G.FUNCS.check_for_buy_space(card)
	if canbuy then
		G.FUNCS.exit_overlay_menu()
		SMODS.add_card({key = card.config.center.key})
		card.area.config.elle_marie_card.ability.extra.active = false
	end
end

SMODS.DrawStep {
	key = 'elle_marie_button',
	order = -10, -- before the Card is drawn
	func = function(card, layer)
		if card.children.elle_marie_button then
			card.children.elle_marie_button:draw()
		end
	end
}

local highlight_ref = Card.highlight
function Card.highlight(self, is_highlighted)
	if is_highlighted and self.area.config.elle_marie then
		self.children.elle_marie_button = create_marie_button_ui(self, self.area.config.elle_marie_card)
	elseif self.children.elle_marie_button then
		self.children.elle_marie_button:remove()
		self.children.elle_marie_button = nil
	end

	return highlight_ref(self, is_highlighted)
end

-- remove showman from marie's shop
SMODS.Joker:take_ownership('ring_master', {elle_no_marie = true}, true)