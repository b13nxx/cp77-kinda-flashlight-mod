player = {
  checkIfSessionStarted = function (self)
    return Game.GetPlayer() and Game.GetPlayer():IsAttached() and not Game.GetSystemRequestsHandler():IsPreGame()
  end,

  checkIfActivelyPlaying = function (self)
    local timeSystem = Game.GetTimeSystem()

    return self.checkIfSessionStarted() and not (Game.GetSystemRequestsHandler():IsGamePaused() or (timeSystem:IsTimeDilationActive() and timeSystem:GetActiveTimeDilation() < 0.05))
  end,

  checkIfInsideVehicle = function (self)
    return Game.GetPlayer():GetMountedVehicle() ~= nil
  end,

  getActiveWeapon = function (self)
    return Game.GetActiveWeapon(Game.GetPlayer())
  end
}
