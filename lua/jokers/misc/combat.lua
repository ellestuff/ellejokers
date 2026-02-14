local combat = SMODS.Joker {
	key = 'combat',
	blueprint_compat = false,
	config = { extra = { } },
	loc_vars = function(self, info_queue, card) return {} end,
	rarity = 3,
	atlas = 'jokers',
	pos = { x = 6, y = 5 },
	cost = 10
}

local bubbles = love.graphics.newImage( love.image.newImageData(NFS.newFileData( ellejokers.mod_data.path .. "assets/extra_images/bubbles.png") ) )

SMODS.Shader {
	key = 'combat',
	path = 'combat.fs',

	send_vars = function(self, sprite, card)
		return {
			--dims = {63,13},
			--pos = {4,78},
			--hpFac = .5,
			--palette = {HEX("ff7971"), HEX("fd5f55"), HEX("dd463c"), HEX("aa4740")}, -- og shader uses vec3 but this is easier to write
			--bubbles = bubbles.image
		}
	end
} 

SMODS.DrawStep {
	key = "elle_combat",
	order = 1,
	func = function(self, layer)
		if self.config.center_key == "j_elle_combat" then
			self.children.center:draw_shader('elle_combat', nil, self.ARGS.send_to_shader)
		end
	end,
	conditions = { vortex = false, facing = 'front' }
}