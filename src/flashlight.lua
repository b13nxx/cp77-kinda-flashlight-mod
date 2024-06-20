flashlight = {
  init = function (self)
    self.drawnWeapon = player:getActivePlayerWeapon()
    self.colliderCName = CName.new('Collider')
    self.meshCName = CName.new('Mesh0371')
    self.lightCName = CName.new('Light1460')
    self.entityId = nil
    self.entity = nil
    self.light = nil

    self.path = [[base\gameplay\devices\lighting\industrial\spotlight\spotlight_d_lamp_a_glen_overhang.ent]]
    self.entityStatus = FlashlightStatus.DESPAWNED
    self.lightStatus = LightStatus.OFF
    self.disableColl = true
    self.disableVisib = false
  end,

  destroy = function (self)
    self.drawnWeapon = nil
    self.colliderCName = nil
    self.meshCName = nil
    self.lightCName = nil
    self.entityId = nil
    self.entity = nil
    self.light = nil
  end,

  turnOn = function (self)
    if self.entity ~= nil and self.lightStatus == LightStatus.OFF then
      self.lightStatus = LightStatus.ON
      self.entity:TurnOnLights()
    end
  end,

  turnOff = function (self)
    if self.entity ~= nil and self.lightStatus == LightStatus.ON then
      self.lightStatus = LightStatus.OFF
      self.entity:TurnOffLights()
    end
  end,

  getSpawnPoint = function (self)
    if self.drawnWeapon == nil then
      return
    end

    local spawnTransform = WorldTransform.new()
    local spawnPos = nil
    local spawnRot = nil

    if self.entityStatus == FlashlightStatus.SPAWNED then
      local muzzleTransform = self.drawnWeapon:GetMuzzleSlotWorldTransform()
      local muzzlePos = muzzleTransform:GetPosition()
      local muzzleRot = muzzleTransform:GetOrientation()

      local forwardDir = operator:mulVectorByScalar(muzzleTransform:GetForward(), 0.1)
      local upDir = operator:mulVectorByScalar(muzzleTransform:GetUp(), 0.03)
      local direction = operator:addVectors(forwardDir, upDir)

      spawnPos = operator:addVectors(muzzlePos, direction)
      spawnRot = operator:rotQuatByZ(muzzleRot, -90)
    elseif self.entityStatus == FlashlightStatus.SPAWNING then
      local playerPos = Game.GetPlayer():GetWorldPosition()

      spawnPos = Vector4.new(playerPos.x, playerPos.y, playerPos.z - 5, playerPos.w)
      spawnRot = Quaternion.new()
    end

    spawnTransform:SetPosition(spawnPos)
    spawnTransform:SetOrientation(spawnRot)

    return {
      transform = spawnTransform,
      pos = spawnPos,
      rot = spawnRot
    }
  end,

  spawn = function (self)
    if self.entityStatus == FlashlightStatus.DESPAWNED then
      self.entityStatus = FlashlightStatus.SPAWNING

      sound:playTurnOn()

      local spawnPoint = self:getSpawnPoint()
      self.entityId = exEntitySpawner.Spawn(self.path, spawnPoint.transform)
    end
  end,

  despawn = function (self)
    if self.entityStatus == FlashlightStatus.SPAWNED then
      self.entityStatus = FlashlightStatus.DESPAWNING

      sound:playTurnOff()

      exEntitySpawner.Despawn(self.entity)

      self.drawnWeapon = nil
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
          self.entityStatus = FlashlightStatus.SPAWNED
          self.lightStatus = LightStatus.ON
        end
      end
    end
  end,

  move = function (self)
    if self.entityStatus == FlashlightStatus.SPAWNED then
      local spawnPoint = self:getSpawnPoint()
      Game.GetTeleportationFacility():Teleport(self.entity, spawnPoint.pos, spawnPoint.rot:ToEulerAngles())
    end
  end,

  calibrate = function (self)
    if self.light ~= nil and self.lightStatus == LightStatus.ON then
      local lightSettings = self.light:GetCurrentSettings()
      local isLightStateDirty = lightBeam:isStateDirty(lightSettings) or color:isStateDirty(lightSettings.color)

      if isLightStateDirty then
        self:setDistance(lightBeam.distance)
        self:setPower(lightBeam.power)
        self:setSize(lightBeam.size, lightBeam.blend)
        self:setColor(color:getSelected())
      end
    end
  end,

  switch = function (self)
    local isActivelyPlaying = player:checkIfActivelyPlaying()
    local isInsideVehicle = player:checkIfInsideVehicle()

    self.drawnWeapon = player:getActivePlayerWeapon()

    if not isInsideVehicle and isActivelyPlaying and self.drawnWeapon ~= nil then
      if self.entityStatus == FlashlightStatus.DESPAWNED and not self.drawnWeapon:IsMelee() then
        self:spawn()
      elseif self.entityStatus == FlashlightStatus.SPAWNED then
        self:despawn()
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
