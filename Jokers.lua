--- STEAMODDED HEADER
--- MOD_NAME: LushMod 2
--- MOD_ID: LushMod2
--- PREFIX: lush
--- MOD_AUTHOR: [lusciousdev, elbe]
--- MOD_DESCRIPTION: Various new Jokers
--- BADGE_COLOUR: a81e91
--- VERSION: 0.0.1
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas{
	key = "LushJokers",
	path = "Jokers_LushMod.png",
	px = 71,
	py = 95,
}

local j_jokester = SMODS.Joker{
	name = "j_jokester",
	key = "jokester",
	config = { extra = { mult_mod = 0.2, jokers = 0 }, Xmult = 1 },
	pos = { x = 0, y = 0 },
	loc_txt = {
		name = "The Jokester",
		text = {"{X:mult,C:white} X#1# {} Mult per", "Joker added.",
                    "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"}
	},
	rarity = 3,
	cost = 8,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult_mod, center.ability.x_mult } }
	end,
	calculate = function(self, card, context)
        local num_jokers = #G.jokers.cards
        local diff = 0
        if num_jokers > card.ability.extra.jokers then
            diff = num_jokers - card.ability.extra.jokers
        end
        if diff ~= 0 then
            card.ability.x_mult = card.ability.x_mult + (card.ability.extra.mult_mod * diff)
        end
        card.ability.extra.jokers = num_jokers
	end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.jokers = #G.jokers.cards + 1
    end
}
local j_brethren = SMODS.Joker{
	name = "j_brethren",
	key = "brethren",
	config = { extra = 2 },
	pos = { x = 1, y = 0 },
	loc_txt = {
		name = "The Brethren",
        text = { "{C:green}#1# in #2#{} chance to", "convert the pair in a", 
                 "{C:attention}Full House{} to the rank", "of the other 3 cards" }
	},
	rarity = 3,
	cost = 8,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { G.GAME.probabilities.normal, center.ability.extra } }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
            if next(context.poker_hands["Full House"]) then
                if pseudorandom('breth'..G.GAME.round_resets.ante) < G.GAME.probabilities.normal / card.ability.extra then
                  local rank1 = nil
                  local rank1_count = nil
                  local rank2 = nil
                  local rank2_count = nil

                  for i = 1, #context.scoring_hand do
                    if rank1 == context.scoring_hand[i]:get_id() then
                      rank1_count = rank1_count + 1
                    elseif rank2 == context.scoring_hand[i]:get_id() then
                      rank2_count = rank2_count + 1
                    elseif rank1 == nil then
                      rank1 = context.scoring_hand[i]:get_id()
                      rank1_count = 1
                    elseif rank2 == nil then
                      rank2 = context.scoring_hand[i]:get_id()
                      rank2_count = 1
                    end
                  end
                  
                  local pair_rank = nil
                  local three_rank = nil
                  if rank1_count == 2 then
                    pair_rank = rank1
                    three_rank = rank2
                  elseif rank2_count == 2 then
                    pair_rank = rank2
                    three_rank = rank1
                  end

                  local cdelay = 0.5
                  for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:get_id() == pair_rank then
                      G.E_MANAGER:add_event(Event({trigger = 'after', delay = cdelay, func = function()
                        local card = context.scoring_hand[i]
                        local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                        local rank_suffix = three_rank
                        if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                        elseif rank_suffix == 10 then rank_suffix = 'T'
                        elseif rank_suffix == 11 then rank_suffix = 'J'
                        elseif rank_suffix == 12 then rank_suffix = 'Q'
                        elseif rank_suffix == 13 then rank_suffix = 'K'
                        elseif rank_suffix == 14 then rank_suffix = 'A'
                        end
                        card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                      return true end}))
                      cdelay = 0.1
                    end
                  end

                  return {
                      message = "Converted!",
                      colour = G.C.RED,
                      card = self
                  }
                end
            end
        end
	end,
}
local j_trickster = SMODS.Joker{
	name = "j_trickster",
	key = "trickster",
	config = { extra = {} },
	pos = { x = 2, y = 0 },
	loc_txt = {
		name = "The Trickster",
		text = { "When {C:attention}Blind{} is selected,", "reroll the Joker to the", "right into a new Joker", "of the same rarity" }
	},
	rarity = 3,
	cost = 8,
    unlocked = true,
    discovered = false,
	blueprint_compat = false,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { } }
	end,
	calculate = function(self, card, context)
		if context.setting_blind and not card.getting_sliced and not card.gettin_rerolled and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
              if G.jokers.cards[i] == card then my_pos = i; break end
            end

            if my_pos and G.jokers.cards[my_pos + 1] and not card.getting_sliced and not G.jokers.cards[my_pos + 1].ability.eternal and not G.jokers.cards[my_pos + 1].getting_rerolled then
              local rerolled_card = G.jokers.cards[my_pos + 1]
              rerolled_card.getting_rerolled = true

              local rerolled_card_rarity = 0
              if rerolled_card.config.center.rarity == 2 then
                rerolled_card_rarity = 0.9
              elseif rerolled_card.config.center.rarity == 3 then
                rerolled_card_rarity = 1
              end

              G.GAME.joker_buffer = G.GAME.joker_buffer - 1

              G.E_MANAGER:add_event(Event({
                func = function()
                G.GAME.joker_buffer = 0
                card:juice_up(0.8, 0.8)
                rerolled_card:start_dissolve({HEX("57ecab")}, nil, 1.6)
                local new_card = create_card('Joker', G.jokers, nil, rerolled_card_rarity, nil, nil, nil, 'trc')
                new_card:add_to_deck()
                G.jokers:emplace(new_card)
                new_card:start_materialize()
                G.GAME.joker_buffer = 0
                return true
              end}))
              card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Rerolled!", colour = G.C.PURPLE})
            end
        end
	end,
}
local j_top5 = SMODS.Joker{
	name = "j_top5",
	key = "top5",
	config = { extra = { chips = 4, chip_mod = 2 } },
	pos = { x = 3, y = 0 },
	loc_txt = {
		name = "Top 5",
        text = {"Doubles Chips if first", "played hand is a {C:attention}Straight{}",
                "containing an {C:attention}Ace{} and a {C:attention}5{} ",
                "{C:inactive}(Currently {C:chips}#1#{C:inactive} Chips)"}
	},
	rarity = 2,
	cost = 6,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips } }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
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
                card.ability.extra.chips = card.ability.extra.chip_mod * card.ability.extra.chips

                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
	end,
}
local j_buffer = SMODS.Joker{
	name = "j_buffer",
	key = "buffer",
	config = { extra = { mult = 15 } },
	pos = { x = 4, y = 0 },
	loc_txt = {
		name = "The Buffer",
        text = {"{C:mult}+#1#{} Mult if", "played hand", "contains a {C:attention}5{}"}
	},
	rarity = 1,
	cost = 4,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
            local fives = 0
            for i = 1, #context.full_hand do
                if context.full_hand[i]:get_id() == 5 then
                    fives = fives + 1
                end
            end
            if fives >= 1 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                    mult_mod = card.ability.extra.mult
                }
            end
        end
	end,
}
local j_amazin = SMODS.Joker{
	name = "j_amazin",
	key = "amazin",
	config = { extra = { chips = 25 } },
	pos = { x = 5, y = 0 },
	loc_txt = {
		name = "Amazin' Joker",
        text = { "Each {C:attention}Ace{}", "held in hand", "gives {C:chips}+#1#{} Chips" }
	},
	rarity = 1,
	cost = 4,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.hand and context.other_card:get_id() == 14 then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED,
                    card = card,
                }
            else
                return {
                    h_chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
	end,
}
local j_hue = SMODS.Joker{
	name = "j_hue",
	key = "hue",
	config = { extra = 3 },
	pos = { x = 6, y = 0 },
	loc_txt = {
		name = "Hue Graph",
        text = { "If {C:attention}first discard{} of round is", "a flush, {C:green}#1# in #2#{} chance", " to destroy each discarded card."}
	},
	rarity = 2,
	cost = 6,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { G.GAME.probabilities.normal, center.ability.extra } }
	end,
	calculate = function(self, card, context)
		if context.discard and not context.blueprint and not context.hook and G.GAME.current_round.discards_used <= 0 then
            local text,disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            if text == "Flush" then
                if pseudorandom('hue'..G.GAME.round_resets.ante) < G.GAME.probabilities.normal / card.ability.extra then
                    return {
                        message = "Hewn!",
                        colour = G.C.RED,
                        delay = 0.45, 
                        remove = true,
                        card = card
                    }
                end
            end
        end
	end,
}
local j_wizard = SMODS.Joker{
	name = "j_wizard",
	key = "wizard",
	config = { extra = 1 },
	pos = { x = 7, y = 0 },
	loc_txt = {
		name = "Cloud Wizard",
        text = { "Earn {C:money}$1{} for each", "{C:purple}Tarot{} card used." }
	},
	rarity = 2,
	cost = 6,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra } }
	end,
	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable.ability.set == "Tarot" then
            ease_dollars(card.ability.extra)
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra
            G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
            return {
                message = localize('$')..card.ability.extra,
                dollars = card.ability.extra,
                colour = G.C.MONEY
            }
        end
	end,
}
local j_timely = SMODS.Joker{
	name = "j_timely",
	key = "timely",
	config = { extra = { mult = 12 } },
	pos = { x = 8, y = 0 },
	loc_txt = {
		name = "Timely Lion",
        text = { "{C:mult}+#1#{} Mult on {C:attention}first{}", "and {C:attention}final{} hand", "of round." }
	},
	rarity = 2,
	cost = 6,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers then
            if G.GAME.current_round.hands_left == 0 and G.GAME.current_round.hands_played == 0 then
                local temp_mult = 2 * card.ability.extra.mult
                return {
                    message = localize{type='variable',key='a_mult',vars={temp_mult}},
                    mult_mod = temp_mult,
                }
            elseif G.GAME.current_round.hands_left == 0 or G.GAME.current_round.hands_played == 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
                    mult_mod = card.ability.extra.mult,
                }
            end
        end
	end,
}
local j_seven = SMODS.Joker{
	name = "j_seven",
	key = "seven",
	config = { extra = 3 },
	pos = { x = 9, y = 0 },
	loc_txt = {
		name = "Seven Seven Seven",
        text = {
            "Create a {C:attention}random 7{}",
            "if played hand contains",
            "{C:attention}#1#{} or more {C:attention}7s{}",
        }
	},
	rarity = 1,
	cost = 4,
    unlocked = true,
    discovered = false,
	blueprint_compat = true,
	perishable_compat = trigger_colour_end_of_round,
	atlas = "LushJokers",
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra } }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before then
            local sevens = 0
            for i = 1, #context.scoring_hand do
            if context.scoring_hand[i]:get_id() == 7 then
                sevens = sevens + 1
            end
            end
            if sevens >= 3 then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.7,
                func = function()
                local card = nil
                local newcards = {}
                local _rank = '7'
                local _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('777_create'))
                local cen_pool = {}
                local enhanced_poll = pseudorandom(pseudoseed('777enh'..G.GAME.round_resets.ante))
                if enhanced_poll > 0.7 then
                    for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                        if v.key ~= 'm_stone' then 
                            cen_pool[#cen_pool+1] = v
                        end
                    end
                    card = create_playing_card({front = G.P_CARDS[_suit..'_'.._rank], center = pseudorandom_element(cen_pool, pseudoseed('777_card'))}, G.hand, nil, false, {G.C.SECONDARY_SET.Spectral})
                else
                    card = create_playing_card({front = G.P_CARDS[_suit..'_'.._rank], center = G.P_CENTERS.c_base}, G.hand, nil, false, {G.C.SECONDARY_SET.Spectral})
                end
                local edition_rate = 2
                local edition = poll_edition('777_edition'..G.GAME.round_resets.ante, edition_rate, true)
                card:set_edition(edition)
                local seal_rate = 10
                local seal_poll = pseudorandom(pseudoseed('777seal'..G.GAME.round_resets.ante))
                if seal_poll > 1 - 0.02*seal_rate then
                    local seal_type = pseudorandom(pseudoseed('777sealtype'..G.GAME.round_resets.ante))
                    if seal_type > 0.75 then card:set_seal('Red')
                    elseif seal_type > 0.5 then card:set_seal('Blue')
                    elseif seal_type > 0.25 then card:set_seal('Gold')
                    else card:set_seal('Purple')
                    end
                end
                newcards[1] = card
                playing_card_joker_effects(newcards)
                return true
                end}))
            end
        end
	end,
}

