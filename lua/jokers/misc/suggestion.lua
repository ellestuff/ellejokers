local suggestion = SMODS.Joker {
	key = 'suggestion',
	blueprint_compat = false,
	config = { extra = { } },
	loc_vars = function(self, info_queue, card) return { vars = { } } end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 6, y = 1 },
	cost = 9
}

suggestion.calculate = function(self, card, context)
	if context.after then
		local faces = {}
		for _, scored_card in ipairs(context.scoring_hand) do
			if scored_card:is_face() and scored_card:get_id() ~= 12 then faces[#faces+1] = scored_card end
		end
	
		if #faces == 0 then return end

		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.4,
			func = function()
				card:juice_up(0.3, 0.5)
		return true end}))

		for _, v in ipairs(faces) do
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.2,
				func = function()
					v:flip()
					play_sound('cardSlide1', 1, 0.6)
			return true end}))
		end
		
		delay(0.4)

		for _, v in ipairs(faces) do
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.1,
				func = function()
					assert(SMODS.change_base(v, nil, 'Queen'))
					play_sound('tarot2', 1, 0.6)
					v:juice_up()
			return true end}))
		end

		delay(0.4)

		for _, v in ipairs(faces) do
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.2,
				func = function()
					v:flip()
					play_sound('cardSlide1', 1, 0.6)
			return true end}))
		end
		
		delay(0.5)

		return {
			message = localize("elle_suggestion"),
			colour = G.ARGS.LOC_COLOURS.elle
		}
	end
end