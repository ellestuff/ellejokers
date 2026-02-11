-- ty aiko for telling me how to do this lol
-- ..also i'm refernecing aikoshen code for this lmao
SMODS.current_mod.custom_ui = function(mod_nodes)
	mod_nodes = EMPTY(mod_nodes)
	
	local ellecard = Card(G.ROOM.T.x,G.ROOM.T.y,G.CARD_W*.75,G.CARD_H*.75,nil,G.P_CENTERS.j_elle_elle, { bypass_discovery_center = true, bypass_discovery_ui = true, no_ui = true })

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
			{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = ellecard }}}},
			{n = G.UIT.C, config = {align = "cl", padding = 0.1}, nodes = {
				{n = G.UIT.R, nodes = {{n = G.UIT.T, config = {text = "A mod by this goober.", scale = .4, colour = G.C.WHITE}}}},
				{n = G.UIT.R, nodes = {{n = G.UIT.T, config = {text = "(and featuring her characters)", scale = .3, colour = G.C.WHITE}}}}
			}}
		}}
	}}
end

if not SMODS.ScreenShader then return end

local palette_options = {}
for i, v in ipairs(ellejokers.palettes) do
	palette_options[#palette_options+1] = v.name
end
local palette_info = {"Palette by "..ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette].credit}


SMODS.current_mod.config_tab = function()
	return {n = G.UIT.ROOT, config = {
		emboss = 0.05,
		minh = 6,
		r = 0.1,
		minw = 6,
		align = "tm",
		padding = 0.2,
		colour = G.C.BLACK
	}, nodes = {
		create_toggle({opt_callback = "conf_elle_palette_toggle",
			label = "Palette Shader",
			ref_table = ellejokers.mod_data.config.pixel_shader,
			ref_value = 'enabled'
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
		}}
	}}
end

function G.FUNCS.conf_elle_palette(args)
	ellejokers.mod_data.config.pixel_shader.palette = args.cycle_config.current_option
end

function G.FUNCS.conf_elle_palette_toggle(args)
	ellejokers.mod_data.config.pixel_shader.enabled = not ellejokers.mod_data.config.pixel_shader.enabled
	check_for_unlock({type = "elle_toggle_palette"})
end

function G.FUNCS.conf_elle_palette_credit(args)
	args.config.ref_table = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette]
end