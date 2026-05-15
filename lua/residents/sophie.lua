function ellejokers.burn_vars() return {1,3} end -- Can be hooked for silly joker effects

function ellejokers.add_burn(card,count)
	if card.config.center.set == "Default" or card.config.center.set == "Enhanced" then
		if (card.ability.elle_burns or 0)+(count or 1) > ellejokers.burn_vars()[2] then
			SMODS.destroy_cards(card)
			SMODS.calculate_context({
				elle_burned_up = true,
				card = card
			})
		else
			card:juice_up(.4,.4)
			card.ability.elle_burns = (card.ability.elle_burns or 0) + (count or 1)
		end
		play_sound("elle_fizz")
	end
end


function ellejokers.burn_desc()
	return {set="Other",key="elle_burn",vars=ellejokers.burn_vars()}
end

ellejokers.Resident {
	key = 'sophie',
	pos = { x = 3, y = 1 },
	config = { extra = { charges = 0, xmult=1, xmult_mod = 0.25 } },
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

		if context.elle_burned_up then
			card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
			return {
				message = localize("k_upgrade_ex")
			}
		end
	end,
	resident_buttons = {
		{
			text = "Burn",
			can_use = function(self, card) return slimeutils.can_use(card,G.elle_resident_area) and card.ability.extra.charges >= #G.hand.highlighted and #G.hand.highlighted > 0 end,
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
					local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.2,
						func = function()
							ellejokers.add_burn(G.hand.highlighted[i])
							return true
						end
					}))
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

		local new = ((amount or 0)-base)*burn_mult+base
		
		pcall(function ()	
			if effect.message then
				effect.message = effect.message:gsub(amount,new)
			end
		end)
		
		amount = new
	end

	return cie_hook(effect, scored_card, key, amount, from_edition)
end

local burn_canvases = {}

local burn_quad = love.graphics.newQuad(0,0,71,95,71,95)

local cd_hook = Card.draw
function Card:draw(layer)
	if self.children.front then
		self.children.center.config.elle_burns = self.ability.elle_burns or nil
		self.children.center.config.elle_unique_val = self.ability.elle_burns and self.unique_val or nil
		self.children.front.config.elle_burns = self.ability.elle_burns or nil
		self.children.front.config.elle_unique_val = self.ability.elle_burns and self.unique_val or nil
	end
	cd_hook(self, layer)
end

-- idk how do get it to pull from the file correctly so i'm just doing this
local burn_shader = love.graphics.newShader([[
extern vec4 offset;
extern float seed;
extern float amp;

vec2 random(vec2 value){
	value = vec2( dot(value, vec2(127.1,311.7)+seed),
				  dot(value, vec2(269.5,183.3)+seed));
	return -1.0 + 2.0 * fract(sin(value) * 43758.5453123);
}

float seamless_noise(vec2 uv, vec2 _period) {
	uv = uv * 40.;
	vec2 cellsMinimum = floor(uv);
	vec2 cellsMaximum = ceil(uv);
	vec2 uv_fract = fract(uv);
	
	cellsMinimum = mod(cellsMinimum, _period);
	cellsMaximum = mod(cellsMaximum, _period);
	
	vec2 blur = smoothstep(0.0, 1.0, uv_fract);
	
	vec2 lowerLeftDirection = random(vec2(cellsMinimum.x, cellsMinimum.y));
	vec2 lowerRightDirection = random(vec2(cellsMaximum.x, cellsMinimum.y));
	vec2 upperLeftDirection = random(vec2(cellsMinimum.x, cellsMaximum.y));
	vec2 upperRightDirection = random(vec2(cellsMaximum.x, cellsMaximum.y));
	
	vec2 fraction = fract(uv);
	
	return mix( mix( dot( lowerLeftDirection, fraction - vec2(0, 0) ),
                     dot( lowerRightDirection, fraction - vec2(1, 0) ), blur.x),
                mix( dot( upperLeftDirection, fraction - vec2(0, 1) ),
                     dot( upperRightDirection, fraction - vec2(1, 1) ), blur.x), blur.y) * 0.8 + 0.5;
}

vec3 getColour(int id) {
    vec3 colours[3];
    
    colours[0] = vec3(50./255.,40./255.,35./255.); // Balatro black
    colours[1] = vec3(220./255.,80./255.,20./255.);
    colours[2] = vec3(240./255.,220./255.,180./255.);
    
    return colours[id];
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec2 coord = vec2((texture_coords.x-offset.b/offset.r)*offset.r,(texture_coords.y-offset.a/offset.g)*offset.g);
	vec2 dims = vec2(71.,95.);

	vec2 uv = coord/dims;
	vec4 col = Texel(texture,texture_coords);

	vec2 diff = dims * 0.5 - abs(coord - dims * 0.5);
	float dist = 1.-min(diff.x, diff.y)/10./(amp*0.2)+amp*0.3;
    
    float noise = seamless_noise(uv*dims/300.,vec2(40.,0.));
    
    float burn = 1.-(noise-((dist+.5)/2.));
    
    burn = floor(burn*10.)/10.; // Banding effect for stylization
    
    vec3 burnc = mix(getColour(1),getColour(0),clamp(burn*1.7-.5,amp*.1,1.));
    
    col = clamp(vec4(col.xyz*mix(vec3(1.),getColour(2),amp/3.),col.a),0.,1.);
    
    col = dist>noise ? vec4(0.) : vec4(mix(col.xyz,burnc,clamp(burn*1.7,0.,1.)),col.a/*>0. ? clamp(burn*1.7,col.a,1.) : 0*/);

	return col;
}]])

local sds_hook = Sprite.draw_self
function Sprite:draw_self(overlay)
	if self.config and self.config.elle_burns and self.config.elle_burns>0 then
		local qx,qy = self.sprite:getTextureDimensions()

		if not burn_canvases[self.atlas.name] then
			burn_canvases[self.atlas.name] = love.graphics.newCanvas(qx,qy)
		end
		
		local canvas = burn_canvases[self.atlas.name]
		
		local cx,cy = canvas:getDimensions()


		local tw,th = self.RETS.get_pos_pixel[1]*self.RETS.get_pos_pixel[3], self.RETS.get_pos_pixel[2]*self.RETS.get_pos_pixel[4]
		
		local target = love.graphics.getCanvas()
		local shader = love.graphics.getShader()

		love.graphics.setShader(burn_shader)
		burn_shader:send("offset", {qx,qy,tw,th})
		burn_shader:send("seed", self.config.elle_unique_val)
		burn_shader:send("amp", self.config.elle_burns)

		love.graphics.push()
		love.graphics.origin()
		love.graphics.translate(tw,th)
		love.graphics.setCanvas(canvas)
		love.graphics.clear()

		love.graphics.draw(self.atlas.image,self.sprite,0,0)
		love.graphics.setColor(G.C.L_BLACK)
		
		love.graphics.setCanvas({target, stencil=true})
		love.graphics.setShader(shader)
		love.graphics.pop()
		
		love.graphics.setColor(1,1,1)


		local old_img = self.atlas.image

		self.atlas.image = canvas

		sds_hook(self, overlay)

		self.atlas.image = old_img
		
		return
	end
	sds_hook(self, overlay)
end