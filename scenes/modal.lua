-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require( "composer" )
local fishInfo = require("data.fishInfo")
local widget = require("widget")
local utils = require("utils")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local pieces of modal
local modalBox
local msgText
local button1
local button2
local valueText
local fishImage
local weightText

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
	modalBox = display.newRoundedRect(0, 0, display.contentWidth / 1.25, display.contentHeight / 1.4, 12)
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
  -- Check if first letter is vowell
  local firstLetter = string.sub(string.lower(fishName), 1,1)
  local a = "a "
  if (firstLetter == "a") or (firstLetter == "e") or (firstLetter == "i") or (firstLetter == "o") or
     (firstLetter == "u") then
    a = "an "
  end
	local options = {
	   text = "You caught " .. a .. fishName .. "!",
     y = -200,
	   width = 500,
	   fontSize = 50,
	   align = "center"
	}
	msgText = display.newText(options)
	msgText:setFillColor(0)
	modalGroup:insert(msgText)

  -- Value and weight text
  local valueOptions = {
    text = "Worth: " .. value,
    x = (modalBox.width / -2) + 165,
    y = 160,
    fontSize = 40,
    align = "center"
  }
  valueText = display.newText(valueOptions)
  valueText:setFillColor(0)
  modalGroup:insert(valueText)

  -- Calculate weight
  local one = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
  local two = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
  local three = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
  local weight = math.round(((one + two + three) / 3.0) * 100) * 0.01

  local weightText = display.newText({
    text = "Weight: " .. weight,
    x = (modalBox.width / 2) - 165,
    y = 160,
    fontSize = 40,
    align = "center"
  })
  weightText:setFillColor(0)
  modalGroup:insert(weightText)

  -- Create the Details button
  button1 = widget.newButton(
  {
      label = "Details",
      fontSize = 40,
      onEvent = handleButtonEventDetails,
      emboss = false,
      isEnabled = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 200,
      height = 75,
      cornerRadius = 12,
      fillColor = {default={0.8, 0.8, 0.8}, over={0.8,0.8,0.8}},
      strokeColor = {default={0.8,0.8,0.8}, over={0.8,0.8,0.8}},
      strokeWidth = 4
    }
  )
  -- Center the button
  button1.x = (modalBox.width / -2) + 150
  button1.y = 270
  modalGroup:insert(button1) -- Insert the button

  -- Insert image
  local fishImage = display.newImage("images/fish/" .. fid .. "_large.png", modalBox.contentCenterX, 500)
  modalGroup:insert(fishImage)

  -- Create the close button
  button2 = widget.newButton(
  {
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
    }
  )
  -- Center the button
  button2.x = (modalBox.width / 2) - 150
  button2.y = 270
  modalGroup:insert(button2) -- Insert the button

  -- Update the DB
  db:caughtFish(fid, weight)

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
    parent:resumeGame(false, true)
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