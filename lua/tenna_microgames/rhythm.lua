local microgame = {
	loc_name = "Lightners Live",
	data = {},
	rhythm_layer = true
}

microgame.init = function()
	
end

microgame.update = function(dt)
end

microgame.draw = function()
	love.graphics.clear(0,0,0.5,1)
	love.graphics.setColor(1,1,1)
	love.graphics.print(math.floor(ellejokers.microgame.timer*10)/10,10,10)
end

return microgame