G.P_CENTER_POOLS["elle_Resident"] = G.P_CENTER_POOLS["elle_Resident"] or {}

ellejokers.Resident = SMODS.Center:extend {
	unlocked = true,
	discovered = false,
	pos = { x = 0, y = 0 },
	atlas = "elle_residents",
	cost = 8,
	set = 'elle_Resident',
	config = {},
	class_prefix = 'elle_r',
	required_params = {
		'key',
	},
	set_card_type_badge = function(self, card, badges)
		badges[#badges + 1] = create_badge(self.resident_visitor and localize('k_elle_visitor') or localize('k_elle_resident'),
			not slimeutils.card_obscured(card) and self.resident_colour or get_type_colour(card.config.center or card.config, card), G.C.WHITE,
			1.2)
	end,
	inject = function(self)
		-- call the parent function to ensure all pools are set
		SMODS.Center.inject(self)
		G.ARGS.LOC_COLOURS[self.key] = self.resident_colour
	end
}
G.C.SET.elle_Resident = HEX("ff53a9")
G.C.SECONDARY_SET.elle_Resident = HEX("ff53a9")


function ellejokers.custom_card_areas.resident(game)
	game.elle_resident_area = CardArea(
		0,0,
		G.CARD_W*1.1,G.CARD_H,
		{
			card_limit = 1,
			type = "joker",
			highlight_limit = 1,
			no_card_count = false,
			align_buttons = true
		}
	)
end

SMODS.UndiscoveredSprite{
	key = 'elle_Resident',
	atlas = 'residents',
	pos = {x=0,y=0},
	no_overlay = true
}

local gsr = Game.start_run
function Game:start_run(args, ...)
	gsr(self, args, ...)

	local cons_t = G.consumeables.T

	self.elle_resident_area.T.x = cons_t.x + cons_t.w - self.elle_resident_area.T.w
	self.elle_resident_area.T.y = cons_t.y + 3

	-- Fuckass MP compat
	if SMODS.find_mod("Multiplayer") and MP and MP.shared then
		cons_t = self.elle_resident_area.T

		MP.shared.T.x = cons_t.x + cons_t.w - MP.shared.T.w
		MP.shared.T.y = cons_t.y + 3
	end
end

