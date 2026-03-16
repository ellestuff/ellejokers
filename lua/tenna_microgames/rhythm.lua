local inputs = {}
local binds = {
	left = {"z","left"},
	right = {"x","right"},
	miss_test = {"space"}
}

local function update_inputs()
	for k, v in pairs(inputs) do
		local isDown = love.keyboard.isDown(binds[k])
		v.pressed = isDown and not v.held
		v.released = v.held and not isDown
		v.held = isDown
	end
end

local function init_inputs()
	for k, _ in pairs(binds) do
		inputs[k] = {
			pressed = false,
			released = false,
			held = false
		}
	end
end

local microgame = {
	rhythm_layer = true,
	loc_vars = function(self) return {string.upper(binds.left[1]),string.upper(binds.right[1])} end,
	duration = 5
}

local sprites = {
	bg = "bg.png"
}
for k, v in pairs(sprites) do
	sprites[k] = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/tvtime/rhythm/"..v)))
end

microgame.init = function()
	init_inputs()
end

microgame.update = function(dt)
	update_inputs()
	if inputs.miss_test.pressed then
		play_sound("elle_utdr_hurt")
		ellejokers.microgame.hits = ellejokers.microgame.hits+1
	end
end

microgame.draw = function()
	love.graphics.clear(0,0,0.5,1)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(sprites.bg,0,0,0,1,1)
end

return microgame