ellejokers.Resident {
	key = 'p31',
	pos = { x = 1, y = 2 },
	config = { extra = { } },
	resident_colour = HEX('81cefd'),
	in_pool = function (self, args) return false end,
	loc_vars = function(self, info_queue, card) return { vars = { "#" } } end,
	no_collection = true -- Don't give own collection entry as sharing with #28
}