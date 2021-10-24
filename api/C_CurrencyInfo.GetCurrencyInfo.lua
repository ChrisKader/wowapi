return {
  name = 'C_CurrencyInfo.GetCurrencyInfo',
  status = 'stub',
  inputs = {'','n'},
  outputs = 't',
  impl = function()
    local tbl = {
      name = "Test",
      isHeader = true,
      isHeaderExpanded = true,
      isTypeUnused = true,
      isShowInBackpack = true,
      quantity = 9999,
      iconFileID = 136235,
      maxQuantity = 9999999,
      canEarnPerWeek = true,
      quantityEarnedThisWeek = 1,
      isTradeable = false,
      quality = 6,
      maxWeeklyQuantity = 6,
      totalEarned = 99999,
      discovered = true,
      useTotalEarnedForMaxQty = false
    }
    return tbl
  end,
}
