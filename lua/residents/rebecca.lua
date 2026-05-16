-- TO-DO:
--	- Dialogue stuff
--	- Sprite stuff
--	- Dialogue writing
--		- Mention shop info
--			- 1 Pack per ante
--		- Talk about the Café
--		- Explain how modifiers work

ellejokers.rebecca_modifiers = {}

ellejokers.Resident {
	key = 'rebecca',
	pos = { x = 1, y = 3 },
	config = { extra = { } },
	loc_vars = function (self, info_queue, card)
		local modkey = G.GAME.elle_popup_shops.rebecca.modifier
		local modifier = ellejokers.rebecca_modifiers[modkey]
		local mod_txt = 'elle_rebecca_modifier_'..modkey
		info_queue[#info_queue+1] = modkey ~= 'none' and {set='Other', key=mod_txt, vars=modifier.loc_vars and modifier:loc_vars() or nil} or nil

		return {
			vars = { localize({set='Other',key=mod_txt, type='name_text',vars=modifier.loc_vars and modifier:loc_vars() or nil}) }
		}
	end,
	calculate = function(self, card, context)
		if context.main_eval and context.ante_change and not context.retrigger_joker then
			G.GAME.elle_popup_shops.rebecca.reset_on_open = true
			ellejokers.set_rebecca_modifier(pseudorandom_element(ellejokers.table_keys(ellejokers.rebecca_modifiers),'elle_rebecca_modifier'))
			return { message = localize("elle_shop_restock") }
		end
	end,
	resident_buttons = {
		{
			text = function() return localize("elle_joker_open") end,
			can_use = function(self, card) return true end,
			use = function(self, card)
				G.FUNCS.overlay_menu({ definition = create_UIbox_becca() })
			end,
			colour = HEX("89ca80"),
			scale = 1.6,
			close = true
		}
	},
	resident_colour = HEX("89ca80"),
	elle_tail = {x = 2, y = 3},
}

--local becca_obj = Sprite(0,0,192,256,"rebecca",{x=0,y=0})

--#region Shop UI

-- Reroll shop while inside UI (targetting cardareas)
local function becca_visible_reroll(booster)
	modifier = ellejokers.rebecca_modifiers[G.GAME.elle_popup_shops.rebecca.modifier]

	-- Remove old cards
	for i,v in ipairs(ellejokers.popup_shop.shop_cardareas.rebecca) do
		for i2 = #G[v].cards,1, -1 do
			if (not booster and v == "elle_becca_shop_booster") then break end
			local c = G[v]:remove_card(G[v].cards[i])
			c:remove()
			c = nil
		end
	end

	-- Jokers
	for i = 1, 2 -#G.elle_becca_shop_jokers.cards do
		local t = modifier.joker and SMODS.shallow_copy(modifier:joker()) or {}
		t.set = t.set or "Joker"
		t.area = G.elle_becca_shop_jokers
		t.skip_materialize = true
		t.bypass_discovery_center = true

		
		local new_shop_card = SMODS.create_card(t)

		G.elle_becca_shop_jokers:emplace(new_shop_card)
		if modifier.cardfunc then modifier:cardfunc(new_shop_card) end
		new_shop_card:set_cost()
		create_shop_card_ui(new_shop_card)
		new_shop_card:juice_up()
	end
	-- Consumables
	for i = 1, 2-#G.elle_becca_shop_consumables.cards do
		local t = modifier.consumables and SMODS.shallow_copy(modifier:consumables()) or {}
		t.set = t.set or "Consumeables"
		t.area = G.elle_becca_shop_consumables
		t.skip_materialize = true
		t.bypass_discovery_center = true

		local new_shop_card = SMODS.create_card(t)
		G.elle_becca_shop_consumables:emplace(new_shop_card)
		if modifier.cardfunc then modifier:cardfunc(new_shop_card) end
		new_shop_card:set_cost()
		create_shop_card_ui(new_shop_card)
		
		new_shop_card:juice_up()
		--print("added consumable")
	end
	-- Booster pack
	if booster then
		for i = 1, 1-#G.elle_becca_shop_booster.cards do
			local t = modifier.booster and SMODS.shallow_copy(modifier:booster()) or {}
			t.set = t.set or "Booster"
			t.area = G.elle_becca_shop_booster
			t.skip_materialize = true
			t.bypass_discovery_center = true

			local new_shop_card = SMODS.create_card(t)
			G.elle_becca_shop_booster:emplace(new_shop_card)
			if modifier.cardfunc then modifier:cardfunc(new_shop_card) end
			new_shop_card:set_cost()
			create_shop_card_ui(new_shop_card)
			
			new_shop_card:juice_up()
			new_shop_card.T.h = new_shop_card.T.h*1.27
			new_shop_card.T.w = new_shop_card.T.w*1.27
			
			--print("added booster")
		end
	end
end

-- Shop UI
function create_UIbox_becca()
	--print(G.GAME.elle_popup_shops.rebecca.first_open)
	G.elle_becca_shop_jokers = CardArea(
		G.hand.T.x,
		G.hand.T.y+G.ROOM.T.y + 9,
		2.1*G.CARD_W,
		1.05*G.CARD_H, 
		{card_limit = 2, type = 'shop', highlight_limit = 1, negative_info = true})

	G.elle_becca_shop_consumables = CardArea(
		G.hand.T.x,
		G.hand.T.y+G.ROOM.T.y + 9,
		2.1*G.CARD_W,
		1.05*G.CARD_H, 
		{card_limit = 2, type = 'shop', highlight_limit = 1})

	G.elle_becca_shop_booster = CardArea(
		G.hand.T.x,
		G.hand.T.y+G.ROOM.T.y + 9,
		1.05*G.CARD_W,
		1.05*G.CARD_H-0.25, 
		{card_limit = 1, type = 'shop', highlight_limit = 1})
	
	-- Track whether this shop is open
	G.GAME.elle_popup_shop_open = "rebecca"
	
	-- Reload areas if not first time opening
	if not G.GAME.elle_popup_shops.rebecca.first_open then
		ellejokers.popup_shop.load_shop_areas("rebecca")
		--save_run()
	else G.GAME.elle_popup_shops.rebecca.first_open = false end


	-- Reroll the shop on open if expected to
	if (G.GAME.elle_popup_shops.rebecca.reset_on_open) then
		G.GAME.elle_popup_shops.rebecca.reset_on_open = false
		
		G.E_MANAGER:add_event(Event({ func = function()
			G.GAME.elle_popup_shops.rebecca.reroll = G.GAME.elle_popup_shops.rebecca.default_reroll
			becca_visible_reroll(true)
			return true
		end}))
	end
	
	local mod_txt = 'elle_rebecca_modifier_'..G.GAME.elle_popup_shops.rebecca.modifier
	local modifier = ellejokers.rebecca_modifiers[G.GAME.elle_popup_shops.rebecca.modifier]

	local modifier_lines = {}
	localize({set='Other', key=mod_txt, type='descriptions', vars=modifier.loc_vars and modifier:loc_vars() or nil, nodes = modifier_lines,})
	local modifier_desc = {}
	for _, v in ipairs(modifier_lines) do
		modifier_desc[#modifier_desc+1] = {n=G.UIT.R,config={align = "cm"},nodes=v}
	end

	local mod_ui = G.GAME.elle_popup_shops.rebecca.modifier ~= 'none' and {
	n = G.UIT.C, config = {align="cm", minw=2, colour=G.C.BLACK, padding=.05, r=.1, emboss=.05}, nodes = {
		{n = G.UIT.C, config = {align="cm", padding=.1}, nodes = {
			{n = G.UIT.R, config = {align="cm"}, nodes = {
				{n = G.UIT.T, config = {text = localize({set='Other', key=mod_txt, type='name_text', vars=modifier.loc_vars and modifier:loc_vars() or nil}), colour=G.C.WHITE, scale=0.5}}}},
				{n = G.UIT.R, config = {align="cm", colour=G.C.WHITE, r=.1, emboss=-.05, padding=.1}, nodes = {
					{n = G.UIT.R, config = {align="cm"}, nodes = modifier_desc}
	}}}}}} or nil

	return create_UIBox_generic_options({
		no_back = true,
		contents = {
			-- Title stuff
			{n = G.UIT.R, config = {align="cm"}, nodes = {
				{n = G.UIT.R, config = {align="cm", padding = .1}, nodes = {
					-- Center box
					{n = G.UIT.C, config = {align="cm"}, nodes = {
						{n = G.UIT.C, config = {align="cm", minw=2, colour=G.C.BLACK, padding=.1, r=.1, emboss=.05}, nodes = {
						{n = G.UIT.C, config = {align="cm", minw=2, colour=G.P_CENTERS.elle_r_elle_rebecca.resident_colour, padding=.1, r=.1}, nodes = {
						{n = G.UIT.C, config = {align="cm", minw=2, colour=G.C.BLACK, r=.1}, nodes = {
							{n = G.UIT.C, config = {align="cm", padding=.1}, nodes = {
								{n = G.UIT.R, config = {align="cm"}, nodes = {
									{n = G.UIT.T, config = {text = localize("elle_rebecca_title1"), colour=G.C.WHITE, scale=0.5}}}},
									{n = G.UIT.R, config = {align="cm"}, nodes = {
										{n = G.UIT.T, config = {text = localize("elle_rebecca_title2"), colour=G.C.UI.TEXT_INACTIVE, scale=0.3}}}}
					}}}}}}}}}},
					mod_ui
			}}}},
			-- Main Area
			{n = G.UIT.R, config = {align="cm"}, nodes = {
				-- Left side (Actual shop)
				{n = G.UIT.C, config = {align="cm", padding=.1}, nodes = {
					-- Shop box
					{n = G.UIT.R, config = {align="cm", colour=G.C.BLACK, outline=1, padding=.1, r=.1, emboss=.1}, nodes = {
						-- Top half
						{n = G.UIT.R, config = {align="cm", padding = 0.15}, nodes = {
							-- Booster pack thingy
							{n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
								{n=G.UIT.C, config={align = "cm", minw=2.5, padding = 0.2, r=0.2, colour = G.C.BLACK, maxh = G.elle_becca_shop_booster.T.h+0.4}, nodes={
									{n=G.UIT.T, config={text = localize("elle_rebecca_booster"), scale = 0.35, colour = G.C.L_BLACK, vert = true}},
									{n=G.UIT.O, config={object = G.elle_becca_shop_booster}},
								}}
							}},
							-- Jonklers
							{n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
								{n=G.UIT.T, config={text = localize("elle_rebecca_joker"), scale = 0.35, colour = G.C.BLACK, vert = true}},
								{n=G.UIT.O, config={object = G.elle_becca_shop_jokers}},
							}}
						}},
						-- Bottom half
						{n = G.UIT.R, config = {align="cm", padding = 0.15}, nodes = {
							-- Buttons
							{n=G.UIT.C, config={align = "cm", minw = 2.9}, nodes={
								{n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
									-- Reroll Button
									{n=G.UIT.R, config={align = "cm", minw = 2.5, minh = 1.4, r=0.15,colour = G.C.GREEN, button = 'elle_rebecca_reroll', func = 'elle_rebecca_can_reroll', hover = true,shadow = true}, nodes = {
										{n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'x', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
											{n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
												{n=G.UIT.T, config={text = localize('k_reroll'), scale = 0.4, colour = G.C.WHITE}},
											}},
											{n=G.UIT.R, config={align = "cm", maxw = 1.3, minw = 1}, nodes={
												{n=G.UIT.T, config={text = localize('$'), scale = 0.7, colour = G.C.WHITE, shadow = true}},
												{n=G.UIT.T, config={ref_table = G.GAME.elle_popup_shops.rebecca, ref_value = 'reroll', scale = 0.75, colour = G.C.WHITE}},
											}}
										}}
									}},
									-- Exit button (for people who don't know you can just press ESC)
									UIBox_button({ button = "exit_overlay_menu", label = { "Exit" }, minh=.8, minw=2.5, colour = G.C.RED })
								}},
							}},
							-- Consumables
							{n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
								{n=G.UIT.T, config={text = localize("elle_rebecca_consumable"), scale = 0.35, colour = G.C.BLACK, vert = true}},
								{n=G.UIT.O, config={object = G.elle_becca_shop_consumables}},
							}}
						}}
					}}
				}},
				-- Right side (Rebecca omggg haiii)
				--[[{n = G.UIT.C, config = {minw=2, minh=2, colour = G.C.MONEY, padding =.1}, nodes = {
					--{n = G.UIT.T, config = {text = becca_menu_card.ability.extra.test, colour=G.C.WHITE, scale=.3}},
					
					-- Right side (Rebecca omggg haiii)
					{n = G.UIT.C, config = {align="cm", minw=6}, nodes = {
						{n = G.UIT.R, config = {align="tr", padding = 0.15}, nodes = {
							UIBox_button({ button = "elle_rebecca_test", label = { "save(test)" }, minh=.6, minw=2.4, colour = G.C.BLUE }),
							UIBox_button({ button = "elle_rebecca_test2", label = { "load(test)" }, minh=.6, minw=2.4, colour = G.C.FILTER })
						}}
					}}
				}}]]
			}},
		}
	})
