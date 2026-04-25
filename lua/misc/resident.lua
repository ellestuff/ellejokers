G.P_CENTER_POOLS["elle_Resident"] = G.P_CENTER_POOLS["elle_Resident"] or {}

ellejokers.Resident = SMODS.Center:extend {
    unlocked = true,
    discovered = false,
    pos = { x = 0, y = 0 },
    atlas = "elle_residents",
    cost = 8,
    set = 'elle_Resident',
    config = {},
    class_prefix = 'elle_r',
    required_params = {
        'key',
    }
}
G.C.SET.elle_Resident = HEX("ff53a9")
G.C.SECONDARY_SET.elle_Resident = HEX("ff53a9")


function ellejokers.custom_card_areas.resident(game)
	game.elle_resident_area = CardArea(
		0,0,
		G.CARD_W*1.1,G.CARD_H,
		{
			card_limit = 1,
			type = "joker",
			highlight_limit = 1,
			no_card_count = false,
			align_buttons = true
		}
	)
end

SMODS.UndiscoveredSprite{
	key = 'elle_Resident',
	atlas = 'residents',
	pos = {x=0,y=0},
	no_overlay = true
}

local gsr = Game.start_run
function Game:start_run(args, ...)
    gsr(self, args, ...)

	local cons_t = G.consumeables.T

    self.elle_resident_area.T.x = cons_t.x + cons_t.w - self.elle_resident_area.T.w
    self.elle_resident_area.T.y = cons_t.y + 3
end

function ellejokers.mod_data.custom_collection_tabs()
	local tally = 0
	for _, v in pairs(G.P_CENTER_POOLS.elle_Resident) do
		tally = tally + 1
	end
	return {UIBox_button{
		button = "elle_your_collection_residents",
		label = {localize("b_elle_residents")},
		count = {tally = tally, of = #G.P_CENTER_POOLS.elle_Resident},
		minw = 5,
		id = "elle_your_collection_residents"
	}}
end

slimeutils.upgrade_areas[#slimeutils.upgrade_areas+1] = "elle_resident_area"

function ellejokers.create_UIBox_your_collection_residents()
	return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.elle_Resident, {1}, {
		no_materialize = true,
		h_mod = 0.95,
	})
end

function G.FUNCS.elle_your_collection_residents(e)
	G.SETTINGS.paused = true
	G.FUNCS.overlay_menu{
		definition = ellejokers.create_UIBox_your_collection_residents(),
	}
end

function ellejokers.reset_game_globals.residents(run_start)
	if run_start then
		G.GAME.elle_resident_rate = 0
	end
end

local function do_replace(card)
	local a = #G.elle_resident_area.cards + (1 + card.ability.extra_slots_used) <= G.elle_resident_area.config.card_limit + card.ability.card_limit
	return card.ability.set == 'elle_Resident' and (#G.elle_resident_area.highlighted == 1 or (#G.elle_resident_area.cards == 1 and not a))
end

local cfbshook = G.FUNCS.check_for_buy_space
function G.FUNCS.check_for_buy_space(card)
	if card.ability.set == 'elle_Resident' then
		-- Force allow if replacing
		if do_replace(card) then return true end

		local a = #G.elle_resident_area.cards + (1 + card.ability.extra_slots_used) <= G.elle_resident_area.config.card_limit + card.ability.card_limit
		if not a then alert_no_space(card, G.elle_resident_area) end
		return a
	end
	return cfbshook(card)
end

local cbhook = G.FUNCS.can_buy
function G.FUNCS.can_buy(e)
	local card = e.config.ref_table
	local res = do_replace(card)
	
	-- Update Box
	local txt = localize(res and "elle_resident_replace" or "b_buy")
	if e.children[1].config.text ~= txt and card.highlighted then
		-- Update text
		e.children[1].config.text = txt
		e.children[1].config.text = e.children[1].config.text
		e.children[1].config.text_drawable = nil
		e.children[1]:update_text()

		-- Temporarily set func to nil to prevent crash
		e.config.func = nil
		e.UIBox:recalculate()
		e.config.func = "can_buy"
	end

	if res then
		local buy = not (card.cost > G.GAME.dollars - G.GAME.bankrupt_at) and (card.cost > 0)
		e.config.colour = buy and G.C.PURPLE or G.C.UI.BACKGROUND_INACTIVE
		e.config.button = buy and 'elle_replace_from_shop' or nil
	else cbhook(e) end
end

function G.FUNCS.elle_replace_from_shop(e)
	G.E_MANAGER:add_event(Event({func = function()
		SMODS.destroy_cards(G.elle_resident_area.highlighted[1] or G.elle_resident_area.cards[1])
	return true end}))

	G.E_MANAGER:add_event(Event({func = function()
		G.FUNCS.buy_from_shop(e)
	return true end}))
end

local w_offset = 0.6
local achook = CardArea.align_cards
function CardArea.align_cards(self)
	if self == G.elle_resident_area then
		self.T.x = self.T.x-w_offset
		self.T.w = self.T.w+w_offset*2
		
		achook(self)
		
		self.T.x = self.T.x+w_offset
		self.T.w = self.T.w-w_offset*2
	else achook(self) end
end
