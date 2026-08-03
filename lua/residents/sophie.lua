function ellejokers.burn_vars() return {1,3} end -- Can be hooked for silly joker effects

function ellejokers.add_burn(card,count)
	if card.config.center.set == "Default" or card.config.center.set == "Enhanced" then
		if (card.ability.elle_burns or 0)+(count or 1) > ellejokers.burn_vars()[2] then
			SMODS.calculate_context({
				elle_burned_up = true,
				card = card
			})
			SMODS.destroy_cards(card)
			G.E_MANAGER:add_event(Event({func = function()
				play_sound("elle_fizz")
			return true end}))
		else
			card.ability.elle_burn_effect = card.ability.elle_burn_effect or card.ability.elle_burns or 0
			card.ability.elle_burns = (card.ability.elle_burns or 0) + (count or 1)
			local b = card.ability.elle_burns
			G.E_MANAGER:add_event(Event({func = function()
				card:juice_up(.4,.4)
				card.ability.elle_burn_effect = b
				play_sound("elle_fizz")
			return true end}))
			G.E_MANAGER:add_event(Event({func = function()
				if card.ability.elle_burn_effect == card.ability.elle_burns then
					card.ability.elle_burn_effect = nil
				end
			return true end}))
		end
	end
end


function ellejokers.burn_desc()
	return {set="Other",key="elle_burn",vars=ellejokers.burn_vars()}
end

ellejokers.Resident {
	key = 'sophie',
	pos = { x = 3, y = 1 },
	config = { extra = { charges = 0, xmult=1, xmult_mod = 0.2 } },
	resident_colour = HEX("ffcce9"),
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = ellejokers.burn_desc()
		return {vars = {card.ability.extra.charges,card.ability.extra.xmult_mod,card.ability.extra.xmult,card.ability.extra.charges==1 and "" or "s"}}
	end,
	calculate = function(self, card, context)
		if context.after and SMODS.last_hand_oneshot then
			card.ability.extra.charges = card.ability.extra.charges+#context.scoring_hand
			return {
				message = "+"..#context.scoring_hand.." Charges",
				colour = G.ARGS.LOC_COLOURS.elle_burn
			}
		end

		if context.elle_burned_up and not context.retrigger_joker then
			card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
			return {
				message = localize("k_upgrade_ex")
			}
		end

		if context.joker_main and card.ability.extra.xmult ~= 1 then
			return {
				xmult = card.ability.extra.xmult,
			}
		end
	end,
	resident_buttons = {
		{
			text = "Burn",
			can_use = function(self, card) return card.ability.extra.charges >= #G.hand.highlighted and #G.hand.highlighted > 0 end,
			use = function(self, card)
				card.ability.extra.charges = card.ability.extra.charges - #G.hand.highlighted
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.4,
					func = function()
						play_sound('tarot1')
						card:juice_up(0.3, 0.5)
						return true
					end
				}))
				for i = 1, #G.hand.highlighted do
					delay(0.2)
					ellejokers.add_burn(G.hand.highlighted[i])
				end
				delay(0.2)
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.2,
					func = function()
						G.hand:unhighlight_all()
						return true
					end
				}))
			end,
			colour = G.ARGS.LOC_COLOURS.elle_burn,
			scale = 1.6,
			close = true
		}
	},
}

-- Hooks
local lpb_hook = SMODS.localize_perma_bonuses
function SMODS.localize_perma_bonuses(specific_vars, desc_nodes)
	lpb_hook(specific_vars,desc_nodes)

	if specific_vars and specific_vars.elle_burns then
		localize{type = 'other', key = specific_vars.elle_burns == 1 and 'elle_card_burn' or 'elle_card_burns', nodes = desc_nodes, vars = {specific_vars.elle_burns, 1+specific_vars.elle_burns*ellejokers.burn_vars()[1]}}
	end
end

local scoring_numbers = {}

local gmm_hook = Game.main_menu
function Game:main_menu(cc)
	local card = Card(0,0,0,0,nil, G.P_CENTERS.c_base)
	scoring_numbers = SMODS.shallow_copy(card.ability)
	card:remove()
	
	return gmm_hook(self,cc)
end

local cie_hook = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
	if scored_card and scored_card.ability and scored_card.ability.elle_burns and scored_card.ability.elle_burns > 0 and (scored_card.config.center.set == "Default" or scored_card.config.center.set == "Enhanced") and key~= "message" then
		local base = scoring_numbers[key] or 0

		local burn_mult = 1+scored_card.ability.elle_burns*ellejokers.burn_vars()[1]

		local new = type(amount)=="number" and ((amount or 0)-base)*burn_mult+base or amount
		
		pcall(function ()	
			if effect.message then
				effect.message = effect.message:gsub(amount,new)
			end
		end)
		
		amount = new
	end

	return cie_hook(effect, scored_card, key, amount, from_edition)
end

local burn_shader = love.graphics.newShader(SMODS.NFS.newFileData(SMODS.current_mod.path ..
	"assets/shaders/burns.fs"):getString())

local burn_shader_old = love.graphics.newShader(SMODS.NFS.newFileData(SMODS.current_mod.path ..
	"assets/shaders/burnsold.fs"):getString())

SMODS.SpriteStep {
	key = "burns",
	order = 1,
	func = function(self, image, quad, sprite)
		local s = burn_shader_old--love.keyboard.isDown("lshift") and burn_shader_old or burn_shader
		love.graphics.setShader(s)

		local card = sprite.parent or sprite.role.major
		local b = card.ability.elle_burn_effect or card.ability.elle_burns

		local w,h = quad:getTextureDimensions()
		local sw,sh = quad:getViewport()

		s:send("offset", {w,h,sw,sh})
		s:send("seed", card.unique_val)
		s:send("amp", b)
		s:send("size", {sprite.scale.x,sprite.scale.y})

		--print(sprite.scale)

		love.graphics.draw(image,quad,0,0)
	end,
	should_apply = function(self, sprite)
		local card = sprite.parent or sprite.role.major
		if card and card.facing == "front" and card.ability then
			local b = card.ability.elle_burn_effect or card.ability.elle_burns
			return b and b > 0
		end
		return false
	end
}