--		[[ To-Do List ]]
--	- New Joker art
--		- Chloe
--		- Furry
--		- Marie
--		- Twy
--		- Elle
--		- Mint
--		- Drago
--	- More Jokers????
--		- Ideas
--			- Deck with showman effect
--			- Jokers
--				- Unnamed Joker Idea
--					- If Scoring Hand contains a Straight, give all cards in hand a permanent +4 Mult
--		- pls don't scope creep i swear to god-
--			- oops too late hehe~
--	- Needs effects
--		- Unimplemented
--			- Spearmint/spearmint.prog
--				- Skill tree?
--				- Allocatable points from beating blinds?
--					- More points from boss blinds (3?)
--			- Boyfriend
--				- LITERALLY JUST FNF - VMan's working on this :p
--				- Balatro SFX atonals similar to SCDM
--	- "The Microphone" boss blind
--		- Also FNF, like Boyfriend
--		- Plays a harder fnf song
--		- "Zoinks!" final boss blind
--			- 9k song, on par with (or literally just) Final Destination
--	- Fix Bugs
--		- MoreFluff
--			- Custom Colour card crashes game on round end

ellejokers = {
	mod_data = SMODS.current_mod,
	palettes = {
		{
			name = "octo80",
			path = "octo80.png",
			credit = "octoshrimpy"
		},
		{
			name = "AAP-64",
			path = "aap64.png",
			credit = "Adigun A. Polack"
		},
		{
			name = "Greyscale (octo80)",
			path = "greyscale.png",
			credit = "octoshrimpy"
		},
		{
			name = "Binary",
			path = "binary.png",
			credit = "???"
		},
		{
			name = "Balatro...?",
			path = "balatro.png",
			credit = "???"
		}
	},
	censor_atlases = {
		"elle_censor_default",
		"elle_censor_bar",
		"elle_censor_featureless"
	},
	calculate = {},
	custom_card_areas = {},
	reset_game_globals = {}
}

-- Create palettes
for k, v in ipairs(ellejokers.palettes) do
	v.image = love.graphics.newImage( love.image.newImageData(SMODS.NFS.newFileData( SMODS.current_mod.path .. "assets/extra_images/palettes/"..v.path) ) )
	local w,h = v.image:getDimensions()
	v.dims = {w,h}
end


--		[[ File List ]]
local lib = {
	"http",
	"skins",
	"consumables",
	"misc",
	"challenges",
	"popup_shop",
	"enhancements",
	"achievements",
	"config",
	--"tv_time",
	"blinds",
	"resident",
	"resident_buttons",
	"booster"
}

--		[[ Joker List ]]
-- Comment out jokers you want to disable
local jokers = {
	"insomniac",
	"contract",
	"slimefarm",
	"flare",
	"plort",
	"kingslime",
	"cassie",
	"carpet",
	"polyamory",
	"nitro",
	"ourple",
	"eraser",
	"magic_fingers",
	"suggestion",
	"powerscaler",
	"clubcard",
	"combat",
	"batcreditcard",
	"wordle",
	"spamton",
	"vivian",
	"jess",
	"jessclip",
	"jessingit",
	"drago",
	--"cheshdrago",
	"feri",
	--"ferisophie",
	--"bf",
	--"tenna",
	"elle",
	"twy"
}
local residents = {
	"marie",
	"chloe",
	"furry",
	"cheshire",
	"sarah",
	"mint",
	"spearmint",
	"spearlamp",
	"41",
	"23",
	"28",
	"31",
	"2831",
	"rebecca",
	"bea",
	"sophie",
}

local crossmod = {
	"MoreFluff"
}
local decks = {
	"mall",
	--"tv"
}

