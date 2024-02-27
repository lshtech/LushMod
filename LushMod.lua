--- STEAMODDED HEADER
--- MOD_NAME: LushMod
--- MOD_ID: LushMod
--- MOD_AUTHOR: [lusciousdev]
--- MOD_DESCRIPTION: Various new Jokers
----------------------------------------------
------------MOD CODE -------------------------
function table_length(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function SMODS.INIT.LushMod()
    local lushJokers = {
        j_jokester = {
            order = 0,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true,
            rarity = 3,
            cost = 8,
            name = "The Jokester",
            set = "Joker",
            config = {
                extra = 0.2,
                Xmult = 1
            },
            pos = {
                x = 0,
                y = 16
            }
        },
        j_top5 = {
            order = 0,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true,
            rarity = 2,
            cost = 6,
            name = "Top 5",
            set = "Joker",
            config = {
                extra = {
                    chips = 4,
                    chip_mod = 2
                }
            },
            pos = {
                x = 1,
                y = 16
            }
        },
        j_buffer = {
            order = 0,
            unlocked = true,
            discovered = true,
            blueprint_compat = true,
            eternal_compat = true,
            rarity = 1,
            cost = 5,
            name = "The Buffer",
            set = "Joker",
            config = {
                extra = {
                    mult = 15
                }
            },
            pos = {
                x = 2,
                y = 16
            }
        }
    }

    -- Add Jokers to center
    for k, v in pairs(lushJokers) do
        v.key = k
        v.order = table_length(G.P_CENTER_POOLS['Joker']) + 1
        G.P_CENTERS[k] = v
        table.insert(G.P_CENTER_POOLS['Joker'], v)
        if v.rarity and v.set == 'Joker' and not v.demo then
            table.insert(G.P_JOKER_RARITY_POOLS[v.rarity], v)
        end
    end

    table.sort(G.P_CENTER_POOLS["Joker"], function(a, b)
        return a.order < b.order
    end)

    -- Localization
    local jokerLocalization = {
        j_jokester = {
            name = "The Jokester",
            text = {"{X:mult,C:white} X#1# {} Mult per", "Joker added.",
                    "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"}
        },
        j_top5 = {
            name = "Top 5",
            text = {"Doubles Chips if first", "played hand is a {C:attention}Straight{}",
                    "containing an {C:attention}Ace{} and a {C:attention}5{} ",
                    "{C:inactive}(Currently {C:chips}#1#{} Chips)"}
        },
        j_buffer = {
            name = "The Buffer",
            text = {"{C:mult}+#1#{} Mult if played", "hand contains", "a {C:attention}5{}"}
        }
    }
    for k, v in pairs(jokerLocalization) do
        G.localization.descriptions.Joker[k] = v
    end

    -- Update localization
    for g_k, group in pairs(G.localization) do
        if g_k == 'descriptions' then
            for _, set in pairs(group) do
                for _, center in pairs(set) do
                    center.text_parsed = {}
                    for _, line in ipairs(center.text) do
                        center.text_parsed[#center.text_parsed + 1] = loc_parse_string(line)
                    end
                    center.name_parsed = {}
                    for _, line in ipairs(type(center.name) == 'table' and center.name or {center.name}) do
                        center.name_parsed[#center.name_parsed + 1] = loc_parse_string(line)
                    end
                    if center.unlock then
                        center.unlock_parsed = {}
                        for _, line in ipairs(center.unlock) do
                            center.unlock_parsed[#center.unlock_parsed + 1] = loc_parse_string(line)
                        end
                    end
                end
            end
        end
    end

    -- Add sprites
    local lushmod = SMODS.findModByID("LushMod")
    local sprite_lushmod = SMODS.Sprite:new("Joker", lushmod.path, "Jokers_LushMod.png", 71, 95, "asset_atli")

    sprite_lushmod:register()
end

-- Joker abilities
local set_abilityref = Card.set_ability
function Card.set_ability(self, center, initial, delay_sprites)
    return set_abilityref(self, center, initial, delay_sprites)
end

local calculate_jokerref = Card.calculate_joker
function Card.calculate_joker(self, context)
    local calc_ref = calculate_jokerref(self, context)

    if self.ability.set == "Joker" and not self.debuff then
        if self.ability.name == "Blueprint" then
            local other_joker = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == self then
                    other_joker = G.jokers.cards[i + 1]
                end
            end
            if other_joker and other_joker ~= self then
                context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                context.blueprint_card = context.blueprint_card or self
                if context.blueprint > #G.jokers.cards + 1 then
                    return
                end
                local other_joker_ret = other_joker:calculate_joker(context)
                if other_joker_ret then
                    other_joker_ret.card = context.blueprint_card or self
                    other_joker_ret.colour = G.C.BLUE
                    return other_joker_ret
                end
            end
        end
        if self.ability.name == "Brainstorm" then
            local other_joker = G.jokers.cards[1]
            if other_joker and other_joker ~= self then
                context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                context.blueprint_card = context.blueprint_card or self
                if context.blueprint > #G.jokers.cards + 1 then
                    return
                end
                local other_joker_ret = other_joker:calculate_joker(context)
                if other_joker_ret then
                    other_joker_ret.card = context.blueprint_card or self
                    other_joker_ret.colour = G.C.RED
                    return other_joker_ret
                end
            end
        end
        
        if context.open_booster then
        elseif context.buying_card then
        elseif context.selling_self then
        elseif context.selling_card then
        elseif context.reroll_shop then
        elseif context.ending_shop then
        elseif context.skip_blind then
        elseif context.skipping_booster then
        elseif context.playing_card_added and not self.getting_sliced then
        elseif context.first_hand_drawn then
        elseif context.setting_blind and not self.getting_sliced then
        elseif context.destroying_card then
        elseif context.cards_destroyed then
        elseif context.remove_playing_cards then
        elseif context.using_consumeable then
        elseif context.debuffed_hand then 
        elseif context.pre_discard then
        elseif context.discard then
        elseif context.end_of_round then
        elseif context.repetition then
        elseif context.other_joker then
        elseif context.adding_to_deck then
            if self.ability.name == "The Jokester" and not context.blueprint then
                if context.adding_to_deck_set == "Joker" then
                    self.ability.x_mult = self.ability.x_mult + self.ability.extra
                end
            end
        elseif context.individual then
        else
            if context.cardarea == G.jokers then
                if context.before then
                    if self.ability.name == "Top 5" and G.GAME.current_round.hands_played == 0 and not context.blueprint then
                        local aces = 0
                        local fives = 0
                        for i = 1, #context.scoring_hand do
                            if context.scoring_hand[i]:get_id() == 14 then
                                aces = aces + 1
                            end
                            if context.scoring_hand[i]:get_id() == 5 then
                                fives = fives + 1
                            end
                        end
                        if aces >= 1 and fives >= 1 and next(context.poker_hands["Straight"]) then
                            self.ability.extra.chips = self.ability.extra.chip_mod * self.ability.extra.chips

                            return {
                                message = localize('k_upgrade_ex'),
                                colour = G.C.CHIPS,
                                card = self
                            }
                        end
                    end
                elseif context.after then

                else
                    if context.cardarea == G.jokers then
                        if self.ability.name == 'Top 5' then
                            return {
                                message = localize {
                                    type = 'variable',
                                    key = 'a_chips',
                                    vars = {self.ability.extra.chips}
                                },
                                chip_mod = self.ability.extra.chips,
                                colour = G.C.CHIPS
                            }
                        elseif self.ability.name == 'The Buffer' then
                            local fives = 0
                            for i = 1, #context.full_hand do
                                if context.full_hand[i]:get_id() == 5 then
                                    fives = fives + 1
                                end
                            end
                            if fives >= 1 then
                                return {
                                    message = localize{type='variable',key='a_mult',vars={self.ability.extra.mult}},
                                    mult_mod = self.ability.extra.mult
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    return calc_ref
end

local add_to_deckref = Card.add_to_deck
function Card.add_to_deck(self, from_debuff)
    local calc_ref = add_to_deckref(self, from_debuff)

    for i = 1, #G.jokers.cards do
        G.jokers.cards[i]:calculate_joker({
            adding_to_deck = true,
            adding_to_deck_set = self.ability.set
        })
    end

    return calc_ref
end

local generate_UIBox_ability_tableref = Card.generate_UIBox_ability_table
function Card.generate_UIBox_ability_table(self)
    local card_type, hide_desc = self.ability.set or "None", nil
    local loc_vars = nil
    local main_start, main_end = nil, nil
    local no_badge = nil

    if self.config.center.unlocked == false and not self.bypass_lock then -- For everyting that is locked
    elseif card_type == 'Undiscovered' and not self.bypass_discovery_ui then -- Any Joker or tarot/planet/voucher that is not yet discovered
    elseif self.debuff then
    elseif card_type == 'Default' or card_type == 'Enhanced' then
    elseif self.ability.set == 'Joker' then
        local customJoker = false

        if self.ability.name == 'The Jokester' then
            loc_vars = {self.ability.extra, self.ability.x_mult}
            customJoker = true
        elseif self.ability.name == 'Top 5' then
            loc_vars = {self.ability.extra.chips}
            customJoker = true
        elseif self.ability.name == 'The Buffer' then
            loc_vars = {self.ability.extra.mult}
            customJoker = true
        end

        if customJoker then
            local badges = {}
            if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
                badges.card_type = card_type
            end
            if self.ability.set == 'Joker' and self.bypass_discovery_ui and (not no_badge) then
                badges.force_rarity = true
            end
            if self.edition then
                if self.edition.type == 'negative' and self.ability.consumeable then
                    badges[#badges + 1] = 'negative_consumable'
                else
                    badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
                end
            end
            if self.seal then
                badges[#badges + 1] = string.lower(self.seal) .. '_seal'
            end
            if self.ability.eternal then
                badges[#badges + 1] = 'eternal'
            end
            if self.pinned then
                badges[#badges + 1] = 'pinned_left'
            end

            if self.sticker then
                loc_vars = loc_vars or {};
                loc_vars.sticker = self.sticker
            end

            return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start,
                main_end)
        end
    end

    return generate_UIBox_ability_tableref(self)
end
----------------------------------------------
------------MOD CODE END----------------------
