-- So much of this is recycled from Wormhole's Meteor Shower lmfao (which was coded by me)
local bubbles = {}

ellejokers.Resident {
	key = 'bea',
	pos = { x = 0, y = 1 },
	config = { extra = { mult_mod = 2 } },
	loc_vars = function(self, info_queue, card)
		return {vars = { card.ability.extra.mult_mod }}
	end,
	calculate = function(self, card, context)
		if context.individual and not context.end_of_round and context.cardarea == G.play and #G.hand.cards > 0 then
			G.E_MANAGER:add_event(Event({
				func = function()
					ellejokers.create_bubble(card.ability.extra.mult_mod)
					card:juice_up(0.4,0.4)
					return true
				end
			}))
		end
		if context.final_scoring_step then
			G.E_MANAGER:add_event(Event({func=function()
			return #bubbles==0 end}))
		end
	end,
	resident_colour = HEX("c3543a"),
}

local bubble_sprite = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path ..
	"assets/extra_images/bea_bubble.png")))

local bubble_click = function(bubble)
	local target = pseudorandom_element(G.hand.cards,"elle_bea_bubble")
	if target then
		target.ability.perma_mult = target.ability.perma_mult + bubble.mult
		target:juice_up()

		SMODS.calculate_effect({
			message = localize { type = 'variable', key = 'a_mult', vars = { bubble.mult } },
			colour = G.C.MULT,
			instant = true
		},target)
	end
	play_sound("multhit1")

	bubble.clicked = true
end


local vel_mult = 100
local sin_mult = 75

function ellejokers.create_bubble(value)
	local scale = pseudorandom("elle_bubble_size")*3+1
	local bubble = {
		pos = {
			x = pseudorandom("elle_bubble_x") * (love.graphics.getWidth() - 128) + 64,
			y = love.graphics.getHeight()+scale*16,
		},
		offset = {
			timer = 0,
			amt = 0
		},
		scale = scale,
		mult = value
	}
	bubbles[#bubbles + 1] = bubble
end

-- Update hook :)
if not love.update then function love.update(dt) end end
local update_hook = love.update
function love.update(dt)
	update_hook(dt)

	for i, v in ipairs(bubbles) do
		if v.clicked then table.remove(bubbles, i) else
			v.pos.y = v.pos.y - dt * vel_mult * v.scale

			v.offset.timer = (v.offset.timer + dt) % math.pi
			v.offset.amt = math.sin(v.offset.timer*2) * sin_mult

			if v.pos.y < -32*v.scale then table.remove(bubbles, i) end
		end
	end
end

if not love.mousepressed then function love.mousepressed(x, y, button, istouch, presses) end end
local click_hook = love.mousepressed
function love.mousepressed(x, y, button, istouch, presses)
	for i, v in ipairs(bubbles) do
		local dist = math.sqrt(math.abs(x - (v.pos.x+v.offset.amt)) ^ 2 + math.abs(y - v.pos.y) ^ 2)
		if dist < 16*v.scale and not v.clicked then
			bubble_click(v)
			return
		end
	end

	click_hook(x, y, button, istouch, presses)
end

if not love.draw then function love.draw() end end
local draw_hook = love.draw
function love.draw()
	draw_hook()

	love.graphics.setColor(1, 1, 1, 1)
	--love.graphics.print("Bubble Count: "..#bubbles,10,50) -- Debug line
	for i, v in ipairs(bubbles) do
		love.graphics.draw(bubble_sprite, v.pos.x+v.offset.amt, v.pos.y, 0, 1*v.scale, 1*v.scale, 16, 16)
	end
end
