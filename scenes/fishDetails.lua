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
local fishNameText
local numberCaught
local largestCaught
local valueText
local value

-- Modal group
local modalGroup

-- Local things
local fid
local previousScene
local location

local function drawFish(info)
  if (picture) then
    picture:removeSelf()
  end

  if (info == nil) then
    picture = display.newImage("assets/fish/unknown_large.png", 0, 0)
  else
    picture = display.newImage("assets/fish/" .. fid .. "_large.png", 0, 0)
  end

  picture.y = -200
  picture.xScale = 1.25
  picture.yScale = 1.25
  modalGroup:insert(picture)
end

-- Function to change the information about the fish
local function changeInfo()

  local info
  for i = 1, #db:getRows("FishCaught") do
    if (db:getRows("FishCaught")[i].fid == fid) then
      info = db:getRows("FishCaught")[i]
      break
    end
  end

  local name = "?"
  local numberCaughtText = "0"
  local value = "?"
  local descriptionText = "?"
  if (info) then
    name = fishInfo[fid].name
    numberCaughtText = info.numberCaught
    value = fishInfo[fid].value
    descriptionText = fishInfo[fid].description
  end


  if (description) then
    fishNameText:removeSelf()
    description:removeSelf()
    numberCaught:removeSelf()
    valueText:removeSelf()
  end

  fishNameText =
    display.newText(
    {
      text = name,
      y = -600,
      width = 700,
      fontSize = 128,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  fishNameText:setFillColor(0)
  modalGroup:insert(fishNameText)

  description =
    display.newText(
    {
      text = descriptionText,
      x = 0,
      y = 220,
      width = display.contentWidth - 100,
      fontSize = 48,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  description:setFillColor(0)
  modalGroup:insert(description)

  valueText =
    display.newText(
    {
      text = "Exp. Points: " .. value,
      x = -430,
      y = 640,
      fontSize = 64,
      font = "LilitaOne-Regular.ttf"
    }
  )
  valueText.anchorX = 0
  valueText:setFillColor(0)
  modalGroup:insert(valueText)
  
  numberCaught =
    display.newText(
    {
      text = "Number Caught: " .. numberCaughtText,
      x = -430,
      y = 750,
      fontSize = 64,
      font = "LilitaOne-Regular.ttf"
    }
  )
  numberCaught.anchorX = 0
  numberCaught:setFillColor(0)
  modalGroup:insert(numberCaught)


  drawFish(info)
end

-- Function to handle close button
local function handleButtonEventClose(event)
  if (event.phase == "ended") then
    if (previousScene == "game") then
      composer.gotoScene(
        "scenes." .. previousScene,
        {
          params = {location = location},
          effect = "fade",
          time = 400
        }
      )
    else
      composer.gotoScene("scenes." .. previousScene, {effect = "slideRight", time = 200})
    end
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  fid = event.params.fid
  previousScene = event.params.previousScene
  location = event.params.location

  -- Scrolling Background
  bgGroup1 = display.newGroup()
  bgGroup2 = display.newGroup()
  sceneGroup:insert(bgGroup2)
  sceneGroup:insert(bgGroup1)

  bgGroup1 = display.newImage(bgGroup1, "assets/backgrounds/enc_background.png")
  bgGroup1.anchorX = 0
  bgGroup1.anchorY = 0
  bgGroup1.y = display.contentHeight / 2

  bgGroup2 = display.newImage(bgGroup2, "assets/backgrounds/enc_background.png")
  bgGroup2.anchorX = 0
  bgGroup2.anchorY = 0
  bgGroup2.y = -display.contentHeight / 2

  -- Fish information components
  modalGroup = display.newGroup()
  sceneGroup:insert(modalGroup)

  descriptionBox = display.newRoundedRect(0, -250, display.contentWidth / 1.1, display.contentHeight / 1.5, 12)
  descriptionBox:setFillColor(utils.hexToRGB("#dbc397"))
  descriptionBox:setStrokeColor(utils.hexToRGB("#000000"))
  descriptionBox.strokeWidth = 4
  modalGroup:insert(descriptionBox)

  statBox = display.newRoundedRect(0, 650, display.contentWidth / 1.1, display.contentHeight / 5, 12)
  statBox:setFillColor(utils.hexToRGB("#dbc397"))
  statBox:setStrokeColor(utils.hexToRGB("#000000"))
  statBox.strokeWidth = 4
  modalGroup:insert(statBox)

  pageTitle =
    display.newText(
    {
      text = "Fish Detail",
      x = -245,
      y = -825,
      width = 700,
      fontSize = 100,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  pageTitle:setFillColor(0)
  modalGroup:insert(pageTitle)

  statsText =
    display.newText(
    {
      text = "Stats",
      x = -350,
      y = 520,
      width = 700,
      fontSize = 100,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  statsText:setFillColor(0)
  modalGroup:insert(statsText)

  backButton =
    widget.newButton(
    {
      x = 430,
      y = -830,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/close-button.png",
      overFile = "assets/buttons/close-button-pressed.png",
      onEvent = handleButtonEventClose
    }
  )
  modalGroup:insert(backButton)

  plaque = display.newImage("assets/plaque.png", modalGroup.contentCenterX)
  plaque.xScale = 1.25
  plaque.yScale = 1.25
  plaque.y = -180
  modalGroup:insert(plaque)

  changeInfo()

  -- Place the group
  modalGroup.x = display.contentWidth / 2
  modalGroup.y = display.contentHeight / 2

end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    fid = event.params.fid
    previousScene = event.params.previousScene
    location = event.params.location
    changeInfo()
  elseif (phase == "did") then
  -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent -- Reference to the parent scene object

  if (phase == "will") then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif (phase == "did") then
  -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

local function moveBG(event)
  -- xOffset = 3
  yOffset = 3

  if (bgGroup1.y + yOffset) > display.contentHeight then
    bgGroup1.y = -display.contentHeight + yOffset
  else
    bgGroup1.y = bgGroup1.y + yOffset
  end

  if (bgGroup2.y + yOffset) > display.contentHeight then
    bgGroup2.y = -display.contentHeight + yOffset
  else
    bgGroup2.y = bgGroup2.y + yOffset
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

Runtime:addEventListener("enterFrame", moveBG)

-- -----------------------------------------------------------------------------------

return scene
