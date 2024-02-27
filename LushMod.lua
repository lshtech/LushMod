--- STEAMODDED HEADER
--- MOD_NAME: LushMod
--- MOD_ID: LushMod
--- MOD_AUTHOR: [lusciousdev]
--- MOD_DESCRIPTION: Various new Jokers

----------------------------------------------
------------MOD CODE -------------------------

function table_length(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function SMODS.INIT.LushMod()
  local lushJokers = {
    j_jokester = {
      order = 0,
      unlocked = true,
      discovered = false,
      blueprint_compat = true,
      eternal_compat = true,
      rarity = 1,
      cost = 4,
      name = "The Jokester",
      set = "Joker",
      config = { extra = 0.2, Xmult = 1 },
      pos = { x = 0, y = 16 },
    },
  }

  -- Add Jokers to center
  for k, v in pairs(lushJokers) do
      v.key = k
      v.order = table_length(G.P_CENTER_POOLS['Joker']) + 1
      G.P_CENTERS[k] = v
      table.insert(G.P_CENTER_POOLS['Joker'], v)
  end

  table.sort(G.P_CENTER_POOLS["Joker"], function (a, b) return a.order < b.order end)

  -- Localization
  local jokerLocalization = {
      j_jokester = {
          name = "The Jokester",
          text = {
            "{X:mult,C:white} X#1# {} Mult per",
            "Joker added to deck.",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
          }
      },
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
                  for _, line in ipairs(type(center.name) == 'table' and center.name or { center.name }) do
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
    set_abilityref(self, center, initial, delay_sprites)

    if self.ability.name == "The Jokester" then
        if self.area == G.joker then self.base_cost = 4 end
        self.sell_cost = 2
        --if G.GAME.used_rkey then sendDebugMessage("r key used") end
    end
end

local calculate_jokerref = Card.calculate_joker
function Card.calculate_joker(self, context)
    local calc_ref = calculate_jokerref(self, context)

    if self.ability.set == "Joker" and not self.debuff then
        if context.adding_to_deck then
            if self.ability.name == "The Jokester" and not context.blueprint then
                self.ability.x_mult = self.ability.x_mult + self.ability.extra
            end
        end
    end

    return calc_ref
end

local add_to_deckref = Card.add_to_deck
function Card.add_to_deck(self, from_debuff)
  local calc_ref = add_to_deckref(self, from_debuff)

  for i = 1, #G.jokers.cards do
    G.jokers.cards[i]:calculate_joker({adding_to_deck = true})
  end

  return calc_ref
end

local generate_UIBox_ability_tableref = Card.generate_UIBox_ability_table
function Card.generate_UIBox_ability_table(self)
  local card_type, hide_desc = self.ability.set or "None", nil
  local loc_vars = nil
  local main_start, main_end = nil,nil
  local no_badge = nil

  if self.config.center.unlocked == false and not self.bypass_lock then --For everyting that is locked
  elseif card_type == 'Undiscovered' and not self.bypass_discovery_ui then -- Any Joker or tarot/planet/voucher that is not yet discovered
  elseif self.debuff then
  elseif card_type == 'Default' or card_type == 'Enhanced' then
  elseif self.ability.set == 'Joker' then 
    if self.ability.name == 'The Jokester' then 
      loc_vars = {self.ability.extra, self.ability.x_mult}

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
      if self.seal then badges[#badges + 1] = string.lower(self.seal)..'_seal' end
      if self.ability.eternal then badges[#badges + 1] = 'eternal' end
      if self.pinned then badges[#badges + 1] = 'pinned_left' end
  
      if self.sticker then loc_vars = loc_vars or {}; loc_vars.sticker=self.sticker end

      return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
    end
  end

  return generate_UIBox_ability_tableref(self)
end
----------------------------------------------
------------MOD CODE END----------------------