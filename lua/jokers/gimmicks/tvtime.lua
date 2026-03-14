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

local tennasprites = {
	jump = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tenna_jump.png"))),
	screen = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tenna.png"))),
	static = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tenna_static.png")))
}
local staticquad = love.graphics.newQuad(0,0,36,25,36*8,25)


ellejokers.microgame = {
	running = false
}


tenna.set_ability = function(self, card, initial, delay_sprites)
	card.ability.extra.microgame = pseudorandom_element(microgame_list, "elle_tenna_microgame")
end

function ellejokers.microgame.play(card, microgame)
	-- Tenna Jump In
	G.E_MANAGER:add_event(Event({func = function()
		-- first frame stuff
		if not ellejokers.microgame.running then
			-- Don't override the whole table!!!
			ellejokers.microgame.timer = 1
			ellejokers.microgame.running = true
			ellejokers.microgame.playing = false
			ellejokers.microgame.microgame = microgames[microgame]
			ellejokers.microgame.card = card
			ellejokers.microgame.hit = false
			ellejokers.microgame.tennaanim = {
				stage = 0,
				timer = 1.5,
			}

			-- Make a canvas with the correct dimensions, destroying the old one if it still exists
			if ellejokers.microgame.canvas then ellejokers.microgame.canvas:release() end
			ellejokers.microgame.canvas = love.graphics.newCanvas(ellejokers.microgame.microgame.width and ellejokers.microgame.microgame.width*2 or 640, ellejokers.microgame.microgame.height and ellejokers.microgame.microgame.height*2 or 480)

			ellejokers.microgame.microgame.init()

			play_sound("elle_tenna_jump")
		end
	return true end}))
	
	-- Start microgame
	G.E_MANAGER:add_event(Event({func = function()
		return ellejokers.microgame.timer <= 0
	end}))

	-- Stop minigame
	G.E_MANAGER:add_event(Event({func = function()
		card.ability.extra.xmult = ellejokers.microgame.hit and 1 or card.ability.extra.xmult + card.ability.extra.win
		ellejokers.microgame.playing = false
		ellejokers.microgame.tennaanim.stage = 3
		ellejokers.microgame.tennaanim.timer = 1.5
	return true end}))

	-- Tenna Jump Out
	G.E_MANAGER:add_event(Event({func = function()
		return ellejokers.microgame.tennaanim.stage == 5
	end}))
end

if not love.update then function love.update(dt) end end
local update_hook = love.update
function love.update(dt)
	update_hook(dt)
	if ellejokers.microgame.running then
		if not ellejokers.microgame.playing then
			ellejokers.microgame.tennaanim.timer = ellejokers.microgame.tennaanim.timer - dt * 1.5
			if ellejokers.microgame.tennaanim.timer <= 0 then
				ellejokers.microgame.tennaanim.stage = ellejokers.microgame.tennaanim.stage + 1
				ellejokers.microgame.tennaanim.timer = 1.5

				if ellejokers.microgame.tennaanim.stage == 2 then ellejokers.microgame.playing = true
				elseif ellejokers.microgame.tennaanim.stage == 5 then ellejokers.microgame.running = false
				else play_sound(ellejokers.microgame.tennaanim.stage%2==1 and "elle_tenna_land" or "elle_tenna_jump") end
			end
		end
		
		if ellejokers.microgame.playing and ellejokers.microgame.timer > 0 then
			ellejokers.microgame.timer = ellejokers.microgame.timer - dt
			ellejokers.microgame.microgame.update(dt)
		end
		
	end
end

local mask_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		if (Texel(texture, texture_coords).a == 0.0) {
			discard;
		}
		return vec4(1.0);
	}
]]

