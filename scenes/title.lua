-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local utils = require("utils")
local widget = require("widget")

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local title
local game
local encyclopedia
-- Keeps track of what scene to load based on the users swipe
local sceneToLoad
local slideDirection

-- Go to the game
local function handleButtonEventGame(event)
  if (event.phase == "ended") then
    composer.gotoScene("scenes.locations", {params = {}, effect = "slideLeft", time = 800})
  end
end

-- Go to the encyclopedia
local function handleButtonEventEncyclopedia(event)
  if (event.phase == "ended") then
    composer.gotoScene("scenes.encyclopedia", {effect = "slideUp", time = 800})
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function toggleMusic()
  if (db:getRows("Flags")[1].music == 0) then
    audio.resume({channel = 1})
  else
    audio.pause({channel = 1})
  end
end

-- create()
function scene:create(event)
  local sceneGroup = self.view

  -- Set default background color

  -- New display group
  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  local sheetOptions = {
    width = 540,
    height = 960,
    numFrames = 8
  }

  local waterTextureSheet = graphics.newImageSheet("assets/backgrounds/water_anim.png", sheetOptions)

  local sequenceAnim = {
    {
      name = "stationary",
      start = 1,
      count = 8,
      time = 1600,
      loopDirection = "forward"
    }
  }

  waterTexture = display.newSprite(mainGroup, waterTextureSheet, sequenceAnim)
  waterTexture.anchorX = 0 
  waterTexture.anchorY = 0 
  waterTexture.xScale = 2
  waterTexture.yScale = 2
  waterTexture:setSequence("stationary")
  waterTexture:play()


  background = display.newImage(mainGroup, "assets/backgrounds/title.png")
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local color = {
    highlight = {r = 0, g = 0, b = 0},
    shadow = {r = 0, g = 0, b = 0}
  }

  logo = display.newImage("assets/logo.png", display.contentCenterX, 350)
  mainGroup:insert(logo)


  -- Game
  game =
    widget.newButton(
    {
      width = 300,
      height = 300,
      onEvent = handleButtonEventGame,
      defaultFile = "assets/buttons/playButton.png",
      overFile = "assets/buttons/playButtonPressed.png",
    }
  )
  -- Center the button
  game.x = display.contentCenterX
  game.y = display.contentCenterY + 50
  mainGroup:insert(game)

  encyclopedia =
    widget.newButton(
    {
      width = 300,
      height = 300,
      onEvent = handleButtonEventEncyclopedia,
      defaultFile = "assets/buttons/enc-detail.png",
      overFile = "assets/buttons/enc-detail-pressed.png"
    }
  )
  -- Center the button
  encyclopedia.x = display.contentCenterX
  encyclopedia.y = display.contentCenterY + 450
  mainGroup:insert(encyclopedia)

  local widget = require("widget")

  -- Handle press events for the setting buttons
  local function onSwitchPress(event)
    local switch = event.target
    if (switch.id == "music") then
      toggleMusic()
    elseif (switch.id == "vibrate") then
      if (db:getRows("Flags")[1].vibrate == 0) then
        system.vibrate()
      end
    elseif (switch.id == "sound") then
      if (db:getRows("Flags")[1].sound == 0) then
        local fishBite = audio.loadSound("audio/fish_bite.wav")
        audio.play(fishBite)
      end
    end

    if (switch.isOn) then
      db:update("UPDATE Flags SET " .. switch.id .. " = 0;")
    else
      db:update("UPDATE Flags SET " .. switch.id .. " = 1;")
    end
    db:print()
  end

  local function changeComplete()
    print("Switch change complete!")
  end

  -- Set the on/off switch to off

  -- Image sheet options and declaration
  local options = {
    width = 128,
    height = 128,
    numFrames = 6,
    sheetContentWidth = 384,
    sheetContentHeight = 256
  }
  local settingButtonsSheet = graphics.newImageSheet("assets/buttons/settingsSheet.png", options)
  
  local sound =
    widget.newSwitch(
    {
      left = 25,
      top = display.contentHeight - 170,
      style = "checkbox",
      id = "sound",
      width = 150,
      height = 150,
      initialSwitchState = db:getRows("Flags")[1].sound == 0 and true or false,
      onPress = onSwitchPress,
      sheet = settingButtonsSheet,
      frameOn = 3,
      frameOff = 4
    }
  )
  local music =
    widget.newSwitch(
    {
      left = 195,
      top = display.contentHeight - 170,
      style = "checkbox",
      id = "music",
      width = 150,
      height = 150,
      initialSwitchState = db:getRows("Flags")[1].music == 0 and true or false,
      onPress = onSwitchPress,
      sheet = settingButtonsSheet,
      frameOn = 1,
      frameOff = 2
    }
  )
  local vibrate =
    widget.newSwitch(
    {
      left = 365,
      top = display.contentHeight - 170,
      style = "checkbox",
      id = "vibrate",
      width = 150,
      height = 150,
      initialSwitchState = db:getRows("Flags")[1].vibrate == 0 and true or false,
      onPress = onSwitchPress,
      sheet = settingButtonsSheet,
      frameOn = 5,
      frameOff = 6
    }
  )


  mainGroup:insert(vibrate)
  mainGroup:insert(music)
  mainGroup:insert(sound)
  backgroundMusic = audio.loadStream("audio/backgroundMusic.wav")

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

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
