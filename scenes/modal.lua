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
local valueText
local fishImage

-- Level objects
local expSlider
local currentLevelText
local currentExpText
local nextExpText

local sliderAnimating = false
local fid
local location

local currentExp
local nextLevel
local expBeep = audio.loadSound("audio/expBeep.wav")
local levelUpSound = audio.loadSound("audio/levelUp.wav")


-- Function to handle details button
-- TODO: Open encylopedia with that fish
local function handleButtonEventDetails(event)
    -- Don't navigate if the slider is animating, will throw an error when the scene changes
  if (not sliderAnimating) then
    if (event.phase == "ended") then
      composer.gotoScene(
        "scenes.fishDetails",
        {
          params = {fid = fid, previousScene = "game", location = location},
          effect = "fade",
          time = 400
        }
      )
    end
  end
end

-- Function to handle close button
local function handleButtonEventClose(event)
  -- Don't navigate if the slider is animating, will throw an error when the scene changes
  if (not sliderAnimating) then
    if (event.phase == "ended") then
      composer.hideOverlay(true, "fade", 400)
    end
  end
end

function levelUp(remainingValue)

  if (db:getRows("Flags")[1].sound == 1) then
    audio.play(levelUpSound)
  end

  local level = db:getRows("Stats")[1].level + 1
  db:updateLevel(level, remainingValue)

  nextLevel = levelInfo[db:getRows("Stats")[1].level].cost
  currentExp = remainingValue

  -- remove and re-add level information to reset the display
  removeLevelInformation()
  createLevelInformation()

  updateSlider(remainingValue)
end

function updateSlider(value)
  -- Wait for the slider to complete updating, then flip the animating flag
  sliderAnimating = true
  timer.performWithDelay(
    5 * value,
    function() 
      sliderAnimating = false
    end
  )

  currentExp = currentExp - value
  for i = 0, value, 10 do
    if (currentExp + i >= nextLevel) then
      timer.performWithDelay(
        5 * i,
        function()
          value = value - i
          levelUp(value)
        end
      )
      return
    else
      timer.performWithDelay(
        5 * i,
        function()
          if (db:getRows("Flags")[1].sound == 1) then
            audio.play(expBeep)
          end
          currentExp = currentExp + 10
          expSlider:setValue(currentExp / nextLevel * 100)
        end
      )
    end
  end
end

function removeLevelInformation()
  expSlider:removeSelf()
  currentLevel:removeSelf()
  currentExpText:removeSelf()
  nextExpText:removeSelf()
end

function createLevelInformation()
  local nextLevel = levelInfo[db:getRows("Stats")[1].level].cost
  local sliderPercentage = (currentExp - value) / nextLevel * 100

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
  expSlider =
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
      x = 0,
      y = 450,
      width = modalBox.width,
      listener = sliderListener,
      value = sliderPercentage
    }
  )
  modalGroup:insert(expSlider)

  local options = {
    text = "Level " .. db:getRows("Stats")[1].level,
    y = 350,
    x = 0,
    width = 700,
    fontSize = 64,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  currentLevel = display.newText(options)
  currentLevel:setFillColor(0)
  modalGroup:insert(currentLevel)

  local options = {
    text = "Current Exp:\n" .. currentExp,
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

  local expToNext = (nextLevel - currentExp) > 0 and (nextLevel - currentExp) or 0
  local options = {
    text = "Next Level In:\n" .. expToNext,
    y = 565,
    x = 420,
    width = 700,
    fontSize = 48,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  nextExpText = display.newText(options)
  nextExpText:setFillColor(0)
  modalGroup:insert(nextExpText)
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

  fishName = fishInfo[fid].name
  value = fishInfo[fid].value

  currentExp = db:getRows("Stats")[1].exp + value
  nextLevel = levelInfo[db:getRows("Stats")[1].level].cost

  -- Options for primary text
  -- Check if first letter is vowell
  aOrAn = utils.beginsWithVowel(fishName) and "an" or "a"
  options = {
    text = "You caught " .. aOrAn,
    y = -570,
    width = 500,
    fontSize = 64,
    font = "LilitaOne-Regular.ttf",
    align = "center"
  }
  youCaughtText = display.newText(options)
  youCaughtText:setFillColor(0)
  modalGroup:insert(youCaughtText)

  options = {
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

  options = {
    text = "Exp. Points: " .. value,
    y = 240,
    x = -130,
    fontSize = 64,
    font = "LilitaOne-Regular.ttf",
    align = "left"
  }
  valueText = display.newText(options)
  valueText:setFillColor(0)
  modalGroup:insert(valueText)

  detailsButton =
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
  modalGroup:insert(detailsButton)

  plaque = display.newImage("assets/plaque.png", modalBox.contentCenterX, 700)
  plaque.y = -30
  modalGroup:insert(plaque)

  fishImage = display.newImage("assets/fish/" .. fid .. "_large.png", modalBox.contentCenterX, 100)
  fishImage.y = -40
  modalGroup:insert(fishImage)

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
  
  createLevelInformation()
  -- Place the group
  modalGroup.x = display.contentWidth / 2
  modalGroup.y = display.contentHeight / 2

  -- Update the slider after waiting a moment for the modal to open
  sliderAnimating = true
  timer.performWithDelay(
    700,
    function()
      updateSlider(value)
    end
  )
  db:caughtFish(fid, 0, value)

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

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
-- -----------------------------------------------------------------------------------

return scene
