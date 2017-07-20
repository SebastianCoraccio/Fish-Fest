-- baitButton
-- Create a new bait button that will show the user the bait selection

-- Imports
local widget = require("widget")
local composer = require("composer")
local utils = require("utils")

-- Bait Button object
local _BaitButton = {}

-- Create a bait button in the display group, 'group'
function _BaitButton.create(x, y, group, loc)
  local baitButton = {}

  -- Open bait modal
  function openBaitModal(event)
    if (event.phase == "ended") then
      local options = {
        isModal = true,
        effect = "fade",
        time = 400,
        params = {
          location = loc
        }
      }
      composer.showOverlay("scenes.baitModal", options)

      -- Pause the game
      local pauseEvent = {name="pauseEvent", target="scene"}
      baitButton.anim:dispatchEvent(pauseEvent)
    end
  end
  
  baitButton.anim = widget.newButton(
  {
    label = "Chum",
    fontSize = 50,
    onEvent = openBaitModal,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 150,
    height = 75,
    cornerRadius = 12,
    labelColor = {default={utils.hexToRGB("#ef4100")}, over={utils.hexToRGB("#00aeef")}},
    fillColor = {default={utils.hexToRGB("#00aeef")}, over={utils.hexToRGB("#ef4100")}},
    strokeColor = {default={0}, over={0}},
    strokeWidth = 3
  }) 
  baitButton.anim.x = x
  baitButton.anim.y = y
  group:insert(baitButton.anim)

  return baitButton
end

return _BaitButton