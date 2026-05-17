ellejokers.Resident {
	key = 'p2831',
	pos = { x = 2, y = 2 },
	config = { extra = { } },
	resident_colour = SMODS.Gradient({
		key = "elle_p2831",
		colours = {
			HEX('ff53a9'),
			HEX('81cefd')
		},
		cycle = 4
	}),
	in_pool = function (self, args) return false end,
	loc_vars = function(self, info_queue, card)
		return { vars = {
			"#"
		}}
	end
}