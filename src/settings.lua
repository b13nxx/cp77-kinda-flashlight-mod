settings = {
  init = function (self, title, version)
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

    color:init()

    self.filePath = 'settings.json'
    self.nativeSettings = GetMod('nativeSettings')
    self.lightColorPresetChanged = false
    self.path = '/KRF'
    self.sections = {
      [1] = 'lightBeam',
      [2] = 'color',
      [3] = 'sound',
      lightBeam = {
        path = '/lightBeam',
        title = 'Light Beam'
      },
      color = {
        path = '/color',
        title = 'Color'
      },
      sound = {
        path = '/sound',
        title = 'Sound'
      }
    }

    self.nativeSettings.addTab(self.path, title .. ' (' .. version .. ')')
  end,

  calcLightPower = function (self, percent)
    local multiply = percent / 100
    return StringToFloat(FloatToStringPrec(16 * multiply, 2))
  end,

  calcLightBlend = function (self, size, percent)
    local multiply = percent / 100
    return size - FloorF(size * multiply)
  end,

  updateLightColorRGB = function (self)
    self.lightColorPresetChanged = true

    local selectedLightColor = color:getSelected()

    self.nativeSettings.setOption(color.options.red, selectedLightColor.red)
    self.nativeSettings.setOption(color.options.green, selectedLightColor.green)
    self.nativeSettings.setOption(color.options.blue, selectedLightColor.blue)

    self.lightColorPresetChanged = false
  end,

  updateLightColorPreset = function (self)
    if self.lightColorPresetChanged ~= true then
      self.nativeSettings.setOption(color.options.preset, color.preset)
    end
  end,

  draw = function (self)
    for _, name in ipairs(self.sections) do
      self.nativeSettings.addSubcategory(self.path .. self.sections[name].path, self.sections[name].title)
    end

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Distance', 'How far light should travel', 5, 70, 5, self.lightDistance, self.defaultLightDistance, function(value)
      self.lightDistance = value
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetRadius(value)
      end
    end)

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Power (%)', 'How strong the light should be', 2, 100, 2, self.lightPowerPercent, self.defaultLightPowerPercent, function(value)
      self.lightPowerPercent = value
      self.lightPower = self:calcLightPower(self.lightPowerPercent)
      self:save()

      print('lightPower', self.lightPower)

      if flashlight.light ~= nil then
        flashlight.light:SetStrength(self.lightPower)
      end
    end)

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Size', 'How strong the light should be', 20, 50, 10, self.lightSize, self.defaultLightSize, function(value)
      self.lightSize = value
      self.lightBlend = self:calcLightBlend(self.lightSize, self.lightBlendPercent)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetAngles(self.lightBlend, self.lightSize)
      end
    end)

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Blend (%)', 'How strong the light should be', 40, 80, 10, self.lightBlendPercent, self.defaultLightBlendPercent, function(value)
      self.lightBlendPercent = value
      self.lightBlend = self:calcLightBlend(self.lightSize, self.lightBlendPercent)
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetAngles(self.lightBlend, self.lightSize)
      end
    end)



    local selectedLightColor = color:getSelected()
    local defaultLightColor = color:getDefault()

    color.options.preset = self.nativeSettings.addSelectorString(self.path .. self.sections.color.path, 'Preset', 'Description', color:getNames(), color.preset, color.defaultPreset, function(value)
      color:setPreset(value)
      
      self:updateLightColorRGB()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    color.options.red = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Red', 'Description', 0, 255, 1, selectedLightColor.red, defaultLightColor.red, function(value)
      color:setRed(value)

      self:updateLightColorPreset()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    color.options.green = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Green', 'Description', 0, 255, 1, selectedLightColor.green, defaultLightColor.green, function(value)
      color:setGreen(value)

      self:updateLightColorPreset()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    color.options.blue = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Blue', 'Description', 0, 255, 1, selectedLightColor.blue, defaultLightColor.blue, function(value)
      color:setBlue(value)

      self:updateLightColorPreset()
      self:save()

      flashlight:setColor(color:getSelected())
    end)
  end,

  load = function (self)
    local file = io.open(self.filePath, 'r')
  
    if not file then
      return self:save()
    end

    local content = file:read('*a');

    if content ~= '' then
      local jsonData = json.decode(content)

      file:close()

      for key, value in pairs(jsonData) do
        --if self[key] ~= nil then
          self[key] = value
        --end
      end

      self.lightPower = self:calcLightPower(self.lightPowerPercent)
      self.lightBlend = self:calcLightBlend(self.lightSize, self.lightBlendPercent)

      color:setRed(self.lightColorRed)
      color:setGreen(self.lightColorGreen)
      color:setBlue(self.lightColorBlue)
    end
  end,

  save = function(self)
    local file = io.open(self.filePath, 'w')

    if file then
      local selectedLightColor = color:getSelected()

      file:write(json.encode({
        lightDistance = self.lightDistance,
        lightSize = self.lightSize,
        lightPowerPercent = self.lightPowerPercent,
        lightBlendPercent = self.lightBlendPercent,
        lightColorRed = selectedLightColor.red,
        lightColorGreen = selectedLightColor.green,
        lightColorBlue = selectedLightColor.blue
      }))

      file:close()
    end
  end,

  destroy = function (self)
    self.nativeSettings = nil
  end
}
