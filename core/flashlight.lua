require "settings"
require "vector"

flashlight = {
  init = function (self)
    self.drawnWeapon = player:getActivePlayerWeapon()
    self.colliderCName = CName.new('Collider')
    self.meshCName = CName.new('Mesh0371')
    self.lightCName = CName.new('Light1460')
    self.entityId = nil
    self.entity = nil
    self.light = nil
    self.turnOnSoundCName = CName.new('ui_radio_turn_on')
    self.turnOffSoundCName = CName.new('ui_tv_turn_on')

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
    self.turnOnSoundCName = nil
    self.turnOffSoundCName = nil
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

  playTurnOnSound = function (self)
    GameObject.PlaySound(Game.GetPlayer(), self.turnOnSoundCName)
  end,

  playTurnOffSound = function (self)
    GameObject.PlaySound(Game.GetPlayer(), self.turnOffSoundCName)
  end,

  getSpawnPoint = function (self)
    if self.drawnWeapon == nil then
      return
    end

    local spawnTransform = WorldTransform.new()
    local spawnPos = nil
    local spawnAngle = nil

    if self.entityStatus == FlashlightStatus.SPAWNED then
      local muzzleTransform = self.drawnWeapon:GetMuzzleSlotWorldTransform()
      local muzzlePos = Transform.GetPosition(muzzleTransform)
      local muzzleAngle = Transform.ToEulerAngles(muzzleTransform)
      local forwardDir = vector:multiplyByScalar(self.drawnWeapon:GetWorldForward(), 0.1)
      local upDir = vector:multiplyByScalar(self.drawnWeapon:GetWorldUp(), 0.2)
      local direction = vector:add(forwardDir, upDir)

      spawnPos = vector:add(muzzlePos, direction)
      spawnAngle = EulerAngles.new(muzzleAngle.pitch, 0, muzzleAngle.yaw - 90)
    elseif self.entityStatus == FlashlightStatus.SPAWNING then
      local playerPos = Game.GetPlayer():GetWorldPosition()

      spawnPos = Vector4.new(playerPos.x, playerPos.y, playerPos.z - 5, playerPos.w)
      spawnAngle = EulerAngles.new(0, 0, 0)
    end

    WorldTransform.SetPosition(spawnTransform, spawnPos)
    WorldTransform.SetOrientationEuler(spawnTransform, spawnAngle)

    return {
      transform = spawnTransform,
      pos = spawnPos,
      angle = spawnAngle
    }
  end,

  spawn = function (self)
    if self.entityStatus == FlashlightStatus.DESPAWNED then
      self:playTurnOnSound()

      self.entityStatus = FlashlightStatus.SPAWNING

      local spawnPoint = self:getSpawnPoint()
      self.entityId = exEntitySpawner.Spawn(self.path, spawnPoint.transform)
    end
  end,

  despawn = function (self)
    if self.entityStatus == FlashlightStatus.SPAWNED then
      self:playTurnOffSound()
  
      self.entityStatus = FlashlightStatus.DESPAWNING
  
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
      Game.GetTeleportationFacility():Teleport(self.entity, spawnPoint.pos, spawnPoint.angle)
    end
  end,

  calibrate = function (self)
    if self.light ~= nil and self.lightStatus == LightStatus.ON then
      self.light:SetRadius(settings.lightDistance)
      self.light:SetStrength(settings.lightPower)
      self.light:SetAngles(settings.lightBlend, settings.lightSize)
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
  end
}