end

-- Reroll button update
function G.FUNCS.elle_rebecca_can_reroll(e)
	if ((G.GAME.dollars-G.GAME.bankrupt_at) - G.GAME.elle_popup_shops.rebecca.reroll < 0) and G.GAME.elle_popup_shops.rebecca.reroll ~= 0 then 
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.GREEN
		e.config.button = 'elle_rebecca_reroll'
	end
end

-- Reroll shop
function G.FUNCS.elle_rebecca_reroll(e)
	stop_use() -- This was in the vanilla reroll callback for some reason
	ease_dollars(-G.GAME.elle_popup_shops.rebecca.reroll)
	G.GAME.elle_popup_shops.rebecca.reroll = G.GAME.elle_popup_shops.rebecca.reroll + G.GAME.elle_popup_shops.rebecca.reroll_cost
	G.E_MANAGER:add_event(Event({ trigger = 'immediate', func = function()
		play_sound('coin2')
		play_sound('other1')
		
		becca_visible_reroll()
		return true
	end}))
end

--#endregion

function ellejokers.set_rebecca_modifier(mod_key)
	G.GAME.elle_popup_shops.rebecca.modifier = mod_key
	if ellejokers.rebecca_modifiers[mod_key].init then ellejokers.rebecca_modifiers[mod_key]:init() end
