local function toggle_with_desc(t)
	local toggle = create_toggle(t)
	toggle.config.tooltip = t.desc
	return toggle
end

--[[
{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = slimeutils.create_display_card('j_elle_chloe') }}}},
{n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {text = ">", scale = .6, colour = G.C.WHITE}}}},
{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = slimeutils.create_display_card('j_elle_furry') }}}},
{n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {text = ">", scale = .6, colour = G.C.WHITE}}}},
{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = slimeutils.create_display_card('j_elle_cheshire') }}}}
]]

local function upgrade_tree_example(t)
	local r = {}
	for i, v in ipairs(t) do
		if i>1 then r[#r+1] = {n = G.UIT.C, config = {align = "cm", padding = 0.1}, nodes = {{n = G.UIT.T, config = {text = ">", scale = .5, colour = G.C.WHITE}}}} end
		r[#r+1] = {n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = slimeutils.create_display_card(v) }}}}
	end
	return r
end

local upgrade_trees = {
	{"j_elle_chloe", "j_elle_furry"},
	{"j_elle_furry", "j_elle_cheshire"},
	{"j_elle_feri", "j_elle_ferisophie"},
	{"j_elle_sophie","j_elle_fallen"},
	{"j_elle_sarah","j_elle_mint"},
	{"j_elle_p41", "j_elle_prototypes"},
	{"j_elle_drago","j_elle_cheshdrago"},
	{"j_credit_card", "j_elle_bat_credit_card"}
}

local splashes = {
	"I have a suggestion...",
	"Yet another OC mod",
	"Hi chat!",
	"elle wuz here.",
	"7 members and counting",
	"Can you believe the shit they let me write in here?",
	"Beware the purple cat...",
	"I'll make you pay! I've got friends on the inside!",
	
}

-- ty aiko for telling me how to do this lol
-- ..also i'm referencing aikoshen code for this lmao
--[[SMODS.current_mod.custom_ui = function(mod_nodes)
	mod_nodes = EMPTY(mod_nodes)
	
	mod_nodes[#mod_nodes+1] = {n = G.UIT.C, config = {padding = 0.1}, nodes = {
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
		{n = G.UIT.R, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {text = pseudorandom_element(splashes,"elle_desc_splash"), scale = .3, colour = G.C.WHITE}}}},
		{n = G.UIT.R, config = {align = "cm"}, nodes = {
			{n = G.UIT.C, config = {align = "cm", padding = 0.2}, nodes = {
				{n = G.UIT.R, config = {align = "cm"}, nodes = {
					{n = G.UIT.R,
						config = {
							emboss = 0.05,
							r = 0.1,
							minw = 6,
							minh = 2.4,
							align = "cm",
							padding = 0.1,
							colour = G.C.L_BLACK
						}, nodes = {
						{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = slimeutils.create_display_card('j_elle_elle') }}}},
						{n = G.UIT.C, config = {align = "cl", padding = 0.1, minw = 4}, nodes = {
							{n = G.UIT.R, nodes = {
								{n = G.UIT.T, config = {text = "A mod by ", scale = .4, colour = G.C.WHITE}},
								{n = G.UIT.T, config = {text = "ellestuff.", scale = .4, colour = G.ARGS.LOC_COLOURS.elle}}
							}},
							{n = G.UIT.R, nodes = {{n = G.UIT.T, config = {text = "(and featuring her characters)", scale = .3, colour = G.C.WHITE}}}}
						}}
					}},
				}},
				{n = G.UIT.R, config = {align = "cm"}, nodes = {
					{n = G.UIT.R,
						config = {
							emboss = 0.05,
							r = 0.1,
							minw = 6,
							minh = 2.4,
							align = "cm",
							padding = 0.1,
							colour = G.C.L_BLACK
						}, nodes = {
						{n = G.UIT.C, config = {align = "cr", padding = 0.1, minw = 4}, nodes = {
							{n = G.UIT.R, config = {align = "cr"}, nodes = {{n = G.UIT.T, config = {text = "Based off my dumb", scale = .4, colour = G.C.WHITE}}}},
							{n = G.UIT.R, config = {align = "cr"}, nodes = {{n = G.UIT.T, config = {text = "fuckin' slime girl OCs and", scale = .4, colour = G.C.WHITE}}}},
							{n = G.UIT.R, config = {align = "cr"}, nodes = {{n = G.UIT.T, config = {text = "the lore I gave them", scale = .4, colour = G.C.WHITE}}}}
						}},
						{n = G.UIT.C, nodes = {{n = G.UIT.O, config = { object = slimeutils.create_display_card("j_elle_marie") }}}}
					}}
				}}
			}},
			{n = G.UIT.C, config = {align = "cm", padding = 0.2}, nodes = {
				{n = G.UIT.R, config = {align = "cm"}, nodes = {
					{n = G.UIT.R,
						config = {
							emboss = 0.05,
							r = 0.1,
							minw = 3,
							minh = 5,
							align = "cm",
							padding = 0.1,
							colour = G.C.L_BLACK
						}, nodes = {
						{n = G.UIT.R, config = {align = "cm"}, nodes = upgrade_tree_example(pseudorandom_element(upgrade_trees))},
						{n = G.UIT.R, config = {align = "cm", padding = 0.1, minw = 4}, nodes = {
							{n = G.UIT.R, config = {align = "cm"}, nodes = {
								{n = G.UIT.T, config = {text = "Upgrade", scale = .4, colour = G.C.FILTER}},
								{n = G.UIT.T, config = {text = " your Jokers into", scale = .4, colour = G.C.WHITE}}
							}},
							{n = G.UIT.R, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {text = "new, more interesting ones", scale = .4, colour = G.C.WHITE}}}},
							{n = G.UIT.R, config = {align = "cm"}, nodes = {
								{n = G.UIT.T, config = {text = "by meeting ", scale = .4, colour = G.C.WHITE}},
								{n = G.UIT.T, config = {text = "unique criteria", scale = .4, colour = G.C.FILTER}}
							}}
						}}

					}},
				}}
			}}
		}}
	}}