--#region Atlases
SMODS.Atlas{
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
}
SMODS.Atlas {
	key = "jokers",
	path = "joker/jokers.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "residents",
	path = "resident/residents.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "furrychesh",
	path = "resident/furrychesh.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "nsfw",
	path = "joker/nsfw.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "animated",
	path = "joker/animated.png",
	px = 71,
	py = 95,
	atlas_table = 'ANIMATION_ATLAS',
	frames = 2,
	fps = 2
}
SMODS.Atlas {
	key = "legendary",
	path = "joker/legendary.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "consumables",
	path = "consumables.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "enhancers",
	path = "enhancers.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "vouchers",
	path = "vouchers.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "stickers",
	path = "stickers.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "tag",
	path = "tags.png",
	px = 34,
	py = 34
}
SMODS.Atlas {
	key = "blinds",
	path = "blinds.png",
	px = 34,
	py = 34,
	atlas_table = 'ANIMATION_ATLAS',
	frames = 21
}
SMODS.Atlas {
	key = "cornericons",
	path = "ui/cornericons.png",
	px = 34,
	py = 34
}
SMODS.Atlas {
	key = "crossover_icon",
	path = "ui/crossover_icon.png",
	px = 50,
	py = 50
}
SMODS.Atlas {
	key = "lamps",
	path = "resident/lamps.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "booster",
	path = "booster.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "censor_default",
	path = "joker/sophieold/default.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "censor_bar",
	path = "joker/sophieold/bar.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "censor_featureless",
	path = "joker/sophieold/featureless.png",
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = "tenna_its_tv_time",
	path = "ui/tenna_its_tv_time.png",
	px = 505,
	py = 141,
	atlas_table = 'ANIMATION_ATLAS',
	frames = 2,
	fps = 4
}
SMODS.Atlas {
	key = "tenna_physical_challenge",
	path = "ui/tenna_physical_challenge.png",
	px = 391,
	py = 69,
	atlas_table = 'ANIMATION_ATLAS',
	frames = 18,
	fps = 30
}
--#endregion

--#region Sounds
SMODS.Sound {
	key = "carpet",
	path = "carpet.ogg"
}
SMODS.Sound {
	key = "fizz",
	path = "fizz.ogg"
}
SMODS.Sound {
	key = "squeak",
	path = "squeak.ogg"
}
SMODS.Sound {
	key = "music_spamton",
	path = "music_spamton.ogg",
	sync = false,
	pitch = 1,
	select_music_track = function()
		return G.GAME.elle_popup_shop_open == "spamton" and 10
	end,
}
SMODS.Sound {
	key = "music_tvtime",
	path = "music_tvtime.ogg",
	 sync = {
		['elle_music_tvtime'] = true,
		['elle_music_tvtime_guitar'] = true
	},
	pitch = 1
}
SMODS.Sound {
	key = "music_tvtime_guitar",
	path = "music_tvtime_guitar.ogg",
	 sync = {
		['elle_music_tvtime'] = true,
		['elle_music_tvtime_guitar'] = true
	},
	pitch = 1
}
SMODS.Sound {
	key = "tenna_jump",
	path = "tenna_jump.ogg"
}
SMODS.Sound {
	key = "tenna_land",
	path = "tenna_land.ogg"
}
SMODS.Sound {
	key = "utdr_hurt",
	path = "utdr_hurt.ogg"
}
--#endregion

--#region Font stuff
SMODS.Font {
	key = "Determination",
	path = "determination_mono.otf",
	render_scale = 100,
	TEXT_HEIGHT_SCALE = 0.83,
	TEXT_OFFSET = {x=0,y=0},
	FONTSCALE = 0.1,
	squish = 1,
	DESCSCALE = 1
}
-- Make this version for Tenna microgames 
ellejokers.undertale_font = love.graphics.newFont(SMODS.NFS.newFileData( SMODS.current_mod.path .. "assets/fonts/determination_mono.otf"),13,"mono")
--#endregion

--		[[ Config / Optional Features ]]
-- Optional Features
SMODS.current_mod.optional_features = function()
	return {
		retrigger_joker = true,
		quantum_enhancements = true,
		object_weights = true
	}
end

-- Text Colours
loc_colour('red')
G.ARGS.LOC_COLOURS.elle = HEX('FF53A9')

local burn_c = {
	HEX('a7544f'),
	HEX('de8647'),
	HEX('fdc857')
}

