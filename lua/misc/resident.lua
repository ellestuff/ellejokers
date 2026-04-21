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
		label = {localize("b_quests")},
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