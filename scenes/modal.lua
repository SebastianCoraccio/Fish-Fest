-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require( "composer" )
local fishInfo = require("data.fishInfo")
local widget = require("widget")

-- This scene
local scene = composer.newScene()

-- Local pieces of modal
local modalBox
local msgText
local button1
local button2
local valueText

local modalGroup

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
    composer.hideOverlay(true, "fade", 400)
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
   -- New display group to add modal too
  modalGroup = display.newGroup()
  sceneGroup:insert(modalGroup)
  -- Code here runs when the scene is first created but has not yet appeared on screen
  -- Background
	modalBox = display.newRoundedRect(0, 0, display.contentWidth / 1.5, display.contentHeight / 1.5, 12)
	modalBox:setFillColor( 255 )
	modalBox:setStrokeColor(78, 179, 211)
	modalBox.strokeWidth = 4
	modalGroup:insert(modalBox)

  local fid = event.params.fid

  -- Get fish name from fid
  local fishName = ""
  local value = 0
  for i = 1, #fishInfo do
    if (fid == fishInfo[i].fid) then
      fishName = fishInfo[i].name
      value = fishInfo[i].value
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
	msgText:setFillColor(0)
	modalGroup:insert(msgText)

  -- Value and weight text
  local valueOptions = {
    text = "Worth: " .. value,
    x = -115,
    y = 140,
    fontSize = 40,
    align = "center"
  }
  valueText = display.newText(valueOptions)
  valueText:setFillColor(0)
  modalGroup:insert(valueText)

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
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen

  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent  -- Reference to the parent scene object

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    parent:resumeGame()
  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy( event )
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene