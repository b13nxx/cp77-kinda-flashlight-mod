lightBeam = {
  init = function (self)
    self.maxPower = 80

    self.defaultDistance = 60
    self.defaultSize = 50
    self.defaultPowerPercent = 20
    self.defaultBlendPercent = 80

    self.distance = self.defaultDistance
    self.size = self.defaultSize
    self.powerPercent = self.defaultPowerPercent
    self.blendPercent = self.defaultBlendPercent

    self.power = self:calcPower(self.powerPercent)
    self.blend = self:calcBlend(self.size, self.blendPercent)
  end,

  isStateDirty = function (self, lightSettings)
    return lightSettings.strength ~= self.power or
      lightSettings.radius ~= self.distance or
      lightSettings.innerAngle ~= self.blend or
      lightSettings.outerAngle ~= self.size
  end,

  calcPower = function (self, percent)
    local multiply = percent / 100
    return StringToFloat(FloatToStringPrec(self.maxPower * multiply, 2))
  end,

  calcBlend = function (self, size, percent)
    local multiply = percent / 100
    return size - FloorF(size * multiply)
  end,

  setDistance = function (self, value)
    self.distance = value
  end,

  setSize = function (self, value)
    self.size = value
    self.blend = self:calcBlend(self.size, self.blendPercent)
  end,

  setPowerPercent = function (self, percent)
    self.powerPercent = percent
    self.power = self:calcPower(self.powerPercent)

    print('power is', self.power)
  end,

  setBlendPercent = function (self, percent)
    self.blendPercent = percent
    self.blend = self:calcBlend(self.size, self.blendPercent)
  end
}
