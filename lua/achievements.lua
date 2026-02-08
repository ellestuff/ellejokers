SMODS.Achievement {
    key="soretro",
    bypass_all_unlocked = true,
    unlock_condition = function (self, args)
        if args and (args.type == "elle_toggle_palette") then
            return true
        end
    end
}