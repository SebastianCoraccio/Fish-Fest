-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local pieces of modal
local modalBox
local text
local closeButton

-- Modal group
local modalGroup

-- if true, tutorial engaged
local tutorial = false

-- Function to handle next button
local function handleButtonEventClose(event)
  if (event.phase == "ended") then
    composer.hideOverlay(true, "fade", 200)
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
  modalBox = display.newRoundedRect(0, 0, display.contentWidth / 1.25, display.contentHeight / 1.3, 12)
  modalBox:setFillColor( 255 )
  modalBox:setStrokeColor(0)
  modalBox.strokeWidth = 4
  modalGroup:insert(modalBox)

  -- Text information
  local text = display.newText({
    text = event.params.text,
     y = -80,
	   width = 500,
	   fontSize = 50,
	   align = "center"
  })
  text:setFillColor(0)
  modalGroup:insert(text)

  -- Close button
  closeButton = widget.newButton({
    label = "Close",
    fontSize = 40,
    onEvent = handleButtonEventClose,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 200,
    height = 75,
    cornerRadius = 12,
    labelColor = {default={utils.hexToRGB("#ef4100")}, over={utils.hexToRGB("#00aeef")}},
    fillColor = {default={utils.hexToRGB("#00aeef")}, over={utils.hexToRGB("#ef4100")}},
    strokeColor = {default={0}, over={0}},
    strokeWidth = 3
  })

  -- Center the button
  closeButton.x = 0
  closeButton.y = 270
  modalGroup:insert(closeButton) -- Insert the button

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