end

function ellejokers.reset_game_globals.rebecca(run_start)
	if run_start then
		ellejokers.set_rebecca_modifier(pseudorandom_element(ellejokers.table_keys(ellejokers.rebecca_modifiers),'elle_rebecca_modifier'))
	end
end

local oldsetcost = Card.set_cost
function Card:set_cost()
    oldsetcost(self)

	local modifier = ellejokers.rebecca_modifiers[G.GAME.elle_popup_shops.rebecca.modifier]
	for i, v in ipairs(ellejokers.popup_shop.shop_cardareas.rebecca) do
		if self.area == G[v] and modifier.cost_mod then
			self.cost = modifier:cost_mod(self,G[v])
		end
	end
end
--[[ List of modifier thingies
	init(self) - when modifier is set
	loc_vars(self) - localize() vars table
	jokers(self)/consumables(self)/booster(self) - modify SMODS.create_card for respective areas
	vars = arbitrary values for things that could change over time
	cost_mod(self,card) - Change the cost of cards
]]

ellejokers.rebecca_modifiers.none = {}	-- Nothing :)

ellejokers.rebecca_modifiers.oops = {	-- Oops! All [ConsumableType]
	init = function(self)
		self.vars.type = pseudorandom_element(SMODS.ConsumableTypes,'elle_becca_mod_oops').key
	end,
	loc_vars = function(self)
		return {localize("k_"..string.lower(self.vars.type)), colours = {SMODS.ConsumableTypes[self.vars.type].secondary_colour}}
	end,
	vars = { type = 'Tarot' },
	consumables = function(self)
		return { set = self.vars.type }
	end
}

