flashlight = {
  init = function (self)
    self.colliderCName = CName.new('Collider')
    self.meshCName = CName.new('Mesh0371')
    self.lightCName = CName.new('Light1460')
    self.forceReadyStateCName = CName.new('ForceReadyState')
    self.entityId = nil
    self.entity = nil
    self.light = nil
    self.stateContext = nil

    self.path = [[base\gameplay\devices\lighting\industrial\spotlight\spotlight_d_lamp_a_glen_overhang.ent]]
    self.entityStatus = FlashlightStatus.DESPAWNED
    self.lightStatus = LightStatus.OFF
    self.disableColl = true
    self.disableVisib = true
  end,

  destroy = function (self)
    self.colliderCName = nil
    self.meshCName = nil
    self.lightCName = nil
    self.forceReadyStateCName = nil
    self.entityId = nil
    self.entity = nil
    self.light = nil
    self.stateContext = nil
  end,

  setStateContext = function (self, stateContext)
    self.stateContext = stateContext
  end,

  turnOn = function (self)
    if self.entity ~= nil and self.lightStatus == LightStatus.OFF then
      self.lightStatus = LightStatus.ON
      self.entity:TurnOnLights()

      if generalOptions.keepWeaponReady then
        self:togglePlayerWeaponReadyState(true)
      end
    end
  end,

  turnOff = function (self)
    if self.entity ~= nil and self.lightStatus == LightStatus.ON then
      self.lightStatus = LightStatus.OFF
      self.entity:TurnOffLights()
      self:togglePlayerWeaponReadyState(false)
    end
  end,

  getSpawnPoint = function (self)
    local spawnTransform = WorldTransform.new()

    spawnPos = operator:sumVectors(operator:getUpVec(0.03), operator:getForwardVec(0.8))
    spawnRot = operator:getUpQuat(-90)

    spawnTransform:SetPosition(spawnPos)
    spawnTransform:SetOrientation(spawnRot)

    return spawnTransform
  end,

  spawn = function (self)
    if self.entityStatus == FlashlightStatus.DESPAWNED then
      self.entityStatus = FlashlightStatus.SPAWNING

      self.entityId = exEntitySpawner.Spawn(self.path, self:getSpawnPoint())

      if self.entityId ~= nil then
        sound:playTurnOn()
      end
    end
  end,

  despawn = function (self)
    if self.entityStatus == FlashlightStatus.SPAWNED then
      self.entityStatus = FlashlightStatus.DESPAWNING

      if self.entity ~= nil then
        exEntitySpawner.Despawn(self.entity)
        sound:playTurnOff()
      end

      self.entityId = nil
      self.entity = nil
      self.light = nil

      self.entityStatus = FlashlightStatus.DESPAWNED
      self.lightStatus = LightStatus.OFF
    end
  end,

  findEntity = function (self)
    if self.entityStatus == FlashlightStatus.SPAWNING and self.entityId ~= nil and self.entity == nil then
      self.entity = Game.FindEntityByID(self.entityId)

      if self.entity ~= nil then
        if self.disableColl then self.entity:ToggleComponentByName(self.colliderCName, false) end
        if self.disableVisib then self.entity:ToggleComponentByName(self.meshCName, false) end

        self.light = self.entity:FindComponentByName(self.lightCName)

        if self.light ~= nil then
          self:bindToPlayerWeapon()

          self.entityStatus = FlashlightStatus.SPAWNED
          self.lightStatus = LightStatus.ON
        end
      end
    end
  end,

  isStateDirty = function (self)
    if self.light == nil then
      return false
    end

    local lightSettings = self.light:GetCurrentSettings()
    return lightBeam:isStateDirty(lightSettings) or color:isStateDirty(lightSettings.color)
  end,

  calibrate = function (self)
    if self.light ~= nil and self.lightStatus == LightStatus.ON then
      if self:isStateDirty() then
        self:setDistance(lightBeam.distance)
        self:setPower(lightBeam.power)
        self:setSize(lightBeam.size, lightBeam.blend)
        self:setColor(color:getSelected())
      end
    end
  end,

  bindToPlayerWeapon = function (self)
    local playerWeapon = player:getActiveWeapon()

    if self.entity ~= nil and playerWeapon ~= nil then
      EntityGameInterface.UnbindTransform(self.entity:GetEntity())
      EntityGameInterface.BindToComponent(self.entity:GetEntity(), playerWeapon:GetEntity(), CName.new('SlotComponent'), CName.new('Receiver'), false)
    end
  end,

  togglePlayerWeaponReadyState = function (self, state)
    if self.stateContext ~= nil then
      self.stateContext:SetPermanentBoolParameter(self.forceReadyStateCName, state, true)
    end
  end,

  switch = function (self)
    local isActivelyPlaying = player:checkIfActivelyPlaying()
    local isInsideVehicle = player:checkIfInsideVehicle()
    local playerWeapon = player:getActiveWeapon()

    if not isInsideVehicle and isActivelyPlaying and playerWeapon ~= nil and not playerWeapon:IsMelee() then
      if self.entityStatus == FlashlightStatus.DESPAWNED then
        self:spawn()

        if generalOptions.keepWeaponReady then
          self:togglePlayerWeaponReadyState(true)
        end
      elseif self.entityStatus == FlashlightStatus.SPAWNED then
        self:despawn()
        self:togglePlayerWeaponReadyState(false)
      end
    end
  end,

  setDistance = function (self, distance)
    if self.light ~= nil then
      self.light:SetRadius(distance)
    end
  end,

  setPower = function (self, power)
    if self.light ~= nil then
      self.light:SetStrength(power)
    end
  end,

  setSize = function (self, size, blend)
    if self.light ~= nil then
      self.light:SetAngles(blend, size)
    end
  end,

  setColor = function (self, targetColor)
    if self.light ~= nil then
      self.light:SetColor(color:builtFrom(targetColor.red, targetColor.green, targetColor.blue))
    end
  end
}
