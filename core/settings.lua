require "utils/debug"
require "flashlight"


settings = {
  init = function (self)
    self.path = '/KRF'
    self.lightDistance = 50
    self.lightPower = 1
    self.lightSize = 20
    self.lightBlend = 20

    self.nativeSettings = GetMod('nativeSettings')
    self.nativeSettings.addTab(self.path, 'KRF (2.1)')
  end,

  calcLightDistance = function (self, percent)
    local multiply = percent / 100
    return toFixed(70 * multiply, 2)
  end,

  calcLightDistancePercent = function (self, distance)
    return toPercent(distance / 70)
  end,

  calcLightPower = function (self, percent)
    local multiply = percent / 100
    return toFixed(16 * multiply, 2)
  end,

  calcLightPowerPercent = function (self, power)
    return toPercent(power / 8)
  end,

  calcLightBlend = function (self, size, percent)
    local multiply = percent / 100
    return size - math.floor(size * multiply)
  end,

  calcLightBlendPercent = function (self, size, blend)
    return toPercent((size - blend) / size)
  end,

  draw = function (self)
    self.nativeSettings.addRangeInt(self.path, "Distance", "How far light should travel", 10, 100, 5, self:calcLightDistancePercent(self.lightDistance), 70, function(value)
      self.lightDistance = self:calcLightDistance(value)
      print(self.lightDistance)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetRadius(value)
      end
    end)

    self.nativeSettings.addRangeInt(self.path, "Power (%)", "How strong the light should be", 10, 100, 10, self:calcLightPowerPercent(self.lightPower), 50, function(value)
      self.lightPower = self:calcLightPower(value)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetStrength(self.lightPower)
      end
    end)

    self.nativeSettings.addRangeInt(self.path, "Size", "How strong the light should be", 20, 50, 10, self.lightSize, 30, function(value)
      local percent = self:calcLightBlendPercent(self.lightSize, self.lightBlend)

      self.lightSize = value
      self.lightBlend = self:calcLightBlend(self.lightSize, percent)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetAngles(self.lightBlend, self.lightSize)
      end
    end)

    self.nativeSettings.addRangeInt(self.path, "Blend (%)", "How strong the light should be", 40, 80, 80, self:calcLightBlendPercent(self.lightSize, self.lightBlend), 40, function(value)
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
    end
  end,

  save = function(self)
    local file = io.open('settings.json', 'w')

    if file then
      file:write(json.encode({
        lightDistance = self.lightDistance,
        lightPower = self.lightPower,
        lightSize = self.lightSize,
        lightBlend = self.lightBlend
      }))

      file:close()
    end
  end,

  destroy = function (self)
    self.nativeSettings = nil
  end
}
