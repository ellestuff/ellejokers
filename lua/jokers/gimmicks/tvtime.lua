local microgames = {
	rhythm = SMODS.load_file("lua/tenna_microgames/rhythm.lua")()
}

local tenna = SMODS.Joker {
	key = 'tenna',
	config = { extra = { xmult = 1, win = 0.5, microgame = "" } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.win, card.ability.extra.xmult, microgames[card.ability.extra.microgame] and microgames[card.ability.extra.microgame].loc_name or "Unknown" } }
	end,
	rarity = 3,
	--atlas = 'jokers',
	blueprint_compat = false,
	--pos = { x = 5, y = 0 },
	cost = 10
}

local microgame_list = {"rhythm"}

ellejokers.microgame = {
	timer = 10,
	running = false
}


tenna.set_ability = function(self, card, initial, delay_sprites)
	card.ability.extra.microgame = pseudorandom_element(microgame_list, "elle_tenna_microgame")
end



local function play_microgame(card, microgame)
	-- Tenna Jump In
	G.E_MANAGER:add_event(Event({func = function()
		ellejokers.microgame = {
			timer = 10,
			running = true,
			microgame = microgames[microgame],
			card = card,
			hit = false
		}
	return true end}))

	-- Start microgame
	G.E_MANAGER:add_event(Event({func = function()
		return ellejokers.microgame.timer <= 0
	end}))

	-- Tenna Jump Out
	G.E_MANAGER:add_event(Event({func = function()
		ellejokers.microgame.running = false
	return true end}))
end

if not love.update then function love.update(dt) end end
local update_hook = love.update
function love.update(dt)
	update_hook(dt)
	if ellejokers.microgame.running then
		ellejokers.microgame.timer = ellejokers.microgame.timer - dt
		ellejokers.microgame.microgame.update(dt)
	end
end

tenna.calculate = function(self, card, context)
	if (context.before and not context.blueprint) then
		play_microgame(card, card.ability.extra.microgame)
		return { message = localize("k_reset") }
	end

	if (context.after and not context.blueprint) then
		card.ability.extra.microgame = pseudorandom_element(microgame_list, "elle_tenna_microgame")
	end

	if context.joker_main and not ellejokers.microgame.hit then
		card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.win
		return {
			message = localize("k_upgrade_ex"),
			xmult = card.ability.extra.xmult
		}
	end
end

local get_current_music_hook = SMODS.Sound.get_current_music
function SMODS.Sound:get_current_music()
	if #SMODS.find_card("j_elle_tenna")>0 then
		return ellejokers.microgame.running and ellejokers.microgame.microgame and ellejokers.microgame.microgame.rhythm_layer and "elle_music_tvtime_guitar" or "elle_music_tvtime"
	end

	get_current_music_hook(self)
end

tenna.generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
	SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)

	local s = G.TILESCALE*G.TILESIZE
	local tvtime_sprite = SMODS.create_sprite(0,0,505/s*.5,141/s*.5, "elle_tenna_its_tv_time", {x=0,y=0})
	local pc_sprite = SMODS.create_sprite(0,0,391/s*.75,69/s*.75, "elle_tenna_physical_challenge", {x=0,y=0})

	local tvtime = {
		n = G.UIT.R,
		config = { align = 'cm', padding = -0.1, no_fill = true },
		nodes = {
			{
				n = G.UIT.O,
				config = { align = 'cm', object = tvtime_sprite }
			}
		}
	}
	local pc = {
		{
			n = G.UIT.O,
			config = { align = 'cm', object = pc_sprite }
		}
	}

	full_UI_table.name[1].nodes[1].nodes[1].config.object:remove()
	full_UI_table.name[1].nodes[1] = tvtime
	full_UI_table.main[2] = pc
end
