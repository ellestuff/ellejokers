SMODS.Challenge {
	key = "cafe_frequent",
	jokers = {{
			id = "j_elle_rebecca",
			eternal=true
	}},
	rules = {
		custom = {
			{id = "elle_no_shop"},
		}
	},
	restrictions = {
		banned_tags = {
			{id="tag_uncommon"},
			{id="tag_rare"},
			{id="tag_negative"},
			{id="tag_foil"},
			{id="tag_holo"},
			{id="tag_polychrome"},
			{id="tag_voucher"},
			{id="tag_coupon"},
			{id="tag_d_six"},
		},
		banned_cards = Cryptid and {{id="c_cry_run"}} or nil
	}
}

SMODS.Challenge {
	key = "forcefem",
	rules = {
		custom = {
			{id = "elle_not_all", value = "Queen"},
			{id = "elle_untested"}
		}
	},
	jokers = {
		{
			id = "j_elle_suggestion",
			eternal=true
		},
		{
			id = "j_pareidolia",
			eternal=true
		}
	},
	restrictions = {
		banned_other = {
			{id="bl_plant",type="blind"}
		}
	}
}

local shopless = SMODS.Challenge {
	key = "shopless",
	rules = {
		custom = {
			{id = "elle_no_shop"},
			{id = "elle_untested"}
		}
	},
	restrictions = {
		banned_tags = {
			{id="tag_uncommon"},
			{id="tag_rare"},
			{id="tag_negative"},
			{id="tag_foil"},
			{id="tag_holo"},
			{id="tag_polychrome"},
			{id="tag_voucher"},
			{id="tag_coupon"},
			{id="tag_d_six"},
		},
		banned_cards = {
			{id="j_elle_rebecca"}
		}
	}
}
if Cryptid then shopless.restrictions.banned_cards[#shopless.restrictions.banned_cards+1] = {id="c_cry_run"} end

SMODS.Challenge {
	key = "unlockable",
	rules = {
		custom = {
			{id = "elle_untested"}
		}
	},
	jokers = {
		{
			id = "j_elle_diamond_pickaxe",
			eternal=true,
			edition="negative"
		},
		{ id = "j_egg", eternal=true },
		{ id = "j_egg", eternal=true },
		{ id = "j_egg", eternal=true },
		{ id = "j_egg", eternal=true },
		{ id = "j_egg", eternal=true }
	}
}

function elle_challenge_mod_calc(self,context)
	if G.GAME.modifiers.elle_not_all and context.modify_hand then
		local all_rank = true
		for _,v in ipairs(context.scoring_hand) do
			all_rank = all_rank and (v.base.value == G.GAME.modifiers.elle_not_all)
		end
		if all_rank then
			-- Copied from VanillaRemade wiki
			G.STATE = G.STATES.GAME_OVER
			if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then
				G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
			end
			G:save_settings()
			G.FILE_HANDLER.force = true
			G.STATE_COMPLETE = false
		end
	end
end