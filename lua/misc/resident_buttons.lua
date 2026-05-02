SMODS.DrawStep {
	key = 'elle_resident_buttons',
	order = -30, -- before the Card is drawn
	func = function(card, layer)
		if card.children.elle_resident_buttons then
			card.children.elle_resident_buttons:draw()
		end
	end
}

function G.FUNCS.elle_resident_button(e)
	e.config.button_thingy:use(e.config.ref_table)
	if e.config.button_thingy.close and (type(e.config.button_thingy.close) == "function" and e.config.button_thingy:close(e.config.ref_table) or true) then
		e.config.ref_table.area:remove_from_highlighted(e.config.ref_table)
	end
end

function G.FUNCS.elle_resident_button_func(e)
	--local button = e.config.button_thingy
	local yes = e.config.button_thingy:can_use(e.config.ref_table)

	e.config.colour = yes and (e.config.button_thingy.colour or G.C.BLUE) or G.C.UI.BACKGROUND_INACTIVE
	e.config.button = yes and 'elle_resident_button' or nil
end

local function create_resident_buttons_ui(card)
	local buttons = {}


	for i, v in ipairs(card.config.center.resident_buttons) do
			
		local bTable = card.config.center.resident_buttons[i]
		
		buttons[#buttons+1] = {
			n = G.UIT.R,
			config = {
				align = "cr"
			},
			nodes = {
				{ n = G.UIT.R,
				config = {
					colour = bTable.colour or G.C.BLUE,
					align = 'cm',
					padding = 0.15,
					r = 0.08*bTable.scale,
					hover = true,
					shadow = true,
					button = 'elle_resident_button',
					func = 'elle_resident_button_func',
					ref_table = card,
					ref_value = "resident_buttons",
					button_thingy = bTable
				},
				nodes = {
					{ n = G.UIT.C, nodes = {
						{ n = G.UIT.T, config = { text = type(bTable.text) == "function" and bTable:text(card) or bTable.text, scale = 0.3*bTable.scale, } }
					}},
					{ n = G.UIT.C }
				}
		}}}
	end

	return UIBox{
		definition = {
			n = G.UIT.ROOT,
			config = {
				colour = G.C.CLEAR,
				padding = 0.1,
				align = "cr"
			},
			nodes = buttons
		},
		config = {
			align = 'cl', -- position relative to the card, meaning "center left". Follow the SMODS UI guide for more alignment options
			major = card,
			parent = card,
			offset = { x = .5, y = 0 } -- depends on the alignment you want, without an offset the button will look as if floating next to the card, instead of behind it
		}
	}
end

local highlight_ref = Card.highlight
function Card.highlight(self, is_highlighted)
	if is_highlighted and self.config.center.resident_buttons then
		self.children.elle_resident_buttons = create_resident_buttons_ui(self)
	elseif self.children.elle_resident_buttons then
		self.children.elle_resident_buttons:remove()
		self.children.elle_resident_buttons = nil
	end

	return highlight_ref(self, is_highlighted)
end