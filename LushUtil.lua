--- STEAMODDED HEADER
--- MOD_NAME: LushUtil
--- MOD_ID: LushUtil
--- MOD_AUTHOR: [lusciousdev]
--- MOD_DESCRIPTION: Utility mod to facilitate adding Jokers.
----------------------------------------------
------------MOD CODE -------------------------

function sortByOrder(t, arg1, arg2)
  if t[arg2].order == nil then return true
  elseif t[arg1].order == nil then return false
  else
    if t[arg1].order < t[arg2].order then return true
    elseif t[arg1].order == t[arg2].order then return true
    elseif t[arg1].order > t[arg2].order then return false
    end
  end
end

function pairsByOrder(t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, function(a, b) return sortByOrder(t, a, b) end)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

----------------------------------------------
------------MOD CODE END----------------------