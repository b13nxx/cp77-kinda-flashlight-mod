require "utils/debug"
require "flashlight"


settings = {
  init = function (self)
    self.defaultLightDistance = 40
    self.defaultLightSize = 40
    self.defaultLightPowerPercent = 50
    self.defaultLightBlendPercent = 80

    self.lightDistance = self.defaultLightDistance
    self.lightSize = self.defaultLightSize
    self.lightPowerPercent = self.defaultLightPowerPercent
    self.lightBlendPercent = self.defaultLightBlendPercent

    self.lightPower = self:calcLightPower(self.defaultLightPowerPercent)
    self.lightBlend = self:calcLightBlend(self.defaultLightPowerPercent, self.defaultLightBlendPercent)

    self.path = '/KRF'
    self.nativeSettings = GetMod('nativeSettings')

    self.nativeSettings.addTab(self.path, 'KRF (2.1)')
  end,

  calcLightPower = function (self, percent)
    local multiply = percent / 100
    return toFixed(16 * multiply, 2)
  end,

  calcLightBlend = function (self, size, percent)
    local multiply = percent / 100
    return size - math.floor(size * multiply)
  end,

  draw = function (self)
    self.nativeSettings.addRangeInt(self.path, "Distance", "How far light should travel", 5, 70, 5, self.lightDistance, self.defaultLightDistance, function(value)
      self.lightDistance = value
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetRadius(value)
      end
    end)

    self.nativeSettings.addRangeInt(self.path, "Power (%)", "How strong the light should be", 2, 100, 2, self.lightPowerPercent, self.defaultLightPowerPercent, function(value)
      self.lightPowerPercent = value
      self.lightPower = self:calcLightPower(value)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetStrength(self.lightPower)
      end
    end)

    self.nativeSettings.addRangeInt(self.path, "Size", "How strong the light should be", 20, 50, 10, self.lightSize, self.defaultLightSize, function(value)
      self.lightSize = value
      self.lightBlend = self:calcLightBlend(self.lightSize, self.lightBlendPercent)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetAngles(self.lightBlend, self.lightSize)
      end
    end)

    self.nativeSettings.addRangeInt(self.path, "Blend (%)", "How strong the light should be", 40, 80, 10, self.lightBlendPercent, self.defaultLightBlendPercent, function(value)
      self.lightBlendPercent = value
      self.lightBlend = self:calcLightBlend(self.lightSize, value)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetAngles(self.lightBlend, self.lightSize)
      end
    end)
  end,

  load = function (self)
    local file = io.open('settings.json', 'r')
  
    if not file then
      return self:save()
    end

    local content = file:read('*a');

    if content ~= "" then
      local jsonData = json.decode(content)

      file:close()

      for key, value in pairs(jsonData) do
        if self[key] ~= nil then
          self[key] = value
        end
      end

      self.lightPower = self:calcLightPower(self.lightPowerPercent)
      self.lightBlend = self:calcLightBlend(self.lightSize, self.lightBlendPercent)
    end
  end,

  save = function(self)
    local file = io.open('settings.json', 'w')

    if file then
      file:write(json.encode({
        lightDistance = self.lightDistance,
        lightSize = self.lightSize,
        lightPowerPercent = self.lightPowerPercent,
        lightBlendPercent = self.lightBlendPercent
      }))

      file:close()
    end
  end,

  destroy = function (self)
    self.nativeSettings = nil
  end
}
