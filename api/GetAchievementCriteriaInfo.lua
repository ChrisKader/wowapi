return {
  name = 'GetAchievementCriteriaInfo',
  status = 'stub',
  inputs = {'ss','nn','ns','sn'},
  outputs = 'snbnnsnnsnbnn',
  impl = function(s)
    local criteriaString = "0"
    local criteriaType = 0
    local completed = false
    local quantity = 4
    local reqQuantity = 5
    local charName = "Test"
    local flags = 0
    local assetID = 0
    local quantityString = "5"
    local criteriaID = 109
    local eligible = true
    local duration = 30
    local elapsed = 5
    return criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed
  end,
}
