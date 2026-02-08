local palette_options = {}
for i, v in ipairs(ellejokers.palettes) do
    palette_options[#palette_options+1] = v.name
end
local palette_info = {"Palette by "..ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette].credit}
SMODS.current_mod.config_tab = function()
	return {n = G.UIT.ROOT, config = {
		align = "cm", padding = 0.05, colour = G.C.CLEAR
	}, nodes = {
        create_option_cycle({opt_callback = "conf_elle_palette",
            label = "Palette",
            options = palette_options,
            current_option = ellejokers.mod_data.config.pixel_shader.palette,
            scale = 0.8,
            w = 3,
            config = {func = "conf_elle_palette_update"}
        }),
        {n=G.UIT.R, config={align = "cm", maxw = 2.3, minw = 1}, nodes={
            {n=G.UIT.T, config={text = "Palette by ", scale = 0.8, colour = G.C.WHITE}},
            {n=G.UIT.T, config={ref_table = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette], ref_value = 'credit', scale = 0.8, colour = G.C.WHITE,func='conf_elle_palette_credit'}}
        }}
	}}
end

function G.FUNCS.conf_elle_palette(args)
	ellejokers.mod_data.config.pixel_shader.palette = args.cycle_config.current_option
end

function G.FUNCS.conf_elle_palette_credit(args)
    args.config.ref_table = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette]
end