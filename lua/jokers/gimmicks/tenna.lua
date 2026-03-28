local function end_func()
	local hits = slimeutils.microgames.microgame.hits or 0
	local card = slimeutils.microgames.queue[1].t.card

	card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.win
	SMODS.calculate_effect({ message = localize("k_upgrade_ex") }, card)
	
	if hits>0 then
		for i = 1, hits, 1 do
			card.ability.extra.xmult = math.max(card.ability.extra.xmult - card.ability.extra.hit,1)
			SMODS.calculate_effect({
				message = "-X"..card.ability.extra.hit,
				colour = G.C.RED,
				sound = "elle_utdr_hurt"
			}, card)
		end
	end
end

local tenna = SMODS.Joker {
	key = 'tenna',
	config = { extra = { xmult = 1, win = 0.4, hit = 0.2, microgame = "rhythm" } },
	loc_vars = function(self, info_queue, card)
		--[[local mg = microgames[card.ability.extra.microgame]
		info_queue[#info_queue+1] = {set="Other",key="ellemicrogame_"..card.ability.extra.microgame,specific_vars = (mg and mg.loc_vars and mg:loc_vars() or {})}]]
		return { vars = { card.ability.extra.win, card.ability.extra.hit, card.ability.extra.xmult, 
		localize({type = 'name_text', key = "ellemicrogame_"..card.ability.extra.microgame, set = 'Other'}) } }
	end,
	rarity = 3,
	atlas = 'jokers',
	blueprint_compat = true,
	pos = { x = 6, y = 3 },
	cost = 10
}
tenna.set_ability = function(self, card, initial, delay_sprites)
	card.ability.extra.microgame = pseudorandom_element(ellejokers.tvtime.microgame_list, "elle_tenna_microgame")
end

tenna.calculate = function(self, card, context)
	if (context.elle_on_play_press and not context.blueprint) then
		slimeutils.microgames.enqueue(ellejokers.tvtime.pre_play_queue, ellejokers.tvtime.microgames[card.ability.extra.microgame],{juice = card, end_func = end_func})
	end

	if (context.after and not context.blueprint) then
		card.ability.extra.microgame = pseudorandom_element(ellejokers.tvtime.microgame_list, "elle_tenna_microgame")
	end

	if context.joker_main then
		return { xmult = card.ability.extra.xmult }
	end
end

tenna.generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
	SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)

	local s = G.TILESCALE*G.TILESIZE
	local tvtime_sprite = SMODS.create_sprite(0,0,505/s*.5,141/s*.5, "elle_tenna_its_tv_time", {x=0,y=0})
	local pc_sprite = SMODS.create_sprite(0,0,391/s*.75,69/s*.75, "elle_tenna_physical_challenge", {x=0,y=0})

	local tvtime = {
		n = G.UIT.R,
		config = { align = 'cm', padding = -0.1, no_fill = true },
		nodes = {
			{
				n = G.UIT.O,
				config = { align = 'cm', object = tvtime_sprite }
			}
		}
	}
	local pc = {
		{
			n = G.UIT.O,
			config = { align = 'cm', object = pc_sprite }
		}
	}

	full_UI_table.name[1].nodes[1].nodes[1].config.object:remove()
	full_UI_table.name[1].nodes[1] = tvtime
	full_UI_table.main[2] = pc
end