end]]

local nsfw_cards = {
	"j_elle_feri"
}

local palette_options = {}
for i, v in ipairs(ellejokers.palettes) do
	palette_options[#palette_options+1] = v.name
end
local palette_info = {"Palette by "..ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette].credit}

local function toggle_palette(args)
	check_for_unlock({type = "elle_toggle_palette"})
end

-- this was originally gonna be a separate mod
-- you're welcome :giggle_hehe:

-- thanks to @sleepy.g11 for helping me with this lol
local function show_element(container)
	if container and not container.config.original_object_visible then
		container.config.original_object_visible = true

		container.config.object:remove()
		container.config.object = container.config.original_object
		container.config.original_object.states.visible = true
		container.config.original_object.parent = container;

		(container.UIBox or container):recalculate()
	end
end

local function hide_element(container)
	if container and container.config.original_object_visible then
		container.config.original_object_visible = false
		container.config.original_object.states.visible = false
		container.config.object = Moveable();

		(container.UIBox or container):recalculate()
	end
end

local function create_sophie(key)
	local c = slimeutils.create_display_card(key or "j_elle_sophie")
	c.ability.extra.charges = 6
	return c
end

SMODS.current_mod.config_tab = function()
	local localnodes = {
		nsfw = UIBox{definition={n=G.UIT.ROOT, config={colour=G.C.CLEAR}, nodes = {
			create_option_cycle({opt_callback = "conf_elle_censor_mode",
				label = "Censor Mode",
				options = {"Uncensored", "Censor bar", "Featureless"},
				current_option = ellejokers.mod_data.config.censor_mode,
				w = 3.8,
				scale = .8
			})
		}},config={}},

		sfw = UIBox{definition={n=G.UIT.ROOT, config={colour=G.C.CLEAR, padding = 0.1}, nodes = {
			{n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = "Do not enable if streaming, trust me.", scale = 0.30, colour = G.C.WHITE}}}},
			{n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = "There's nudity and shit...", scale = 0.30, colour = G.C.WHITE}}}},
			{n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = "...Like, immediately-", scale = 0.30, colour = G.C.WHITE}}}},
			{n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = "Don't enable if you're a kid either", scale = 0.30, colour = G.C.WHITE}}}}
		}},config={}}
	}
	local localnodes2 = {
		nsfw = UIBox{definition={n=G.UIT.ROOT, config={colour=G.C.CLEAR}, nodes = {
			{ n = G.UIT.O,
				config = {
					original_object_visible = false,
					original_object = localnodes.nsfw,
					object = Moveable(),
					id = "textthing"
			}}
		}},config={}},
		sfw = UIBox{definition={n=G.UIT.ROOT, config={colour=G.C.CLEAR}, nodes = {
			{ n = G.UIT.O,
				config = {
					original_object_visible = false,
					original_object = localnodes.sfw,
					object = Moveable(),
					id = "textthing2"
			}}
		}},config={}}
	}
	localnodes.nsfw.states.visible = false
	localnodes.sfw.states.visible = true

	local n = localnodes2.nsfw:get_UIE_by_ID("textthing")
	local n2 = localnodes2.sfw:get_UIE_by_ID("textthing2")

	local function toggle_nsfw(args)
		for _, v in ipairs(nsfw_cards) do
			G.P_CENTERS[v].pos.y = ellejokers.mod_data.config.nsfw and 1 or 0
		end
		
		if(ellejokers.mod_data.config.nsfw) then
			show_element(n)
			hide_element(n2)
		else
			show_element(n2)
			hide_element(n)
		end
		G.OVERLAY_MENU:recalculate()
	end
	toggle_nsfw()

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
				desc = { text = {"Toggle the Palette","Screen Shader"} }
			}),
			create_option_cycle({opt_callback = "conf_elle_palette",
				label = "Palette",
				options = palette_options,
				current_option = ellejokers.mod_data.config.pixel_shader.palette,
				w = 5,
				scale = .8
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
				minh = 3,
				align = "cm",
				padding = 0.1,
				colour = G.C.L_BLACK
			}, nodes = {
			{n = G.UIT.C, config = {align = "cm", padding = 0.1, minw = 5}, nodes = {
				toggle_with_desc({callback  = toggle_nsfw,
					label = "(18+) Adult Mode",
					ref_table = ellejokers.mod_data.config,
					ref_value = 'nsfw',
					desc = { text = {"Enables NSFW/fetish","content on some cards"} }
				}),
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.O, config={
						align = "cm",
						object = localnodes2.sfw
					}, nodes={}},
				}},
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.O, config={
						align = "cm",
						object = localnodes2.nsfw
					}, nodes={}},
				}},
			}},
			--{n = G.UIT.C, config = { align = "cm" }, nodes = {{n = G.UIT.O, config = { object = create_sophie(pseudorandom_element({"j_elle_sophie","j_elle_fallen"},"elle_nsfw_sophie")) }}}}
		}}
	}}
end

function G.FUNCS.conf_elle_palette(args)
	ellejokers.mod_data.config.pixel_shader.palette = args.cycle_config.current_option
end

function G.FUNCS.conf_elle_palette_credit(args)
	args.config.ref_table = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette]
end

function G.FUNCS.conf_elle_censor_mode(args)
	ellejokers.mod_data.config.censor_mode = args.cycle_config.current_option
end
