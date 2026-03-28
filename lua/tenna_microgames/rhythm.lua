--[[ Character animation notes:
Kris:
- Frame 1 while held, frame 2 on release
Susie:
- Same as Kris, though she lacks hold notes
- Left notes are drums, Right notes play the left snare
- I have no idea what causes Susie to play the left snare but it happens sometimes in footage. I'll just make it a 1/10 chance :shrug:
- Not an animation note, but Susie hits notes with a random offset, sometimes missing the note
- Raises her drumsticks a second before notes start at start of song, doesn't return to this animation after starting though
Ralsei:
- Switches between frames 1 and 2 on a set cycle
- Opens mouth for most notes, closes between notes
- Claps to beat if more than second until next note
- Cuss note animation at end of It's TV Time has additional animation after hold
	- Ralsei switches to a set frame for rest of animation and shakes horizontally briefly
]]

local song_len = 0
local start_pos = 0
local stream = nil

local chart_full = SMODS.load_file("lua/rhythm_chart.lua")()
local chart_notes = {
	drums = {},
	lead = {},
	vocals = {}
}

local sprites = {
	bg = "bg",
	kris = "kris_guitar",
	susie = "susie_drums",
	ralsei = "ralsei_sing"
}
for k, v in pairs(sprites) do
	sprites[k] = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tvtime/rhythm/"..v..".png")))
end

local quad = love.graphics.newQuad(0,0,1,1,1,1)

local characters = {
	drums = {
		sprite = sprites.susie,
		spr_dims = {x=70,y=62},
		anim_handler = function (self)
			-- Waiting before note plays
			if not self.last_note then
				local f = (chart_notes.drums[1] and chart_notes.drums[1][1]-slimeutils.microgames.timer<1) and 1 or 0
				return {x=f,y=0}
			end
			
			return {
				x = (slimeutils.microgames.timer-self.last_note[1]<0.05) and 0 or 1,
				y = self.last_note[2]+1
			}
		end,
		offset = {x=35,y=58}
	},
	guitar = {
		offset = {x=18,y=44}
	},
	vocals = {
		sprite = sprites.ralsei,
		spr_dims = {x=39,y=48},
		anim_handler = function (self)
			local beat_time = ((slimeutils.microgames.timer+start_pos)/(60/148*2))%1
			-- Clapping animation
			if (not self.last_note or not (chart_notes.drums[1] and chart_notes.drums[1][1]-slimeutils.microgames.timer<1)) and not (self.last_note and self.last_note[4]==1) then -- Additional and check at end for cuss anim
				local clap_frame = math.min(2,math.floor(math.log(-(1/(beat_time-1)))/math.log(2))) -- I used Desmos to figure this shit out lmao
				
				return {x=clap_frame,y=3}
			end


			local ret = {
				x = math.floor(beat_time*2),
				y = self.last_note and slimeutils.microgames.timer<self.last_note[1]+self.last_note[3] and 1 or 0
			}

			-- Screaming goat
			if self.last_note and self.last_note[4]==1 then
				-- spr_ralsei_cuss :3
				if slimeutils.microgames.timer>self.last_note[1]+self.last_note[3] then
					ret = {
						x=2,y=2,
						offset = slimeutils.microgames.timer-self.last_note[1]-self.last_note[3]<0.1 and {
							x = math.random()*6-3,
							y = 0
						} or nil
					}
				else
					ret.x = math.floor(beat_time*8)%2
					ret.y = 2
				end
			end

			return ret
		end,
		offset = {x=21,y=46}
	}
}
local function draw_char(char,x,y,frame)
	frame = frame or char:anim_handler() or {x=0,y=0}

	local sw,sh = char.sprite:getDimensions()
	quad:setViewport(frame.x*char.spr_dims.x,frame.y*char.spr_dims.y,char.spr_dims.x,char.spr_dims.y,sw,sh)

	love.graphics.draw(char.sprite,quad,x,y,0,2,2,(char.offset and char.offset.x or 0)+(frame.offset and frame.offset.x or 0),(char.offset and char.offset.y or 0)+(frame.offset and frame.offset.y or 0))
end

local inputs = {}
local binds = {
	left = {"z","left"},
	right = {"x","right"}
}

local sound_req_channel = love.thread.getChannel("sound_request")
local sound_pos_channel = love.thread.getChannel('elle_pos_channel')
local function get_song_source()
	sound_req_channel:push({type = "elle_get_ambient"})
	return sound_pos_channel:demand()
end

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

local combo = 0
local scrollspeed = 2.5

local function get_note_y(current_time,note_time)
	return 400-(note_time-current_time)*200*scrollspeed
end

local microgame = {
	rhythm_layer = "elle_music_tvtime_guitar",
	loc_vars = function(self) return {
		string.upper(binds.left[1]),
		string.upper(binds.right[1])
	} end,
	duration = 10
}

