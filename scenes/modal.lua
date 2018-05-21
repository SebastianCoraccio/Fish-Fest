-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local fishInfo = require("data.fishInfo")
local levelInfo = require("data.levelInfo")
local widget = require("widget")
local utils = require("utils")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local pieces of modal
local modalGroup
local modalBox
local msgText
local button1
local button2
local valueText
local fishImage
local weightText

local fid
local location
local tutorial

-- Function to handle details button
-- TODO: Open encylopedia with that fish
local function handleButtonEventDetails(event)
  if (event.phase == "ended") then
    composer.gotoScene(
      "scenes.fishDetails",
      {
        params = {fid = fid, previousScene = "game", location = location, tutorial = tutorial},
        effect = "fade",
        time = 400
      }
    )
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
  modalBox = display.newRoundedRect(0, 0, display.contentWidth / 1.25, display.contentHeight / 1.5, 12)
  modalBox:setFillColor(utils.hexToRGB("#dbc397"))
  modalBox:setStrokeColor(utils.hexToRGB("#000000"))
  modalBox.strokeWidth = 4
  modalGroup:insert(modalBox)

  fid = event.params.fid
  location = event.params.location
  tutorial = event.params.tutorial

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

  local expBeep = audio.loadSound("audio/expBeep.wav")


  local currentExp = db:getRows("Stats")[1].exp
  local nextLevel = levelInfo[db:getRows("Stats")[1].level].cost
  local sliderPercentage = currentExp / nextLevel * 100

  -- Options for primary text
  -- Check if first letter is vowell
  local firstLetter = string.sub(string.lower(fishName), 1, 1)
  local a = "a "
  if
    (firstLetter == "a") or (firstLetter == "e") or (firstLetter == "i") or (firstLetter == "o") or (firstLetter == "u")
   then
    a = "an "
  end
  local options = {
    text = "You caught " .. a,
    y = -570,
    width = 500,
    fontSize = 64,
    font = "LilitaOne-Regular.ttf",
    align = "center"
  }
  youCaughtText = display.newText(options)
  youCaughtText:setFillColor(0)
  modalGroup:insert(youCaughtText)

  local options = {
    text = fishName,
    y = -390,
    width = 700,
    fontSize = 128,
    font = "LilitaOne-Regular.ttf",
    align = "center"
  }
  fishNameText = display.newText(options)
  fishNameText:setFillColor(0)
  modalGroup:insert(fishNameText)

  -- Value and weight text
  local valueOptions = {
    text = "Exp. Points: " .. value,
    y = 240,
    x = -130,
    fontSize = 64,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  valueText = display.newText(valueOptions)
  valueText:setFillColor(0)
  modalGroup:insert(valueText)

  -- Calculate weight
  local one = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
  local two = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
  local three = math.random(fishInfo[fid].minSize, fishInfo[fid].maxSize)
  local weight = math.round(((one + two + three) / 3.0) * 100) * 0.01

  -- Create the Details button
  button1 =
    widget.newButton(
    {
      x = (modalBox.width / -2) + 735,
      y = 240,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/enc-detail.png",
      overFile = "assets/buttons/enc-detail-pressed.png",
      onEvent = handleButtonEventDetails
    }
  )
  -- Center the button
  -- button1.x = (modalBox.width / -2) + 700
  -- button1.y = 240
  modalGroup:insert(button1) -- Insert the button

  -- Insert plaque
  local plaque = display.newImage("assets/plaque.png", modalBox.contentCenterX, 700)
  plaque.y = -30
  modalGroup:insert(plaque)

  -- Insert image
  local fishImage = display.newImage("assets/fish/" .. fid .. "_large.png", modalBox.contentCenterX, 100)
  fishImage.y = -40
  modalGroup:insert(fishImage)

  -- Back button
  backButton =
    widget.newButton(
    {
      x = 370,
      y = -580,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/close-button.png",
      overFile = "assets/buttons/close-button-pressed.png",
      onEvent = handleButtonEventClose
    }
  )

  modalGroup:insert(backButton)

  local options = {
    frames = {
      {x = 0, y = 0, width = 100, height = 140},
      {x = 100, y = 0, width = 100, height = 140},
      {x = 200, y = 0, width = 100, height = 140},
      {x = 300, y = 0, width = 100, height = 140},
      {x = 400, y = 0, width = 20, height = 140}
    },
    sheetContentWidth = 420,
    sheetContentHeight = 140
  }
  local sliderSheet = graphics.newImageSheet("assets/buttons/expSlider.png", options)

  -- Create the widget
  local slider =
    widget.newSlider(
    {
      sheet = sliderSheet,
      leftFrame = 1,
      middleFrame = 2,
      rightFrame = 3,
      fillFrame = 4,
      frameWidth = 100,
      frameHeight = 120,
      handleFrame = 5,
      handleWidth = 20,
      handleHeight = 120,
      x = 10,
      y = 450,
      width = modalBox.width,
      listener = sliderListener,
      value = sliderPercentage
    }
  )
  modalGroup:insert(slider)

  local function updateSlider(value)
    for i = 0,value,10 do
      timer.performWithDelay(5 * i, function()
        audio.play(expBeep)
        currentExp = currentExp + 10
        slider:setValue(currentExp / nextLevel * 100)
      end)
    end
  end

  local options = {
    text = "Level " .. db:getRows("Stats")[1].level,
    y = 350,
    x = 0,
    width = 700,
    fontSize = 64,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  level = display.newText(options)
  level:setFillColor(0)
  modalGroup:insert(level)

  local options = {
    text = "Current Exp:\n" .. currentExp + value,
    y = 565,
    x = 0,
    width = 700,
    fontSize = 48,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  currentExpText = display.newText(options)
  currentExpText:setFillColor(0)
  modalGroup:insert(currentExpText)

  local options = {
    text = "Next Level In:\n" .. nextLevel - currentExp - value,
    y = 565,
    x = 420,
    width = 700,
    fontSize = 48,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  next = display.newText(options)
  next:setFillColor(0)
  modalGroup:insert(next)

  updateSlider(value)
  -- Update the DB
  db:caughtFish(fid, weight, value)

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
    parent:resumeGame(false, true)
  elseif (phase == "did") then
  -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy(event)
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