G.ARGS.LOC_COLOURS.elle_burn = SMODS.Gradient({
	key = "elle_burn",
	colours = {
		burn_c[1],
		burn_c[2],
		burn_c[3],
		burn_c[2]
	},
	cycle = 5
})

SMODS.DynaTextEffect {
	key = "elle_burn",
	func = function(dynatext, index, letter)
		local t = G.TIMERS.REAL * 3 + index

		letter.offset = {
			x = 0,
			y = math.cos(t) * 8
		}

		local c = math.sin(t * 0.683) + 2

		letter.colour = mix_colours(burn_c[math.ceil(c)], burn_c[math.floor(c)],c%1)
	end,
}

-- Badges
elle_badges = {
	friends = {
		text = "Friends of Elle",
		colour = HEX('40aeff')
	},
	poly = {
		text = "Girlfriends of Elle",
		colour = HEX('81cefd')
	}
}

for i, v in ipairs(lib) do
	assert(SMODS.load_file("lua/misc/"..v..".lua"))()
end

for _, v in ipairs(jokers) do
	assert(SMODS.load_file("lua/jokers/"..v..".lua"))()
end

for _, v in ipairs(residents) do
	assert(SMODS.load_file("lua/residents/"..v..".lua"))()
end

for _, v in ipairs(decks) do
	assert(SMODS.load_file("lua/decks/"..v..".lua"))()
end

for _, v in ipairs(crossmod) do
	if next(SMODS.find_mod(v)) then assert(SMODS.load_file("lua/crossmod/"..v..".lua"))() end
end

SMODS.current_mod.calculate = function(self,context)
	for k, v in pairs(ellejokers.calculate) do
		v(context)
	end
end

SMODS.current_mod.reset_game_globals = function(run_start)
	for k, v in pairs(ellejokers.reset_game_globals) do
		v(run_start)
	end
end

SMODS.Shader {
	key = "pixelated",
	path = "pixelated.fs"
}

SMODS.ScreenShader {
	key = "pixelated",
	shader = "elle_pixelated", --modprefix is necessary, this now refers to the same shader defined above

	send_vars = function(self)
		local p = ellejokers.palettes[ellejokers.mod_data.config.pixel_shader.palette]
		local w,h = love.graphics.getDimensions()
		return {
			palette = p.image,
			paletteSize = p.dims,
			dims = {w/2,h/2}
		}
	end,
	should_apply = function(self)
		return ellejokers.mod_data.config.pixel_shader.enabled
	end,
	order = 1
}

ellejokers.mod_data.menu_cards = function()
	return {
		-- Elle on title card
		{
			key = "j_elle_elle",
			no_edition = true,
			
		},
		
		-- Let it have a description
		-- ty @somethingcom515 for this lol
		func = function()
			for k, v in pairs(G.title_top.cards) do
				if v.config.center.key == 'j_elle_elle' then
					v.no_ui = false
					v.bypass_lock = true
				end
			end
			G.E_MANAGER:add_event(Event({func = function()
				local card = nil
				for i, v in ipairs(G.title_top.cards) do
					if v.config.center.set == "Default" or v.config.center.set == "Enhanced" then
						card = v
						break
					end
				end
				if card then
					for i = 1, 3 do
						delay((i+1)*.2)
						ellejokers.add_burn(card)
					end
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = .8, func = function()
						card:juice_up(.4,.4)
						play_sound("elle_fizz")
						play_sound("timpani",1,3)

						local pool = {}
						for i,v in pairs(G.P_CENTER_POOLS.elle_Resident) do
							if v.discovered then pool[#pool+1] = v end
						end

						card:set_ability(#pool>0 and pool[math.random(#pool)].key or 'elle_r_elle_marie')
						card.ability.elle_burns = 0
						card.children.front:remove()
						card.children.front = nil
					return true end}))
				end
			return true end}))
		end
	}
end

SMODS.current_mod.custom_card_areas = function(game)
	for k, v in pairs(ellejokers.custom_card_areas) do
		v(game)
	end
end