function ellejokers.mod_data.custom_collection_tabs()
	local tally = 0
	for _, v in pairs(G.P_CENTER_POOLS.elle_Resident) do
		tally = tally + (v.discovered and 1 or 0)
	end
	return {UIBox_button{
		button = "elle_your_collection_residents",
		label = {localize("b_elle_residents")},
		count = {tally = tally, of = #G.P_CENTER_POOLS.elle_Resident},
		minw = 5,
		id = "elle_your_collection_residents"
	}}
end

slimeutils.upgrade_areas[#slimeutils.upgrade_areas+1] = "elle_resident_area"

function ellejokers.create_UIBox_your_collection_residents()
	local pool = {}
	for k, v in pairs(G.P_CENTER_POOLS.elle_Resident) do
		if not v.no_collection then pool[#pool+1] = v end
	end

	local rows = {2,2}

	local cards_per_page = 4

	local options = {}
	for i = 1, math.ceil(#pool/cards_per_page) do
		table.insert(options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#pool/cards_per_page)))
	end

	G.your_collection = {}

	-- for i = 1, #rows do
	-- 	for j = 1, rows[i] do
			
	-- 	end
	-- end

	-- Thanks to @sleepy.g11 for making this update when changing pages
	local get_collection_page = function(page, parent)
		EMPTY(G.your_collection)
		local nodes = {}
		for j = 1, #rows do
			local rowNode = {n=G.UIT.C, config = {padding = 0.15}, nodes = {}}
			for i = 1, rows[j] do
				local c =  CardArea(
					G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
					G.CARD_W,
					G.CARD_H,
					{card_limit = 1, type = 'title', highlight_limit = 0, collection = true}
				)
				G.your_collection[#G.your_collection+1] = c
				
				local center = pool[(i-1)*2+j + (cards_per_page*(page - 1))]

				local bio_lines = {}
				local bio_title = {}

				if center then
					local card = Card(c.T.x + c.T.w/2, c.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
					
					local loc_vars = center.loc_vars and center:loc_vars({},card) or {}

					local name_key = loc_vars and loc_vars.key or center.key
					local bio_key = loc_vars and loc_vars.bio_key or center.key
					
					if not center.discovered then
						name_key = "undiscovered"
						bio_key = "undiscovered"
					elseif not (G.localization.descriptions.elle_Resident[center.key] and G.localization.descriptions.elle_Resident[center.key].res_bio) then
						name_key = "shame"
						bio_key = "shame"
					end

					local bio = {}
					localize({type="res_bio", set="elle_Resident", key=bio_key, nodes=bio, default_col=G.C.UI.TEXT_LIGHT, vars = loc_vars.vars})
					for _, line in ipairs(bio) do bio_lines[#bio_lines+1] = {n = G.UIT.R, config = {align = "cl"}, nodes = line} end
					
					local bt = {}
					localize({type = 'name', key = bio_key == "shame" and "shame" or name_key, set = 'elle_Resident', nodes = bio_title, vars = loc_vars.vars})
					for _, line in ipairs(bio_title) do bt[#bt+1] = {n = G.UIT.R, config = {align = "cl"}, nodes = line} end
					bio_title = bt

					c:emplace(card)
				end

				rowNode.nodes[#rowNode.nodes+1] =
				{n = G.UIT.R, config = {padding = 0.1, r = 0.08, hover=true, shadow=true, colour = G.C.L_BLACK}, nodes = {
					{n = G.UIT.C, config = {padding = 0.1, r = 0.08, emboss = 0.05, colour = G.C.BLACK}, nodes = {
						{n=G.UIT.O, config = {object = c}}
					}},
						{n = G.UIT.C, config = {r = 0.08, emboss = 0.05, colour = G.C.BLACK, padding = 0.1, minh=G.CARD_H, maxh=G.CARD_H}, nodes = {
							{n = G.UIT.R, config = {minw=4, maxw=4}, nodes = bio_title},
							{n = G.UIT.R, config = {minw=4, maxw=4}, nodes = bio_lines},
						}}
				}}
			end
			nodes[#nodes+1] = rowNode
		end
		INIT_COLLECTION_CARD_ALERTS()
		return UIBox({
			definition = {
				n = G.UIT.ROOT,
				config = { colour = G.C.CLEAR },
				nodes = nodes,
			},
			config = {
				major = parent,
				parent = parent,
			},
		})
	end

	G.FUNCS.SMODS_card_collection_page = function(e)
		if not e or not e.cycle_config then return end
		local parent = G.OVERLAY_MENU:get_UIE_by_ID("residents_content")
		parent.config.object:remove()
		parent.config.object = get_collection_page(e.cycle_config.current_option, parent)
		parent.UIBox:recalculate()
	end
	return create_UIBox_generic_options({
		back_func = G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection', contents = {
			{n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes={
				{
					n = G.UIT.O,
					config = {
						id = "residents_content",
						object = get_collection_page(1)
					}
				}
			}},
			(cards_per_page < #pool) and {n=G.UIT.R, config={align = "cm"}, nodes={
				create_option_cycle({options = options, w = 4.5, cycle_shoulders = true, opt_callback = 'SMODS_card_collection_page', current_option = 1, colour = G.ACTIVE_MOD_UI and (G.ACTIVE_MOD_UI.ui_config or {}).collection_option_cycle_colour or G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
			}} or nil,
	}})
end

--function G.FUNCS.elle_resident_collection_bio(e) end

function G.FUNCS.elle_your_collection_residents(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu{
		definition = ellejokers.create_UIBox_your_collection_residents(),
	}
end

function ellejokers.reset_game_globals.residents(run_start)
	if run_start then
		G.GAME.elle_resident_rate = 0
	end
end

function ellejokers.do_replace(card)
	local a = #G.elle_resident_area.cards + (1 + card.ability.extra_slots_used) <= G.elle_resident_area.config.card_limit + card.ability.card_limit
	return card.ability.set == 'elle_Resident' and (#G.elle_resident_area.highlighted == 1 or (#G.elle_resident_area.cards == 1 and not a))
end

local cfbshook = G.FUNCS.check_for_buy_space
function G.FUNCS.check_for_buy_space(card)
	if card.ability.set == 'elle_Resident' then
		-- Force allow if replacing
		if ellejokers.do_replace(card) then return true end

		local a = #G.elle_resident_area.cards + (1 + card.ability.extra_slots_used) <= G.elle_resident_area.config.card_limit + card.ability.card_limit
		if not a then alert_no_space(card, G.elle_resident_area) end
		return a
	end
	return cfbshook(card)
end

local cbhook = G.FUNCS.can_buy
function G.FUNCS.can_buy(e)
	local card = e.config.ref_table
	local res = ellejokers.do_replace(card)
	
	-- Update Box
	local txt = localize(res and "elle_resident_replace" or "b_buy")
	if e.children[1].config.text ~= txt and card.highlighted then
		-- Update text
		e.children[1].config.text = txt
		e.children[1].config.text = e.children[1].config.text
		e.children[1].config.text_drawable = nil
		e.children[1]:update_text()

		-- Temporarily set func to nil to prevent crash
		e.config.func = nil
		e.UIBox:recalculate()
		e.config.func = "can_buy"
	end

	if res then
		local buy = not (card.cost > G.GAME.dollars - G.GAME.bankrupt_at) and (card.cost > 0)
		e.config.colour = buy and G.C.PURPLE or G.C.UI.BACKGROUND_INACTIVE
		e.config.button = buy and 'elle_replace_from_shop' or nil
	else cbhook(e) end
end

local cschook = G.FUNCS.can_select_card
function G.FUNCS.can_select_card(e)
	local card = e.config.ref_table
	local res = ellejokers.do_replace(card)

	-- Update Box
	local txt = localize(res and "elle_resident_replace" or "b_select")
	if e.children[1].config.text ~= txt and card.highlighted then
		print(e.children[1].config.text)
		print(txt)
		-- Update text
		e.children[1].config.text = txt
		e.children[1].config.text = e.children[1].config.text
		e.children[1].config.text_drawable = nil
		e.children[1]:update_text()

		-- Temporarily set func to nil to prevent crash
		e.config.func = nil
		e.UIBox:recalculate()
		e.config.func = "can_select_card"
	end

	if res then
		e.config.colour = G.C.PURPLE
		e.config.button = 'elle_replace_from_booster'
	else cschook(e) end
end

function G.FUNCS.elle_replace_from_shop(e)
	G.E_MANAGER:add_event(Event({func = function()
		SMODS.destroy_cards(G.elle_resident_area.highlighted[1] or G.elle_resident_area.cards[1])
	return true end}))

	G.E_MANAGER:add_event(Event({func = function()
		G.FUNCS.buy_from_shop(e)
	return true end}))
end

function G.FUNCS.elle_replace_from_booster(e)
	G.E_MANAGER:add_event(Event({func = function()
		SMODS.destroy_cards(G.elle_resident_area.highlighted[1] or G.elle_resident_area.cards[1])
	return true end}))

	G.E_MANAGER:add_event(Event({func = function()
		G.FUNCS.use_card(e)
	return true end}))
end

local w_offset = 0.6
local achook = CardArea.align_cards
function CardArea.align_cards(self)
	if self == G.elle_resident_area then
		self.T.x = self.T.x-w_offset
		self.T.w = self.T.w+w_offset*2
		
		achook(self)
		
		self.T.x = self.T.x+w_offset
		self.T.w = self.T.w-w_offset*2
	else achook(self) end
end

SMODS.DrawStep {
	key = 'elle_resident_tail',
	order = -200, -- before the Card and UI buttons are drawn
	func = function(self)
		if self.config.center.elle_tail and (self.config.center.discovered or self.bypass_discovery_center) then
			local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))
			local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

			scale_mod = scale_mod * 1.1

			local spr = SMODS.shallow_copy(self.children.center.sprite_pos)

			self.children.center:set_sprite_pos(self.config.center.elle_tail)

			self.children.center:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
			self.children.center:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)

			self.children.center:set_sprite_pos(spr)
		end
	end,
	conditions = { vortex = false, facing = 'front' },
}

local cae = CardArea.emplace
function CardArea:emplace(card,...)
	if self == G.consumeables and card.ability.set == 'elle_Resident' then
		card:remove_from_area()
		G.elle_resident_area:emplace(card, ...)
		discover_card(card.config.center)
		card.bypass_discovery_center = true
		card.bypass_discovery_ui = true
		card.discovered = true
		return
	end

	cae(self, card, ...)
end

-- both these hooks were given by @nh6574
-- https://github.com/nh6574/JoyousSpring/blob/5ef54fa49bbb5a4450c78294fb7b2854134f5d44/src/card_ui.lua

local init_localization_ref = init_localization
function init_localization()
	init_localization_ref()

	if G.localization.descriptions.elle_Resident then
		for _, center in pairs(G.localization.descriptions.elle_Resident) do
			if center.res_bio then
				center.res_bio_parsed = {}
				for _, line in ipairs(center.res_bio) do
					center.res_bio_parsed[#center.res_bio_parsed + 1] = loc_parse_string(line)
				end
			end
		end
	end
end

local localize_ref = localize
function localize(args, misc_cat)
	if args and not (type(args) == 'table') then
		return localize_ref(args, misc_cat)
	end

	local loc_target = nil
	if args and (args.type == 'res_bio') then
		loc_target = G.localization.descriptions[(args.set or args.node.config.center.set)]
			[args.key or args.node.config.center.key]

		if loc_target then
			for _, line in ipairs(loc_target[args.type .. "_parsed"]) do
				args.nodes[#args.nodes + 1] = SMODS.localize_box(line, args)
			end
		end
	end
	return localize_ref(args, misc_cat)
end


-- makes residents' anim_timer count down properly so it can be used for animations
if not love.update then function love.update(dt) end end
local update_hook = love.update
function love.update(dt)
	update_hook(dt)

	if G and G.elle_resident_area then
		for i, v in ipairs(G.elle_resident_area.cards) do
			if v.ability.extra.anim_timer then v.ability.extra.anim_timer = math.max(v.ability.extra.anim_timer-dt,0) end
		end
	end
end

if SMODS.UndiscoveredCompat then
	SMODS.UndiscoveredCompat.elle_Resident = true
else
	-- i hate that i have to do this
	local gcui_hook = generate_card_ui
	function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
		if _c.set == "elle_Resident" and not G.P_CENTERS[_c.key].discovered then
			hide_desc = hide_desc or card.area.config.collection
			card_type = "Undiscovered"
		end
	
		return gcui_hook(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
	end
end