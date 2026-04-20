local function create_tenna_uibox(queue)
	local queuenodes = {}

	for _, v in ipairs(queue) do
		local mg = ellejokers.tvtime.microgames[v]
		local info = {set="Other",key="ellemicrogame_"..v,specific_vars = (mg and mg.loc_vars and mg:loc_vars() or {})}

		local n = {n = G.UIT.R, config = {colour=G.C.BLUE, padding=.1, r=.1, emboss=.05, detailed_tooltip=info}, nodes = {
			{n = G.UIT.T, config = {text = localize({type = 'name_text', key = "ellemicrogame_"..v, set = 'Other'}), scale = 0.3, colour = G.C.WHITE}}
		}}
		
		queuenodes[#queuenodes+1] = n
	end

	return UIBox{definition={n=G.UIT.ROOT, config={colour=G.C.UI.OUTLINE_LIGHT, padding = 0.05, r=.1, emboss=.05, hover=true, shadow=true}, nodes = {
		{n = G.UIT.C, config = {colour=G.C.L_BLACK, padding=.05, r=.1}, nodes={
			{n = G.UIT.R, config={align="tm"}, nodes={{n= G.UIT.T, config = {text = "Next Up:", scale = 0.3, colour = G.C.WHITE }}}},
			{n = G.UIT.R, config = {padding = 0.05,maxw=1.8,func="elle_tennadeck_colours"}, nodes=queuenodes}
		}}
	}},config={major = G.deck, align = "tm", offset = { x = 0.15, y = -.35 }}}
end

local function refresh_tenna_queue(back)
	local queue = {}

	for i = 1, math.min(math.ceil(G.GAME.round_resets.ante/back.effect.config.extra.antes),back.effect.config.extra.max), 1 do
		queue[#queue+1] = pseudorandom_element(ellejokers.tvtime.microgame_list, "elle_tennadeck_microgame")
	end

	back.effect.config.extra.queue = queue
end

local function refresh_tennabox()
	if G.tennabox then G.tennabox:remove() end
	G.tennabox = create_tenna_uibox(G.GAME.selected_back.effect.config.extra.queue)
	G.tennabox:juice_up(0.4,0.4)
end

local function tennadeck_end_func()
	local hits = slimeutils.microgames.microgame.hits or 0
	local back = G.GAME.selected_back
	
	for i = 1, hits, 1 do
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.4,
			func = function()
				G.GAME.blind.chips = G.GAME.blind.chips * back.effect.config.extra.hit
				G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
				SMODS.juice_up_blind()
				play_sound("elle_utdr_hurt")
				
				return true
		end}))
	end
end

SMODS.Back {
	key = "tenna",
	atlas = "enhancers",
	pos = {x=0,y=1},
	config = {ante_scaling = 0.75, extra = {queue = {}, hit = 1.25, antes = 2, max = 6}},
	loc_vars = function(self, info_queue, back)
		return { vars = { self.config.ante_scaling, self.config.extra.antes, self.config.extra.hit, self.config.extra.max } }
	end,
	apply = function(self, back)
		refresh_tenna_queue(back)
	end,
	calculate = function(self, back, context)
		if context.setting_blind then
			local queue_actual = {}
			for i, v in ipairs(back.effect.config.extra.queue) do
				slimeutils.microgames.enqueue(queue_actual,ellejokers.tvtime.microgames[v],{juice=G.tennabox, end_func = tennadeck_end_func})
			end

			slimeutils.microgames:init(queue_actual,ellejokers.tvtime.anims)
			G.E_MANAGER:add_event(Event({func = function ()
				G.tennabox:remove()
			return true end}))
		end

		if context.round_eval then
			refresh_tenna_queue(back)
		end

		if context.ending_shop then refresh_tennabox() end
	end
}

ellejokers.custom_card_areas.tenna = function(game)
	if G.GAME.selected_back.effect.center.key == "b_elle_tenna" and G.STATE == G.STATES.BLIND_SELECT then
		game.tennabox = create_tenna_uibox(G.GAME.selected_back.effect.config.extra.queue)
	end
end

-- Play Microgames when entering blind
-- Increase microgame count every 4 antes
-- Scale blind size by X0.25 every hit
-- X0.5 Base blind size
-- Preview microgame list above deck

function G.FUNCS.elle_tennadeck_colours(e)
	for i, v in ipairs(e.children) do
		v.config.colour = mix_colours((slimeutils.microgames.running and (#e.children-i == #slimeutils.microgames.queue-1) and G.C.RED or G.C.BLUE), G.C.WHITE,v.states.hover.is and 0.8 or 1)
	end
end