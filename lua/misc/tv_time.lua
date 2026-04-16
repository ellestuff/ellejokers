ellejokers.tvtime = {
	microgames = {},
	pre_play_queue = {},
	microgame_list = {
		"rhythm"
	}
}

local tennasprites = {
	jump = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tvtime/tenna_jump.png"))),
	screen = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tvtime/tenna.png"))),
	static = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tvtime/tenna_static.png")))
}
local staticquad = love.graphics.newQuad(0,0,36,25,36*8,25)

local mask_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		if (Texel(texture, texture_coords).a == 0.0) {
			discard;
		}
		return vec4(1.0);
	}
]]

local stencilScale = 0

local function stencilfunc()
	local w,h = love.graphics.getDimensions()

	local sh = love.graphics.getShader()
	love.graphics.setShader(mask_shader)
	love.graphics.draw(tennasprites.static,staticquad,w/2,h/2,0,2*stencilScale,2*stencilScale,18,12)
	love.graphics.setShader(sh)
end

local lastt=0
ellejokers.tvtime.anims = {
	durations = {start = 0.75, finish = 0.75, pre_game = 0.5, post_game = 0.5},

	start = function(time,frame)
		local w,h = love.graphics.getDimensions()
		if frame == 1 then play_sound("elle_tenna_jump") end
		local t = math.min(time/0.75,1)
		if t == 1 and lastt~=t then play_sound("elle_tenna_land") end
		
		love.graphics.draw(tennasprites.jump,(w+(w*(1-t)*1.1))/2,h/2-math.sin(t*math.pi)*h/8*2,0,2,2,45,41)
		lastt=t
	end,

	finish = function(time,frame)
		local w,h = love.graphics.getDimensions()
		if frame == 1 then play_sound("elle_tenna_jump") end
		local t = math.min(time/0.75,1)
		if t == 1 and lastt~=t then play_sound("elle_tenna_land") end

		love.graphics.draw(tennasprites.jump,(w+(w*t*1.1))/2,h/2-math.sin(t*math.pi)*h/5*2,0,-2,2,45,41)

		lastt=t
	end,

	pre_game = function (time,frame)
		local w,h = love.graphics.getDimensions()
		local t = time/0.5
		local s = 1/math.max((1-t),0.01)
		
		if frame == 1 and slimeutils.microgames.queue[1].t.juice then
			slimeutils.microgames.queue[1].t.juice:juice_up()
			play_sound("cardSlide1")
		end

		love.graphics.draw(tennasprites.screen,w/2,h/2,0,2*s,2*s,45,41)

		stencilScale = s
		love.graphics.stencil(stencilfunc, "replace", 2)
		love.graphics.setStencilTest("equal", 2)
		slimeutils.microgames.draw()
		love.graphics.setStencilTest()

		love.graphics.setColor(1,1,1,(1-t)*4-1.6)
		staticquad:setViewport( math.floor(t*4%8)*36, 0, 36, 26, 36*8, 25 )
		love.graphics.draw(tennasprites.static,staticquad,w/2,h/2,0,2*s,2*s,18,12)
	end,

	post_game = function (time)
		local w,h = love.graphics.getDimensions()
		local t = time/0.5
		local s = math.max(1/t,1)
		
		love.graphics.draw(tennasprites.screen,w/2,h/2,0,2*s,2*s,45,41)
		
		stencilScale = s
		love.graphics.stencil(stencilfunc, "replace", 2)
		love.graphics.setStencilTest("equal", 2)
		slimeutils.microgames.draw()
		love.graphics.setStencilTest()

		staticquad:setViewport( math.floor(t*4%8)*36, 0, 36, 26, 36*8, 25 )
		love.graphics.setColor(1,1,1,t*4-1.6)
		love.graphics.draw(tennasprites.static,staticquad,w/2,h/2,0,2*s,2*s,18,12)
	end
}

function ellejokers.tvtime.register_microgame(name,path)
	ellejokers.tvtime.microgames[name] = SMODS.load_file(path)()
end

for _, v in ipairs(ellejokers.tvtime.microgame_list) do
	ellejokers.tvtime.register_microgame(v,"lua/tenna_microgames/"..v..".lua")
end

local get_current_music_hook = SMODS.Sound.get_current_music
function SMODS.Sound:get_current_music()
	if #SMODS.find_card("j_elle_tenna")>0 or G.GAME.selected_back.effect.center.key == "b_elle_tenna" then
		local track = "elle_music_tvtime"
		if slimeutils.microgames.playing and slimeutils.microgames.microgame and slimeutils.microgames.microgame.rhythm_layer then
			local rl = slimeutils.microgames.microgame.rhythm_layer
			track = type(rl) == "function" and rl() or rl
		end
		return track
	end

	get_current_music_hook(self)
end

local hook = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
	SMODS.calculate_context { elle_on_play_press = true }
	
	G.E_MANAGER:add_event(Event({func = function()
		slimeutils.microgames:init(ellejokers.tvtime.pre_play_queue,ellejokers.tvtime.anims)
	return true end }))
	
	hook(e)
end
