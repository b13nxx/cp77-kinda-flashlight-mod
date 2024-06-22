settings = {
  init = function (self, title, version)
    lightBeam:init()
    color:init()
    sound:init()

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

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Distance', 'How far traveled should the light be?', 5, 100, 5, lightBeam.distance, lightBeam.defaultDistance, function(value)
      lightBeam:setDistance(value)

      self:save()

      flashlight:setDistance(lightBeam.distance)
    end)

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Power (%)', 'How strong should the light be?', 2, 100, 2, lightBeam.powerPercent, lightBeam.defaultPowerPercent, function(value)
      lightBeam:setPowerPercent(value)

      self:save()

      flashlight:setPower(lightBeam.power)
    end)

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Size', 'How big should the light be?', 20, 50, 10, lightBeam.size, lightBeam.defaultSize, function(value)
      lightBeam:setSize(value)

      self:save()

      flashlight:setSize(lightBeam.size, lightBeam.blend)
    end)

    self.nativeSettings.addRangeInt(self.path .. self.sections.lightBeam.path, 'Blend (%)', 'How blended should the light be?', 40, 80, 10, lightBeam.blendPercent, lightBeam.defaultBlendPercent, function(value)
      lightBeam:setBlendPercent(value)

      self:save()

      flashlight:setSize(lightBeam.size, lightBeam.blend)
    end)



    local selectedLightColor = color:getSelected()
    local defaultLightColor = color:getDefault()

    color.options.preset = self.nativeSettings.addSelectorString(self.path .. self.sections.color.path, 'Preset', ' Preset to choose the color you want the light to be', color:toList(), color.preset, color.defaultPreset, function(value)
      color:setPreset(value)

      self:updateLightColorRGB()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    color.options.red = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Red', 'Intensity of the red', 0, 255, 1, selectedLightColor.red, defaultLightColor.red, function(value)
      color:setRed(value)

      self:updateLightColorPreset()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    color.options.green = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Green', 'Intensity of the green', 0, 255, 1, selectedLightColor.green, defaultLightColor.green, function(value)
      color:setGreen(value)

      self:updateLightColorPreset()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    color.options.blue = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Blue', 'Intensity of the blue', 0, 255, 1, selectedLightColor.blue, defaultLightColor.blue, function(value)
      color:setBlue(value)

      self:updateLightColorPreset()
      self:save()

      flashlight:setColor(color:getSelected())
    end)

    self.nativeSettings.addSelectorString(self.path .. self.sections.sound.path, 'Turn On', 'Sound to be played when the flashlight is turned on (wait 1 sec to hear an example)', sound:toList(), sound.turnOnPreset, sound.defaultTurnOnPreset, function(value)
      sound:setTurnOnPreset(value)
      sound:playTurnOn(1)

      self:save()
    end)

    self.nativeSettings.addSelectorString(self.path .. self.sections.sound.path, 'Turn Off', 'Sound to be played when the flashlight is turned off (wait 1 sec to hear an example)', sound:toList(), sound.turnOffPreset, sound.defaultTurnOffPreset, function(value)
      sound:setTurnOffPreset(value)
      sound:playTurnOff(1)

      self:save()
    end)
  end,

  load = function (self)
    local file = io.open(self.filePath, 'r')

    if not file then
      return self:save()
    end

    local content = file:read('*a')

    if content ~= '' then
      local jsonData = json.decode(content)

      file:close()

      for key, value in pairs(jsonData) do
        --if self[key] ~= nil then
          self[key] = value
        --end
      end

      lightBeam:setDistance(self.lightDistance)
      lightBeam:setSize(self.lightSize)
      lightBeam:setPowerPercent(self.lightPowerPercent)
      lightBeam:setBlendPercent(self.lightBlendPercent)

      color:setRed(self.lightColorRed)
      color:setGreen(self.lightColorGreen)
      color:setBlue(self.lightColorBlue)

      sound:setTurnOnPreset(sound:findIndexByName(self.lightTurnOnSound))
      sound:setTurnOffPreset(sound:findIndexByName(self.lightTurnOffSound))
    end
  end,

  save = function(self)
    local file = io.open(self.filePath, 'w')

    if file then
      local selectedLightColor = color:getSelected()

      file:write(json.encode({
        lightDistance = lightBeam.distance,
        lightSize = lightBeam.size,
        lightPowerPercent = lightBeam.powerPercent,
        lightBlendPercent = lightBeam.blendPercent,
        lightColorRed = selectedLightColor.red,
        lightColorGreen = selectedLightColor.green,
        lightColorBlue = selectedLightColor.blue,
        lightTurnOnSound = sound.selectedTurnOn,
        lightTurnOffSound = sound.selectedTurnOff
      }))

      file:close()
    end
  end,

  destroy = function (self)
    self.nativeSettings = nil
  end
}
