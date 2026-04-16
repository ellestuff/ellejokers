ellejokers.Resident = SMODS.Center:extend{
	unlocked = true,
	set = 'Resident',
	discovered = false,
	class_prefix = 'j',
	required_params = {
		'key',
	},
		pos = { x = 0, y = 0 },
		atlas = 'elle_residents',
}

SMODS.current_mod.custom_collection_tabs = function()
	return {
		{
			button = UIBox_button({
				-- calls `G.FUNCS.your_collection_something` when pressed, define accordingly
				button = 'resident_collection', 
				id = 'resident_collection',
				-- Displayed label on the button (using non-localized strings also works)
				label = {localize('elle_residents')},
				-- optional; should have numeric 'tally' and 'of' values (for discovery counts)
				--count = G.DISCOVER_TALLIES['resident'], 
				-- optional; minimum width of your button
				minw = 5
			})
		}
	}
end

local function create_UIBox_resident_collection()
	local deck_tables = {}

	G.your_collection = {}
	for j = 1, 3 do
		G.your_collection[j] = CardArea(
			G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
			5*G.CARD_W,
			0.95*G.CARD_H, 
			{card_limit = 5, type = 'title', highlight_limit = 0, collection = true})
		table.insert(deck_tables, 
		{n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
			{n=G.UIT.O, config={object = G.your_collection[j]}}
		}}
		)
	end

	local resident_options = {}
	for i = 1, math.ceil(#G.P_CENTER_POOLS.Joker/(5*#G.your_collection)) do
		table.insert(resident_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Joker/(5*#G.your_collection))))
	end

	for i = 1, 5 do
		for j = 1, #G.your_collection do
			local center = G.P_CENTER_POOLS["Resident"][i+(j-1)*5]
			local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
			G.your_collection[j]:emplace(card)
		end
	end

	INIT_COLLECTION_CARD_ALERTS()
	
	local t =  create_UIBox_generic_options({ back_func = 'your_collection', contents = {
		{n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}, 
		{n=G.UIT.R, config={align = "cm"}, nodes={
			create_option_cycle({options = resident_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_resident_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
		}}
	}})

	return t
end

G.FUNCS.resident_collection = function ()
	G.SETTINGS.paused = true
		G.FUNCS.overlay_menu{
			definition = create_UIBox_resident_collection(), -- this is the actual UI definition function
		}
end

G.FUNCS.your_collection_resident_page = function(args)
	if not args or not args.cycle_config then return end
	for j = 1, #G.your_collection do
		for i = #G.your_collection[j].cards,1, -1 do
			local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
			c:remove()
			c = nil
		end
	end
	for i = 1, 5 do
		for j = 1, #G.your_collection do
			local center = G.P_CENTER_POOLS["Resident"][i+(j-1)*5 + (5*#G.your_collection*(args.cycle_config.current_option - 1))]
			if not center then break end
			local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
			G.your_collection[j]:emplace(card)
		end
	end
	INIT_COLLECTION_CARD_ALERTS()
end