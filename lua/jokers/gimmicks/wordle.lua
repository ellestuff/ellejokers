local wordle = SMODS.Joker {
	key = 'wordle',
	config = { extra = {
		xmult = 1,
		xmult_mod = .75,
		wordle = {
			word = "joker",
			guesses = {"slime","horse","japes","baked","alter"},
			current_guess = "",
			reveal_status = {},
			inactive = false
	}}},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult_mod, card.ability.extra.xmult } }
	end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 5, y = 4 },
	cost = 9,
	calculate = function(self, card, context)
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end
	end
}

ellejokers.wordle_words = {
	valid = SMODS.load_file("wordle_words/valid_words.lua")(),
	bank = SMODS.load_file("wordle_words/word_bank.lua")()
}

local function wordle_reset(card)
	card.ability.extra.xmult = 1
	card.ability.extra.wordle = {
		word = pseudorandom_element(ellejokers.wordle_words.bank,"elle_wordle_word"),
		guesses = {},
		current_guess = "",
		reveal_status = {},
		inactive = false
	}
end

wordle.add_to_deck = function (self, card, from_debuff)
	wordle_reset(card)
end

wordle.calculate = function(self, card, context)
	if (context.ante_change and not context.blueprint) then
		wordle_reset(card)
		return { message = localize("k_reset") }
	end

	if context.joker_main and card.ability.extra.xmult ~= 1 then
		return { xmult = card.ability.extra.xmult }
	end
end

local wordle_sprites = {
	back = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/wordle_back.png"))),
	chars = love.graphics.newImage(love.image.newImageData(SMODS.NFS.newFileData(SMODS.current_mod.path .. "assets/extra_images/wordle_txt.png")))
}

local wordle_quads = {
	back = love.graphics.newQuad( 1, 1, 9, 9, 31, 21 ),
	chars = love.graphics.newQuad( 1, 1, 5, 5, 43, 25 )
}

local function draw_wordle_letter(x,y,char,back, xscale)
	wordle_quads.back:setViewport( back%3*10+1, math.floor(back/3)*10+1, 9, 9, 31, 21 )
	love.graphics.draw(wordle_sprites.back,wordle_quads.back,x+4.5,y+4.5,0,xscale,1,4.5,4.5)
	
	local charnum = string.byte(string.lower(char))
	if charnum == nil then return end
	
	charnum = charnum-string.byte("a")

	if charnum == math.min(math.max(charnum,0),25) then
		wordle_quads.chars:setViewport( charnum%7*6+1, math.floor(charnum/7)*6+1, 5, 5, 43, 25 )
		love.graphics.draw(wordle_sprites.chars,wordle_quads.chars,x+4.5,y+4.5,0,xscale,1,2.5,2.5)
	end
end

