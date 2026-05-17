ellejokers.Resident {
	key = 'p28',
	pos = { x = 0, y = 2 },
	config = { extra = { } },
	resident_colour = G.ARGS.LOC_COLOURS.elle,
	in_pool = function (self, args) return false end,
	loc_vars = function(self, info_queue, card)
		return { vars = {
			"#"
		}, bio_key = 'elle_r_elle_28_31_bio' }
	end,
	resident_collection_share = {'elle_r_elle_p31'}
}