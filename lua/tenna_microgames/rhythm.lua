local inputs = {}
local binds = {
	left = {"z","left"},
	right = {"x","right"},
	miss_test = {"space"}
}

local chart_full = SMODS.load_file("lua/rhythm_chart.lua")()
local chart_notes = {
	drums = {},
	lead = {},
	vocals = {}
}

local sound_req_channel = love.thread.getChannel("sound_request")
local sound_pos_channel = love.thread.getChannel('elle_pos_channel')
local function get_song_source()
	sound_req_channel:push({type = "elle_get_ambient"})
	return sound_pos_channel:demand()
end

local song_len = 0
local start_pos = 0
local song_pos = 0

local function update_inputs()
	for k, v in pairs(inputs) do
		local isDown = love.keyboard.isDown(v.binds)
		v.pressed = isDown and not v.held
		v.released = v.held and not isDown
		v.held = isDown
	end
end

local function init_inputs(binds)
	for k, v in pairs(binds) do
		inputs[k] = {
			binds = v,
			pressed = false,
			released = false,
			held = false
		}
	end
end

local function load_chartdata(pos,length)
	for track, notetable in pairs(chart_full) do
		chart_notes[track] = {}
		for _, v in pairs(notetable) do
			-- Account for wraparound in song looping
			local rel_time = (v[1]+song_len-pos)%song_len
			if rel_time>=0 and rel_time<length then
				local note = SMODS.shallow_copy(v) -- Don't use the same references from the actual chart when overriding position
				note[1] = rel_time
				chart_notes[track][#chart_notes[track]+1] = note
			end
		end
		table.sort(chart_notes[track],function(a,b)return a[1]<b[1] end)
		for _, v in pairs(chart_notes[track]) do
			print(track.." - "..v[1])
		end
	end
	
end

local microgame = {
	rhythm_layer = true,
	loc_vars = function(self) return {
		string.upper(binds.left[1]),
		string.upper(binds.right[1])
	} end,
	duration = 10
}

local combo = 0
local scrollspeed = 2.5

local sprites = {
	bg = "bg.png"
}
for k, v in pairs(sprites) do
	sprites[k] = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tvtime/rhythm/"..v)))
end

microgame.init = function()
	print("INIT!!!")
	init_inputs(binds)
	local stream = get_song_source().sound
	song_len = stream:getDuration()
	start_pos = stream:tell()
	song_pos = 0
	load_chartdata(start_pos,10)
end

microgame.update = function(dt)
	update_inputs()
	if inputs.miss_test.pressed then
		play_sound("elle_utdr_hurt")
		ellejokers.microgame.hits = ellejokers.microgame.hits+1
	end
	song_pos = song_pos+dt
end

-- bpm = 148

microgame.draw = function()
	local f = love.graphics.getFont()
	love.graphics.setFont(ellejokers.undertale_font)
	love.graphics.clear(0,0,0.5,1)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(sprites.bg,0,0,0,1,1)
	love.graphics.print(song_pos,100,100)
	love.graphics.print(microgame.duration-ellejokers.microgame.timer,100,120)

	local y = 200
	for k, v in pairs(chart_full) do
		love.graphics.print(k,10,y-30)
		for _, v2 in ipairs(v) do
			local pos = 10+v2[1]*20
			love.graphics.rectangle("fill",pos,y+20*v2[2],1,10)
		end
		y = y+100
	end
	love.graphics.rectangle("fill",10,200,1,240)
	love.graphics.rectangle("fill",10+(song_pos+start_pos)*20,200,1,240)

	--[[love.graphics.rectangle("fill",200,400,180,2)
	for i, v in ipairs(chart_notes.lead) do
		local relt = v[1]-song_pos
		local pos = 400-relt*200*scrollspeed
		if pos>20 then
			love.graphics.rectangle("fill",200+100*v[2],pos,80,20)
		end
	end]] 

	love.graphics.setFont(f)
end

return microgame