require 'src/core/debug'
require 'src/core/enums'
require 'src/core/color'
require 'src/core/vector'
require 'src/core/player'

require 'src/flashlight'
require 'src/settings'

public = {
  isReady = false,
  title = 'KRF',
  version = '3.0'
}

private = {
  passedTime = 0
}

registerForEvent('onInit', function()
  public.isReady = true

  settings:init(public.title, public.version)
  settings:load()
  settings:draw()

  flashlight:init()

  ObserveAfter('PlayerPuppet', 'OnWeaponEquipEvent', function(self)
    flashlight.drawnWeapon = player:getActivePlayerWeapon()

    if not flashlight.drawnWeapon:IsMelee() then
      flashlight:turnOn()
    elseif flashlight.drawnWeapon:IsMelee() then
      flashlight:turnOff()
    end
  end)

  Observe('PlayerPuppet', 'OnItemUnequipped', function(self)
    flashlight:turnOff()
  end)

  Observe('UpperBodyTransition', 'SetWeaponHolster', function (self, _scriptInterface, isHolstered)
    if isHolstered == true then
      flashlight:turnOff()
    end
  end)

  ObserveBefore('PlayerPuppet', 'OnVehicleStateChange', function(self, newState)
    if newState ~= EnumInt(gamePSMVehicle.Default) and flashlight.entityStatus == FlashlightStatus.SPAWNED then
      flashlight:despawn()
    end
  end)

  print('KRF is initialized!')
end)

registerForEvent('onUpdate', function(delta)
  private.passedTime = private.passedTime + delta

  if private.passedTime > 0.033 then
    private.passedTime = 0

    flashlight:findEntity()
    flashlight:calibrate()
    flashlight:move()
  end
end)

registerInput('switch_flashlight', 'Switch Flashlight', function(keypress)
  if not keypress then
    flashlight:switch()
  end
end)

registerForEvent('onShutdown', function()
  flashlight:despawn()
  flashlight:destroy()
  settings:destroy()
end)

return public
