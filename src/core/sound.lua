sound = {
  init = function (self)
    self.presets = {
      [1] = 'None',
      [2] = 'ui_radio_turn_on',
      [3] = 'ui_tv_turn_on',
      [4] = 'ui_hologram_turn_on',
      [5] = 'ui_computer_turn_on',
      [6] = 'ui_terminal_positive',
      [7] = 'dev_surveillance_camera_loop_start',
      [8] = 'ui_computer_turn_off',
      [9] = 'ui_tv_turn_off',
      [10] = 'ui_hologram_turn_off',
      [11] = 'ui_hacking_exit',
      [12] = 'ui_terminal_negative',
      [13] = 'dev_surveillance_camera_turn_off',
      [14] = 'ui_positive',
      [15] = 'ui_generic_set_02_positive',
      [16] = 'ui_generic_set_05_positive',
      [17] = 'ui_generic_set_07_positive',
      [18] = 'ui_generic_set_10_positive',
      [19] = 'ui_generic_set_14_positive',
      [20] = 'ui_hacking_access_panel_close',
      [21] = 'ui_generic_set_03_negative',
      [22] = 'ui_generic_set_06_negative',
      [23] = 'ui_generic_set_07_negative',
      [24] = 'ui_generic_set_09_negative',
      [25] = 'ui_generic_set_13_negative',
      None = 1,
      ui_radio_turn_on = 2,
      ui_tv_turn_on = 3,
      ui_hologram_turn_on = 4,
      ui_computer_turn_on = 5,
      ui_terminal_positive = 6,
      dev_metal_detector_turn_on = 7,
      dev_surveillance_camera_loop_start = 8,
      ui_computer_turn_off = 9,
      ui_tv_turn_off = 10,
      ui_hologram_turn_off = 11,
      ui_hacking_exit = 12,
      ui_terminal_negative = 13,
      dev_metal_detector_turn_off = 14,
      dev_surveillance_camera_turn_off = 15,
      ui_positive = 16,
      ui_generic_set_02_positive = 17,
      ui_generic_set_05_positive = 18,
      ui_generic_set_07_positive = 19,
      ui_generic_set_10_positive = 20,
      ui_generic_set_14_positive = 21,
      ui_hacking_access_panel_close = 22,
      ui_generic_set_03_negative = 23,
      ui_generic_set_06_negative = 24,
      ui_generic_set_07_negative = 25,
      ui_generic_set_09_negative = 26,
      ui_generic_set_13_negative = 27,
    }

    self.defaultTurnOnPreset = 2
    self.defaultTurnOffPreset = 3

    self.turnOnPreset = self.defaultTurnOnPreset
    self.turnOffPreset = self.defaultTurnOffPreset

    self.selectedTurnOn = self:getByIndex(self.turnOnPreset)
    self.selectedTurnOff = self:getByIndex(self.turnOffPreset)

    self.requestPlayTurnOn = 0
    self.requestPlayTurnOff = 0
  end,

  toList = function (self)
    return { table.unpack(self.presets, 1, 27) }
  end,

  getByIndex = function (self, index)
    return self.presets[index]
  end,

  findIndexByName = function (self, name)
    return self.presets[name]
  end,

  setTurnOnPreset = function (self, index)
    local sound = self:getByIndex(index)

    if sound ~= nil then
      self.turnOnPreset = index
      self.selectedTurnOn = sound
    end
  end,

  setTurnOffPreset = function (self, index)
    local sound = self:getByIndex(index)

    if sound ~= nil then
      self.turnOffPreset = index
      self.selectedTurnOff = sound
    end
  end,

  playTurnOn = function (self, delay)
    if self.turnOnPreset ~= 1 then
      delay = delay or 0

      if delay == 0 then
        GameObject.PlaySound(Game.GetPlayer(), CName.new(self.selectedTurnOn))
      else
        self.requestPlayTurnOn = delay
      end
    end
  end,

  playTurnOff = function (self, delay)
    if self.turnOffPreset ~= 1 then
      delay = delay or 0

      if delay == 0 then
        GameObject.PlaySound(Game.GetPlayer(), CName.new(self.selectedTurnOff))
      else
        self.requestPlayTurnOff = delay
      end
    end
  end,

  checkPlayRequests = function (self, tickTime)
    if self.requestPlayTurnOn > 0 then
      self.requestPlayTurnOn = self.requestPlayTurnOn - tickTime

      if self.requestPlayTurnOn == 0 then
        self:playTurnOn()
      end
    end

    if self.requestPlayTurnOff > 0 then
      self.requestPlayTurnOff = self.requestPlayTurnOff - tickTime

      if self.requestPlayTurnOff == 0 then
        self:playTurnOff()
      end
    end
  end
}