local function stencilfunc()
	local w,h = love.graphics.getDimensions()
	local tanim = ellejokers.microgame.tennaanim
	local s = 1/math.min(tanim.stage == 1 and tanim.timer or 1.5-tanim.timer,1)
	
	local sh = love.graphics.getShader()
	love.graphics.setShader(mask_shader)
	love.graphics.draw(tennasprites.static,staticquad,w/2,h/2,0,2.25*s,2.25*s,18,12)
	love.graphics.setShader(sh)
end

if not love.draw then function love.draw() end end
local draw_hook = love.draw
function love.draw()
	draw_hook()
	if ellejokers.microgame.running and ellejokers.microgame.canvas then
		local w,h = love.graphics.getDimensions()
		love.graphics.push()
		love.graphics.origin()
		local c = love.graphics.getCanvas()
		love.graphics.setCanvas({ellejokers.microgame.canvas, stencil = true})
		ellejokers.microgame.microgame.draw()
		love.graphics.setCanvas(c)
		love.graphics.pop()

		local mw = (ellejokers.microgame.microgame.width or 320)*2
		local mh = (ellejokers.microgame.microgame.height or 240)*2

		local tanim = ellejokers.microgame.tennaanim

		if tanim.stage == 0 then
			love.graphics.draw(tennasprites.jump,(w+(w*tanim.timer/1.5*1.3))/2,h/2-math.sin(tanim.timer/1.5*math.pi)*400,0,2.25,2.25,45,41)
		elseif tanim.stage == 1 or tanim.stage == 3 then
			local s = 1/math.min(tanim.stage == 1 and tanim.timer or 1.5-tanim.timer,1)
			love.graphics.draw(tennasprites.screen,w/2,h/2,0,2.25*s,2.25*s,45,41)
			
			love.graphics.stencil(stencilfunc, "replace", 2)
			love.graphics.setStencilTest("equal", 2)
    		love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill",0,0,w,h)
    		love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(ellejokers.microgame.canvas,w/2,h/2,0,h/720,h/720,mw/2,mh/2)

			love.graphics.setStencilTest()

			local a = (tanim.stage == 1 and tanim.timer or 1.5-tanim.timer)*4-1.6
			
    		love.graphics.setColor(1, 1, 1, a)
			staticquad:setViewport( math.floor(tanim.timer*4%8)*36, 0, 36, 26, 36*8, 25 )
			love.graphics.draw(tennasprites.static,staticquad,w/2,h/2,0,2.25*s,2.25*s,18,12)
		elseif tanim.stage == 4 then
			love.graphics.draw(tennasprites.jump,(w+(w*(1.5-tanim.timer)/1.5*1.3))/2,h/2-math.sin(tanim.timer/1.5*math.pi)*400,0,-2.25,2.25,45,41)
		else
			love.graphics.clear(0,0,0,1)
			love.graphics.draw(ellejokers.microgame.canvas,w/2,h/2,0,h/720,h/720,mw/2,mh/2)
		end
	end
end

tenna.calculate = function(self, card, context)
	if (context.on_play_press and not context.blueprint) then
		ellejokers.microgame.play(card, card.ability.extra.microgame)
	end

	if (context.after and not context.blueprint) then
		card.ability.extra.microgame = pseudorandom_element(microgame_list, "elle_tenna_microgame")
	end

	if context.joker_main then
		return {
			message = localize(card.ability.extra.xmult==1 and "k_reset" or "k_upgrade_ex"),
			extra = card.ability.extra.xmult==1 and nil or {
				xmult = card.ability.extra.xmult
			}
		}
	end
end

local get_current_music_hook = SMODS.Sound.get_current_music
function SMODS.Sound:get_current_music()
	if #SMODS.find_card("j_elle_tenna")>0 then
		return ellejokers.microgame.running and ellejokers.microgame.playing and ellejokers.microgame.microgame and ellejokers.microgame.microgame.rhythm_layer and "elle_music_tvtime_guitar" or "elle_music_tvtime"
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

local hook = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
	ret = hook(e)
	SMODS.calculate_context { on_play_press = true }
end