require 'utils/debug'
require 'flashlight'
require 'color'


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

    self.defaultLightColorPreset = 3
    local defaultLightColor = color:getByIndex(self.defaultLightColorPreset)

    self.defaultLightColorRed = defaultLightColor.red
    self.defaultLightColorGreen = defaultLightColor.green
    self.defaultLightColorBlue = defaultLightColor.blue

    self.lightColorPreset = self.defaultLightColorPreset
    self.lightColorRed = self.defaultLightColorRed
    self.lightColorGreen = self.defaultLightColorGreen
    self.lightColorBlue = self.defaultLightColorBlue

    self.lightColorOptions = {}
    self.lightColorPresetChanged = false

    self.nativeSettings = GetMod('nativeSettings')
    self.nativeSettings.addTab(self.path, title .. ' (' .. version .. ')')
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

    self.lightColorOptions.preset = self.nativeSettings.addSelectorString(self.path .. self.sections.color.path, 'Preset', 'Description', color:getNames(), self.lightColorPreset, self.defaultLightColorPreset, function(value)
      self.lightColorPreset = value
      local selectedLightColor = color:getByIndex(value)

      if selectedLightColor ~= nil then
        self.lightColorPresetChanged = true

        self.lightColorRed = selectedLightColor.red
        self.lightColorGreen = selectedLightColor.green
        self.lightColorBlue = selectedLightColor.blue

        self.nativeSettings.setOption(self.lightColorOptions.red, self.lightColorRed)
        self.nativeSettings.setOption(self.lightColorOptions.green, self.lightColorGreen)
        self.nativeSettings.setOption(self.lightColorOptions.blue, self.lightColorBlue)

        self:save()

        self.lightColorPresetChanged = false
      end

      if flashlight.light ~= nil then
        flashlight.light:SetColor(color:create(self.lightColorRed, self.lightColorGreen, self.lightColorBlue))
      end
    end)

    self.lightColorOptions.red = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Red', 'Description', 0, 255, 1, self.lightColorRed, self.defaultLightColorRed, function(value)
      self.lightColorRed = value

      if self.lightColorPresetChanged ~= true then
        local lightColorIndex = color:findIndexByRGB(self.lightColorRed, self.lightColorGreen, self.lightColorBlue)
        self.lightColorPreset = lightColorIndex or 1

        self.nativeSettings.setOption(self.lightColorOptions.preset, self.lightColorPreset)
      end

      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetColor(color:create(self.lightColorRed, self.lightColorGreen, self.lightColorBlue))
      end
    end)

    self.lightColorOptions.green = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Green', 'Description', 0, 255, 1, self.lightColorGreen, self.defaultLightColorGreen, function(value)
      self.lightColorGreen = value

      if self.lightColorPresetChanged ~= true then
        local lightColorIndex = color:findIndexByRGB(self.lightColorRed, self.lightColorGreen, self.lightColorBlue)
        self.lightColorPreset = lightColorIndex or 1

        self.nativeSettings.setOption(self.lightColorOptions.preset, self.lightColorPreset)
      end

      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetColor(color:create(self.lightColorRed, self.lightColorGreen, self.lightColorBlue))
      end
    end)

    self.lightColorOptions.blue = self.nativeSettings.addRangeInt(self.path .. self.sections.color.path, 'Blue', 'Description', 0, 255, 1, self.lightColorBlue, self.defaultLightColorBlue, function(value)
      self.lightColorBlue = value

      if self.lightColorPresetChanged ~= true then
        local lightColorIndex = color:findIndexByRGB(self.lightColorRed, self.lightColorGreen, self.lightColorBlue)
        self.lightColorPreset = lightColorIndex or 1

        self.nativeSettings.setOption(self.lightColorOptions.preset, self.lightColorPreset)
      end
      
      self:save()

      if flashlight.light ~= nil then
        flashlight.light:SetColor(color:create(self.lightColorRed, self.lightColorGreen, self.lightColorBlue))
      end
    end)
  end,

  load = function (self)
    local file = io.open('settings.json', 'r')
  
    if not file then
      return self:save()
    end

    local content = file:read('*a');

    if content ~= '' then
      local jsonData = json.decode(content)

      file:close()

      for key, value in pairs(jsonData) do
        if self[key] ~= nil then
          self[key] = value
        end
      end

      self.lightPower = self:calcLightPower(self.lightPowerPercent)
      self.lightBlend = self:calcLightBlend(self.lightSize, self.lightBlendPercent)

      local lightColorIndex = color:findIndexByRGB(self.lightColorRed, self.lightColorGreen, self.lightColorBlue)
      self.lightColorPreset = lightColorIndex or 1
    end
  end,

  save = function(self)
    local file = io.open('settings.json', 'w')

    if file then
      file:write(json.encode({
        lightDistance = self.lightDistance,
        lightSize = self.lightSize,
        lightPowerPercent = self.lightPowerPercent,
        lightBlendPercent = self.lightBlendPercent,
        lightColorRed = self.lightColorRed,
        lightColorGreen = self.lightColorGreen,
        lightColorBlue = self.lightColorBlue
      }))

      file:close()
    end
  end,

  destroy = function (self)
    self.nativeSettings = nil
  end
}
