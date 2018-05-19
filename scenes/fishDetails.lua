-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")
local fishInfo = require("data.fishInfo")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local pieces of modal
local modalBox
local text
local closeButton
local picture
local description
local numberCaught
local largestCaught
local value

-- Modal group
local modalGroup

-- Local things
local fid
local previousScene
local location
local tutorial

-- Function to change the information about the fish
local function changeInfo()
  text.text = fishInfo[fid].name

  local info
  for i=1, #db:getRows("FishCaught") do
    if (db:getRows("FishCaught")[i].fid == fid) then
      info = db:getRows("FishCaught")[i]
      break
    end
  end
  
  picture:removeSelf()
  
  if (info == nil) then
    numberCaught.text = "Caught: ?"
    largestCaught.text = "Largest: ?"
    value.text = "Value: ?"
    description.text = "?"
    picture = display.newImage("assets/fish/unknown_large.png", 0, -300)
  else
    numberCaught.text = "Caught: " .. info.numberCaught
    largestCaught.text = "Largest: " .. info.largestCaught .. " lbs"
    value.text = "Value: " .. fishInfo[fid].value
    description.text = fishInfo[fid].description
    picture = display.newImage("assets/fish/" .. fid .. "_large.png", 0, -300)
  end

  modalGroup:insert(picture)
end

-- Function to handle close button
local function handleButtonEventClose(event)
  if (event.phase == "ended") then
    if (previousScene == "game") then
      composer.gotoScene("scenes." .. previousScene, {
        params = {location=location, tutorial=tutorial},
        effect="fade", 
        time=400})
    else
      composer.gotoScene("scenes." .. previousScene, {effect="slideRight", time=200})
    end
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
  -- Set fid
  fid = event.params.fid

  -- Set where to go back to
  previousScene = event.params.previousScene

  -- Set location
  location = event.params.location

  -- Set tutorial
  tutorial = db:getRows("Flags")[1].watchedTutorial

  -- Text information
  text = display.newText({
    text = fishInfo[fid].name,
    x = -100,
    y = display.contentHeight / 2 * -1,
	  width = 500,
	  fontSize = 50,
	  align = "left"
  })
  text:setFillColor(0)
  modalGroup:insert(text)

  -- Close button
  closeButton = widget.newButton(
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
  closeButton.x = display.contentWidth / 2 - 150
  closeButton.y = display.contentHeight / 2 * -1
  modalGroup:insert(closeButton) -- Insert the button

  local info
  for i=1, #db:getRows("FishCaught") do
    if (db:getRows("FishCaught")[i].fid == fid) then
      info = db:getRows("FishCaught")[i]
      break
    end
  end

  local numberCaughtText = "?"
  local largestCaughtText = "?"
  local valueText = "?"
  local descriptionText = "?"
  if (info) then
    numberCaughtText = info.numberCaught
    largestCaught = info.largestCaught
    value = fishInfo[fid].value
    descriptionText = fishInfo[fid].description

    -- Picture
    picture = display.newImage("assets/fish/" .. fid .. "_large.png", 0, -300)
    modalGroup:insert(picture)
  else 
    -- Picture
    picture = display.newImage("assets/fish/unknown_large.png", 0, -300)
    modalGroup:insert(picture)
  end
  
  -- Description
  description = display.newText({
    text = descriptionText,
    x = 0,
    y = -100,
    width = display.contentWidth - 100,
    fontSize = 40,
    align = "center"
  })
  description:setFillColor(0)
  modalGroup:insert(description)

  -- Number caught
  numberCaught = display.newText({
    text = "Caught: " .. numberCaughtText,
    x = -330,
    y = 0,
    fontSize = 40,
  })
  numberCaught.anchorX = 0
  numberCaught:setFillColor(0)
  modalGroup:insert(numberCaught)

  -- Largest caught
  largestCaught = display.newText({
    text = "Largest: " .. largestCaughtText .. " lbs",
    x = -330,
    y = 100,
    fontSize = 40,
  })
  largestCaught.anchorX = 0
  largestCaught:setFillColor(0)
  modalGroup:insert(largestCaught)

  -- Value
  value = display.newText({
    text = valueText,
    x = -330,
    y = 200,
    fontSize = 40,
  })
  value.anchorX = 0
  value:setFillColor(0)
  modalGroup:insert(value)

  -- Place the group
	modalGroup.x = display.contentWidth / 2
	modalGroup.y = display.contentHeight / 2
end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    fid = event.params.fid
    previousScene = event.params.previousScene
    location = event.params.location
    tutorial = db:getRows("Flags")[1].watchedTutorial
    changeInfo()
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