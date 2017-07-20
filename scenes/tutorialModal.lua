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
local nextButton
local skipButton
local finishButton

-- Modal group
local modalGroup

-- if true, tutorial engaged
local tutorial = false

-- Function to handle details button
-- TODO: Open encylopedia with that fish
local function handleButtonEventNext(event)
  if (event.phase == "ended") then
    tutorial = true
    composer.hideOverlay(true, "fade", 400)
  end
end

-- Function to handle close button
local function handleButtonEventSkip(event)
  if (event.phase == "ended") then
    db:update("UPDATE Flags SET watchedTutorial = 1")
    tutorial = false
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

  -- Next button
  local nextButton = widget.newButton(
  {
      label = "Next",
      fontSize = 40,
      onEvent = handleButtonEventNext,
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
    }
  )
  -- Center the button
  nextButton.x = (modalBox.width / -2) + 150
  nextButton.y = 270
  modalGroup:insert(nextButton) -- Insert the button

  -- Skip button
  skipButton = widget.newButton(
  {
      label = "Skip",
      fontSize = 40,
      onEvent = handleButtonEventSkip,
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
    }
  )
  -- Center the button
  skipButton.x = (modalBox.width / 2) - 150
  skipButton.y = 270
  modalGroup:insert(skipButton) -- Insert the button

  if (event.params.finishButton) then
    -- Skip button
    finishButton = widget.newButton(
    {
        label = "Finish",
        fontSize = 40,
        onEvent = handleButtonEventSkip,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 500,
        height = 75,
        cornerRadius = 12,
        fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4
      }
    )
    -- Center the button
    finishButton.x = 0
    finishButton.y = 270
    modalGroup:insert(finishButton) -- Insert the button

    modalGroup:remove(nextButton)
    modalGroup:remove(skipButton)
  end

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
    parent:resumeGame(tutorial)
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