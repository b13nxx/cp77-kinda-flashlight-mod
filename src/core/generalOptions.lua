generalOptions = {
  init = function(self)
    self.defaultKeepWeaponReady = true

    self.keepWeaponReady = self.defaultKeepWeaponReady
  end,

  setKeepWeaponReady = function(self, state)
    self.keepWeaponReady = state
  end
}