ellejokers.rebecca_modifiers.sale = {
	cost_mod = function(self,card)
		return math.max(math.floor(card.cost/3*2),1)
	end
}

ellejokers.rebecca_modifiers.modded = {
	joker = function(self)
		return {attributes = {"Joker"}, filter = function(pool)
			local new_pool = {}
			for k, v in pairs(pool) do
				if G.P_CENTERS[v.key].original_mod then
					table.insert(new_pool, v)
				end
			end
			if #new_pool == 0 then table.insert(new_pool, 'j_joker') end -- Go, my Jimbo!
			return new_pool
		end}
	end
}

ellejokers.rebecca_modifiers.pcards = {
	consumables = function(self) return {set ='Enhanced'} end,
	cardfunc = function(self,card)
		if card.area == G.elle_becca_shop_consumables then
			card:set_seal(SMODS.poll_seal({guaranteed=true}),true,true)
		end
	end,
	cost_mod = function(self,card)
		return card.area == G.elle_becca_shop_consumables and 4 or card.cost
	end
}

-- this is definitely NOT the correct way to double values :sob:
--[[local other_vals = {
	'choose'
}
ellejokers.rebecca_modifiers.plussize = {
	cardfunc = function(self,card)
		card.ability.choose = card.ability.choose and card.ability.choose*2
		if card.ability.consumeable then
			for _, v in pairs(card.ability.consumeable) do
				if type(v) == "number" then v = v * 2 end
				if type(v) == "table" then
					for _, v2 in pairs(v) do
						if type(v2) == "number" then v2 = v2 * 2 end
					end
				end
			end
		end

		if card.ability.extra then
			if type(card.ability.extra) == "number" then card.ability.extra = card.ability.extra * 2
			elseif type(card.ability.extra) == "table" then
				for _, v in pairs(card.ability.extra) do
					if type(v) == "number" then v = v * 2 end
				end
			end
		end
	end,
	cost_mod = function(self,card)
		return card.cost*2
	end
}]]