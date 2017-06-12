-- baitButton
-- Create a new bait button that will show the user the bait selection

-- Imports
local widget = require("widget")
local composer = require("composer")

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
    label = "Bait",
    fontSize = 40,
    onEvent = openBaitModal,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 150,
    height = 75,
    cornerRadius = 12,
    fillColor = {default={1,0,0,1}, over={1,0.1,0.7,0.4}},
    strokeColor = {default={1,0.4,0,1}, over={0.8,0.8,1,1}},
    strokeWidth = 4
  }) 
  baitButton.anim.x = x
  baitButton.anim.y = y
  group:insert(baitButton.anim)

  return baitButton
end

return _BaitButton