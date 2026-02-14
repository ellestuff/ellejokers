local function create_display_card(key)
	local card = Card(G.ROOM.T.x,G.ROOM.T.y,G.CARD_W*.75,G.CARD_H*.75,nil,G.P_CENTERS[key], { bypass_discovery_center = true, bypass_discovery_ui = true })
	card.no_ui = true
	card.states.drag.can = false
	return card
end

local function toggle_with_desc(t)
	local toggle = create_toggle(t)
	toggle.config.tooltip = t.desc
	return toggle
end

-- ty aiko for telling me how to do this lol
-- ..also i'm referencing aikoshen code for this lmao
SMODS.current_mod.custom_ui = function(mod_nodes)
	mod_nodes = EMPTY(mod_nodes)
	
	mod_nodes[#mod_nodes+1] = {n = G.UIT.C, nodes = {
		{n = G.UIT.R,
			config = {
				align = "cm"
			}, nodes = {
				{n = G.UIT.R,
					config = {
						r = 0.1,
						align = "cm",
						padding = 0.1,
						colour = G.ARGS.LOC_COLOURS.elle,
					}, nodes = {
						{n = G.UIT.C,
							config = {
								r = 0.1,
								align = "cm",
								padding = 0.2,
								colour = G.C.BLACK
							}, nodes = {
								{n = G.UIT.T, config = {text = "ellejokers.", scale = .75, colour = G.C.WHITE}}
						}}
				}}
		}},
		{n = G.UIT.R,
			config = {
				align = "cl",
				padding = 0.1,
				minw = 6
			}, nodes = {
			{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = create_display_card('j_elle_elle') }}}},
			{n = G.UIT.C, config = {align = "cl", padding = 0.1}, nodes = {
				{n = G.UIT.R, nodes = {{n = G.UIT.T, config = {text = "A mod by this goober.", scale = .4, colour = G.C.WHITE}}}},
				{n = G.UIT.R, nodes = {{n = G.UIT.T, config = {text = "(and featuring her characters)", scale = .3, colour = G.C.WHITE}}}}
			}}
		}}
	}}
end

local palette_options = {}
for i, v in ipairs(ellejokers.palettes) do
	palette_options[#palette_options+1] = v.name
end
local palette_info = {"Palette by "..ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette].credit}

local function toggle_palette(args)
	check_for_unlock({type = "elle_toggle_palette"})
end

local puritan_cards = {
	'j_elle_vivian',
	'j_elle_feri'
}
function ellejokers.puritan_sprite_update()
	for i, v in ipairs(puritan_cards) do
		G.P_CENTERS[v].pos.y = ellejokers.mod_data.config.puritan and 1 or 0
	end
end

local function toggle_streamer(args)
	ellejokers.puritan_sprite_update()
	if not ellejokers.mod_data.config.puritan then check_for_unlock({type = "elle_puritan"}) end
end

SMODS.current_mod.config_tab = function()
	return {n = G.UIT.ROOT, config = {
		emboss = 0.05,
		r = 0.1,
		minw = 6,
		align = "tm",
		padding = 0.2,
		colour = G.C.BLACK
	}, nodes = {
		{n=G.UIT.R, config={
			emboss = 0.05,
			r = 0.1,
			minw = 6,
			align = "cm",
			padding = 0.1,
			colour = G.C.L_BLACK
		}, nodes={
			toggle_with_desc({callback = toggle_palette,
				label = "Palette Shader",
				ref_table = ellejokers.mod_data.config.pixel_shader,
				ref_value = 'enabled',
				desc = { text = SMODS.ScreenShader and {"Toggle the Palette","Screen Shader"} or {"Toggle the Palette","Shader on","supported cards"} }
			}),
			create_option_cycle({opt_callback = "conf_elle_palette",
				label = "Palette",
				options = palette_options,
				current_option = ellejokers.mod_data.config.pixel_shader.palette,
				w = 5,
				scale = .8,
				config = {func = "conf_elle_palette_update"}
			}),
			{n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.T, config={text = "Palette by ", scale = 0.30, colour = G.C.WHITE}},
				{n=G.UIT.T, config={ref_table = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette], ref_value = 'credit', scale = 0.30, colour = G.C.FILTER,func='conf_elle_palette_credit'}}
			}},
		}},
		{n = G.UIT.R,
			config = {
				emboss = 0.05,
				r = 0.1,
				minw = 6,
				align = "cm",
				padding = 0.1,
				colour = G.C.L_BLACK
			}, nodes = {
			{n = G.UIT.C, config = {align = "cl", padding = 0.1}, nodes = {
				toggle_with_desc({callback  = toggle_streamer,
					label = "Streamer Mode",
					ref_table = ellejokers.mod_data.config,
					ref_value = 'puritan',
					desc = { text = {"Changes some card","sprites that may be","considered suggestive"} }
				})
			}},
			{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = create_display_card(pseudorandom_element(puritan_cards,"elle_puritan_preview")) }}}}
			
		}}
	}}
end

function G.FUNCS.conf_elle_palette(args)
	ellejokers.mod_data.config.pixel_shader.palette = args.cycle_config.current_option
end



function G.FUNCS.conf_elle_palette_credit(args)
	args.config.ref_table = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette]
end


