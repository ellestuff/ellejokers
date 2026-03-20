if not next(SMODS.find_mod("MoreFluff")) and FLUFF.is_rewrite then return end -- Only continue if playing with the MoreFluff rewrite

FLUFF.Colour({
	key = "jessblue",
	name = "col_jessblue",
	atlas = "consumables",
	pos = { x = 0, y = 2 },
	config = {
		upgrade_rounds = 1,
        enhancement = "m_elle_jess"
	},

	mf_art_credit = "Multi"
})

FLUFF.Colour({
	key = "ellepink",
	name = "col_ellepink",
	atlas = "consumables",
	pos = { x = 1, y = 2 },
	config = {
		upgrade_rounds = 1,
        enhancement = "m_elle_slime"
	},

	mf_art_credit = "Multi"
})

