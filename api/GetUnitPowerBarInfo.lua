return {
  name = 'GetUnitPowerBarInfo',
  status = 'stub',
  inputs = 's',
  outputs = 't',
  impl = function()
    local tbl = {
      id = 1,
      barType = 2,
      minPower = 0,
      startInset = 0,
      endInset = 0,
      smooth = true,
      hideFromOthers = true,
      showOnRaid = true,
      opaqueSpark = true,
      opaqueFlash = true,
      anchorTop = true,
      forcePercentage = true,
      sparkUnderFrame = true,
      flashAtMinPower = true,
      fractionalCounter = true,
      animateNumbers = true,
    }
    return tbl
  end,
}
