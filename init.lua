--print('KRF is loaded!')

require "core/enums"
require "core/utils/debug"
require "core/utils/player"
require "core/flashlight"

public = {
  isReady = false,
  title = 'KRF',
  version = '2.1'
}

private = {
  passedTime = 0
}

registerForEvent('onInit', function()
  public.isReady = true

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

  Observe('UpperBodyTransition', 'SetWeaponHolster', function (self, _scriptInterface, newState)
    local isHolstered = newState

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
end)

return public