local jokers =  {
	j_jokester,
    j_brethren,
    j_trickster,
    j_top5,
    j_buffer,
    j_amazin,
    j_hue,
    j_wizard,
    j_timely,
    j_seven
}

if JokerDisplay then
    local jd_def = JokerDisplay.Definitions

    jd_def["j_lush_jokester"] = { -- Jokester
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    }

    jd_def["j_lush_top5"] = { -- Top 5
        text = {
            { text = "+" },
            { ref_table = "card.ability.extra", ref_value = "chips" }
        },
        text_config = { colour = G.C.CHIPS },
    }

    jd_def["j_lush_buffer"] = { -- Buffer
        text = {
            { text = "+" },
            { ref_table = "card.joker_display_values", ref_value = "mult" }
        },
        text_config = { colour = G.C.MULT },
        calc_function = function(card)
            local mult = 0
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:get_id() == 5 then
                        mult = 
                            card.ability.extra.mult *
                            JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                    end
                end
            end
            card.joker_display_values.mult = mult
        end
    }

    jd_def["j_lush_amazin"] = { -- Amazin
        text = {
            { text = "+" },
            { ref_table = "card.joker_display_values", ref_value = "chips" }
        },
        text_config = { colour = G.C.CHIPS },
        calc_function = function(card)
            local chips = 0
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' then
                for _, held_card in pairs(G.hand.cards) do
                    if held_card:get_id() == 14 and not held_card.debuff then
                        chips = chips + card.ability.extra.chips
                    end
                end
            end
            card.joker_display_values.chips = chips
        end
    }

    jd_def["j_lush_timely"] = { -- Timely
        text = {
            { text = "+" },
            { ref_table = "card.joker_display_values", ref_value = "mult" }
        },
        text_config = { colour = G.C.MULT },
        calc_function = function(card)
            local mult = 0
            if G.GAME.current_round.hands_left == 1 and G.GAME.current_round.hands_played == 0 then
                mult = card.ability.extra.mult * 2
            elseif G.GAME.current_round.hands_left == 1 or G.GAME.current_round.hands_played == 0 then
                mult = card.ability.extra.mult
            end
            card.joker_display_values.mult = mult
        end
    }
end

----------------------------------------------
------------MOD CODE END----------------------