local function load_chartdata(pos,length,offset)
	for track, notetable in pairs(chart_full) do
		chart_notes[track] = {}
		for i, v in ipairs(notetable) do
			-- Account for wraparound in song looping
			local rel_time = (v[1]+song_len-pos)%song_len
			if rel_time>=0 and rel_time<length then
				local note = SMODS.shallow_copy(v) -- Don't use the same references from the actual chart when overriding position]
				note[1] = rel_time+(offset or 0)
				note[3] = note[3] == 0 and 0 or math.max(0,v[3]-v[1])
				-- Only include notes if they aren't onscreen at minigame start
				if get_note_y(0,note[1])<0 then chart_notes[track][#chart_notes[track]+1] = note end
			end
		end
		table.sort(chart_notes[track],function(a,b)return a[1]<b[1] end)
	end

	for _, v in pairs(characters) do
		v.last_note = nil
	end
end

microgame.init = function()
	init_inputs(binds)
	stream = get_song_source().sound
	song_len = stream:getDuration()

	microgame.hits = 0
end

microgame.start = function()
	start_pos = stream:tell()
	load_chartdata(start_pos,microgame.duration)
end

local function get_hit_notes(notes,lanebinds)
	local ret = {}
	for i,v in ipairs(lanebinds) do
		for i2, v2 in ipairs(notes) do
			if v2[2] == i-1 then
				if ret[v] and math.abs(v2[1]-slimeutils.microgames.timer) > math.abs(notes[ret[v]][1]-slimeutils.microgames.timer) then
					break
				else
					ret[v] = i2
				end
			end
		end
	end
	return ret
end

local targetnotes = nil
local lanebinds = {"left","right"}

local function handle_player_notes(notes)
	-- Get nearest notes
	targetnotes = get_hit_notes(notes,lanebinds)

	-- Hit notes
	for k, v in pairs(inputs) do
		local target = notes[targetnotes[k]]
		if target and math.abs(target[1]-slimeutils.microgames.timer)<=0.2 and v.pressed then
			table.remove(notes,targetnotes[k])
		end
	end

	-- Miss notes
	while notes and #notes>0 do
		if notes[1] and notes[1][1]-slimeutils.microgames.timer < -0.3 then
			table.remove(notes,1)
			play_sound("elle_utdr_hurt")
			microgame.hits = microgame.hits + 1
		else
			break
		end
	end
end

local function handle_bot_notes(lane)
	local notes = chart_notes[lane]
	while notes and #notes>0 do
		if notes[1] and notes[1][1]-slimeutils.microgames.timer < 0 then
			characters[lane].last_note = {slimeutils.microgames.timer, notes[1][2] or 0, notes[1][3] and notes[1][3] > 0 and math.max(notes[1][3]-(notes[1][1]-slimeutils.microgames.timer),0) or 0, notes[1][4] or 0}
			table.remove(notes,1)

		else
			break
		end
	end
end

microgame.update = function(dt)
	update_inputs()

	handle_player_notes(chart_notes.lead)
	handle_bot_notes("drums")
	handle_bot_notes("vocals")
end

-- bpm = 148

microgame.draw = function()
	local f = love.graphics.getFont()
	love.graphics.setFont(ellejokers.undertale_font)
	love.graphics.clear(0,0,0,1)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(sprites.bg,0,0,0,1,1)
	love.graphics.print(slimeutils.microgames.timer,100,100)
	love.graphics.print(stream:tell()-start_pos,100,120)
	love.graphics.print(stream:tell(),100,140)

	draw_char(characters.drums,100,300)
	draw_char(characters.vocals,300,300)

	local x = 220
	-- test rendering
	love.graphics.rectangle("fill",x,400,180,2)
	love.graphics.print("lead (kris)",x,400)
	for i, v in ipairs(chart_notes.lead) do
		love.graphics.setColor(1-(targetnotes and (targetnotes.left == i or targetnotes.right == i) and 1 or 0),1,1-(v[4] or 0))
		local pos = get_note_y(slimeutils.microgames.timer,v[1])
		local len = 400-get_note_y(0,v[3])
		if pos>-20 then
			love.graphics.rectangle("fill",x+30+100*v[2],pos,20,-len)
			love.graphics.rectangle("fill",x+100*v[2],pos,80,20)
		end
	end
	love.graphics.setColor(1,1,1)


	x = 20
	-- test rendering
	love.graphics.rectangle("fill",x,400,180,2)
	love.graphics.print("drums (susie)",x,400)
	for i, v in ipairs(chart_notes.drums) do
		local pos = get_note_y(slimeutils.microgames.timer,v[1])
		local len = 400-get_note_y(0,v[3])
		if pos>-20 then
			love.graphics.rectangle("fill",x+30+100*v[2],pos,20,-len)
			love.graphics.rectangle("fill",x+100*v[2],pos,80,20)
		end
	end

	x = 420
	-- test rendering
	love.graphics.rectangle("fill",x,400,180,2)
	love.graphics.print("vocals (ralsei)",x,400)
	for i, v in ipairs(chart_notes.vocals) do
		local pos = get_note_y(slimeutils.microgames.timer,v[1])
		local len = 400-get_note_y(0,v[3])
		if pos>-20 then
			love.graphics.rectangle("fill",x+30+50*v[2],pos,20,-len)
		end
	end

	love.graphics.setFont(f)
end

return microgame