local function get_wordle_colours(guess, answer)
	local colours = {0,0,0,0,0}
	local chars = {}
	local answer2 = {}

	for i = 1, #guess, 1 do
		chars[#chars+1] = string.sub(guess,i,i)
	end

	for i = 1, #answer, 1 do
		answer2[#answer2+1] = string.sub(answer,i,i)
	end

	-- Get green letters
	for i, v in ipairs(answer2) do
		if chars[i] == v then
			colours[i] = 2
			chars[i] = " "
			answer2[i] = " "
		end
	end

	-- Get yellow letters
	for i, v in ipairs(answer2) do
		if v ~= " " then
			for j, v2 in ipairs(chars) do
				if v == v2 and colours[j] == 0 then
					colours[j] = 1
					v2 = " "
					v = " "
				end
			end
		end
	end

	return colours
end

local function wordle_draw(card)
	love.graphics.clear()

	local wordledata = card.ability.extra.wordle
	for line = 1, 6, 1 do
		-- Get line word
		local word = ""
		if line <= #wordledata.guesses then
			word = wordledata.guesses[line]
		elseif line == #wordledata.guesses+1 then
			word = wordledata.current_guess
		end

		local colours = word == "" or get_wordle_colours(word, wordledata.word)

		for chars = 1, 5, 1 do
			local reveal_status = line == #wordledata.guesses and math.max(math.min(wordledata.reveal_status[6-chars] or 2,2),0) or 2
			local xs = (math.cos(math.pi*reveal_status)+1)/2

			local char = string.sub(word,chars,chars)
			local back = 0
			if line <= #wordledata.guesses and reveal_status > 1 then
				back = colours[chars]+2
			elseif char ~= "" then back = 1 end

			draw_wordle_letter(11*chars-2, 12*line+6, char, back, xs)
		end
	end
end

SMODS.DrawStep {
	key = 'wordlecanvas',
	order = 100,
	func = function(self, layer)
		if self.config.center.key == "j_elle_wordle" and not slimeutils.card_obscured(self) then
			if not self.wordlecanvas then
				self.wordlecanvas = SMODS.CanvasSprite({
					canvasScale = 1
				})
			end

			local c = love.graphics.getCanvas()

			love.graphics.push()
			love.graphics.origin()
			self.wordlecanvas.canvas:renderTo(function() wordle_draw(self) end)
			love.graphics.pop()

			self.wordlecanvas.role.draw_major = self
			self.wordlecanvas:draw_shader("dissolve", nil, nil, nil, self.children.center)
		end
	end
}

local function handle_wordle_end(card)
	local wordledata = card.ability.extra.wordle
	local win = wordledata.guesses[#wordledata.guesses] == wordledata.word

	if win or #wordledata.guesses == 6 then
		card.ability.extra.xmult = win and (7-#wordledata.guesses)*card.ability.extra.xmult_mod+1
		wordledata.inactive = true

		SMODS.calculate_effect({ message_card = card,
			message = win and "Win!" or string.upper(wordledata.word.."..."),
			colour = win and G.C.GREEN or G.C.GOLD
		}, card)

		if win and #wordledata.guesses <= 2 then check_for_unlock({type = "elle_wordlelucky"}) end

		if card.states.hover.is then
			card:stop_hover()
			card:hover()
		end
	end
end

local function submit_letter(card, char)
	-- Check if valid letter
	charkey = string.byte(string.lower(char))-string.byte("a")
	if (charkey == math.min(math.max(charkey,0),25) or char == " ") and #card.ability.extra.wordle.current_guess<5 then
		card.ability.extra.wordle.current_guess = card.ability.extra.wordle.current_guess .. char
		card:juice_up(0.1,0.1)
		play_sound("button",1,.5)
	end
end

local function submit_word(card)
	local wordledata = card.ability.extra.wordle

	if not ellejokers.wordle_words.valid[wordledata.current_guess] then
		card:juice_up()
		play_sound("cancel")
		return
	end

	wordledata.reveal_status = {-.8,-.6,-.4,-.2,0}
	wordledata.guesses[#wordledata.guesses+1] = wordledata.current_guess
	wordledata.current_guess = ""
	play_sound("tarot1",1,.5)
	card:juice_up(0.4,0.4)
	handle_wordle_end(card)
end

-- Hacky ass solution lmao
if not love.textinput then function love.textinput(text) end end
local text_input_hook = love.textinput
function love.textinput(text)
	if G.jokers then
		for _, v in ipairs(G.jokers.cards) do
			if v.config.center.key == "j_elle_wordle" and not v.ability.extra.wordle.inactive then
				submit_letter(v, text)
			end
		end
	end
	text_input_hook(text)
end

if not love.keypressed then function love.keypressed(key,unicode) end end
local key_pressed_hook = love.keypressed
function love.keypressed(key,unicode)
	if G.jokers then
		for _, v in ipairs(G.jokers.cards) do
			if v.config.center.key == "j_elle_wordle" and not v.ability.extra.wordle.inactive then
				if key == "backspace" and #v.ability.extra.wordle.current_guess>0 then
					v.ability.extra.wordle.current_guess = string.sub(v.ability.extra.wordle.current_guess,1,#v.ability.extra.wordle.current_guess-1)
					v:juice_up(0.1,0.1)
					play_sound("button",1.2,.5)
				elseif key == "return" and #v.ability.extra.wordle.current_guess == 5 then
					submit_word(v)
				end
			end
		end
	end
	key_pressed_hook(key,unicode)
end


wordle.update = function (self, card, dt)
	if card.wordlecanvas then
		local wordledata = card.ability.extra.wordle
		for i, v in ipairs(wordledata.reveal_status) do
			wordledata.reveal_status[i] = v + dt
		end
		if #wordledata.reveal_status>0 and wordledata.reveal_status[#wordledata.reveal_status] >= 2 then
			table.remove(wordledata.reveal_status,#wordledata.reveal_status)
		end
	end
end