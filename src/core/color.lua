color = {
  init = function(self)
    self.presets = {
      ['255, 255, 255'] = 2,
      ['255, 228, 225'] = 3,
      ['250, 128, 114'] = 4,
      ['127, 255, 0'] = 5,
      ['0, 255, 255'] = 6,
      ['240, 230, 140'] = 7,
      ['238, 130, 238'] = 8,
      ['244, 164, 96'] = 9,
      ['255, 192, 203'] = 10,
      [1] = 'Custom',
      [2] = 'White',
      [3] = 'MistyRose',
      [4] = 'Salmon',
      [5] = 'Chartreuse',
      [6] = 'Cyan',
      [7] = 'Khaki',
      [8] = 'Violet',
      [9] = 'SandyBrown',
      [10] = 'Pink',
      White = {
        red = 255,
        green = 255,
        blue = 255
      },
      MistyRose = {
        red = 255,
        green = 228,
        blue = 225
      },
      Salmon = {
        red = 250,
        green = 128,
        blue = 114
      },
      Chartreuse = {
        red = 127,
        green = 255,
        blue = 0
      },
      Cyan = {
        red = 0,
        green = 255,
        blue = 255
      },
      Khaki = {
        red = 240,
        green = 230,
        blue = 140
      },
      Violet = {
        red = 238,
        green = 130,
        blue = 238
      },
      SandyBrown = {
        red = 244,
        green = 164,
        blue = 96
      },
      Pink = {
        red = 255,
        green = 192,
        blue = 203
      }
    }

    self.defaultPreset = 3
    self.preset = self.defaultPreset

    self.selectedRed = self:getByIndex(self.preset).red
    self.selectedGreen = self:getByIndex(self.preset).green
    self.selectedBlue = self:getByIndex(self.preset).blue

    self.options = {}
  end,

  builtFrom = function(self, red, green, blue)
    return Color.new({ Red = red, Green = green, Blue = blue, Alpha = 1 })
  end,

  isEqualTo = function(self, color)
    return self.selectedRed == color.Red and self.selectedGreen == color.Green and self.selectedBlue == color.Blue
  end,

  getNames = function(self)
    return { table.unpack(self.presets, 1, 10) }
  end,

  getByIndex = function(self, index)
    return self.presets[self.presets[index]]
  end,

  findIndexByRGB = function(self, red, green, blue)
    return self.presets[red .. ', ' .. green .. ', ' .. blue]
  end,

  getSelected = function(self)
    return self.preset == 1 and
      { red = self.selectedRed, green = self.selectedGreen, blue = self.selectedBlue } or
      self:getByIndex(self.preset)
  end,

  getDefault = function(self)
    return self:getByIndex(self.defaultPreset)
  end,

  setPreset = function (self, value)
    local color = self:getByIndex(value)

    if color ~= nil then
      self.preset = value
      self.selectedRed = color.red
      self.selectedGreen = color.green
      self.selectedBlue = color.blue
    end
  end,

  setRed = function(self, value)
    print(value)
    print(self.selectedGreen)
    print(self.selectedBlue)
    local foundPreset = self:findIndexByRGB(value, self.selectedGreen, self.selectedBlue)

    self.selectedRed = value
    self.preset = foundPreset or 1
  end,

  setGreen = function(self, value)
    local foundPreset = self:findIndexByRGB(self.selectedRed, value, self.selectedBlue)

    self.selectedGreen = value
    self.preset = foundPreset or 1
  end,

  setBlue = function(self, value)
    local foundPreset = self:findIndexByRGB(self.selectedRed, self.selectedGreen, value)

    self.selectedBlue = value
    self.preset = foundPreset or 1
  end
}
