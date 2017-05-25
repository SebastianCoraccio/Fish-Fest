-- Imports
local widget = require("widget")
local fishInfo = require("locations.fishInfo")

local _Modal = {}

function _Modal.create(fid)
  local modal = {}

  -- New display group to add modal too
  local modalGroup = display.newGroup()

  -- Local pieces of modal
  local modalBox
  local msgText
  local button1
  local button2

  -- Remove the modal
  local function _destroyModal()
    display.remove(modalGroup)
    modalGroup = nil
  end

  -- Function to handle details button
  -- TODO: Open encylopedia with that fish
  local function handleButtonEventDetails(event)
    if (event.phase == "ended") then
      print("Open encylopedia of that fish")
    end
  end

  -- Function to handle close button
  local function handleButtonEventClose(event)
    if (event.phase == "ended") then
      _destroyModal()
    end
  end

  -- Background
	modalBox = display.newRoundedRect(0, 0, display.contentWidth / 1.5, display.contentHeight / 1.5, 12)
	modalBox:setFillColor( 255 )
	modalBox:setStrokeColor(78, 179, 211)
	modalBox.strokeWidth = 4
	modalGroup:insert(modalBox)

  -- Get fish name from fid
  local fishName = fid
  for i = 1, #fishInfo do
    if (fid == fishInfo[i].fid) then
      fishName = fishInfo[i].name
      break
    end
  end

  -- Options for primary text
	local options = {
	   text = "You caught a " .. fishName .. "!",
     y = -200,
	   width = 320,

	   fontSize = 50,
	   align = "center"
	}
	msgText = display.newText(options)
	msgText:setFillColor( 0 )
	modalGroup:insert(msgText)

  -- Create the widget
  button1 = widget.newButton(
  {
      label = "Details",
      fontSize = 40,
      onEvent = handleButtonEventDetails,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 150,
      height = 75,
      cornerRadius = 12,
      fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
      strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
      strokeWidth = 4
    }
  )
 
  -- Center the button
  button1.x = -115
  button1.y = 270
  
  -- Insert the button
  modalGroup:insert(button1)

  -- Create the widget
  button2 = widget.newButton(
  {
      label = "Close",
      fontSize = 40,
      onEvent = handleButtonEventClose,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 150,
      height = 75,
      cornerRadius = 12,
      fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
      strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
      strokeWidth = 4
    }
  )
 
  -- Center the button
  button2.x = 115
  button2.y = 270
  
  -- Insert the button
  modalGroup:insert(button2)

  -- Place the group
	modalGroup.x = display.contentWidth / 2
	modalGroup.y = display.contentHeight / 2

  -- Send it to the front
  modalGroup:toFront()

  return modal
end

return _Modal