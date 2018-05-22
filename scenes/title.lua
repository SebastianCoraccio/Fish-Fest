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

  background = display.newImage(mainGroup, "assets/backgrounds/title.png")
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local color = {
    highlight = {r = 0, g = 0, b = 0},
    shadow = {r = 0, g = 0, b = 0}
  }

  -- Title text
  local options = {
    text = "Fishing\nFest",
    x = display.contentCenterX,
    y = 600,
    fontSize = 75,
    align = "center"
  }
  title = display.newEmbossedText(options)
  title:setFillColor(1)
  title:setEmbossColor(color)
  mainGroup:insert(title)

  -- Game
  game =
    widget.newButton(
    {
      label = "Travel",
      fontSize = 40,
      onEvent = handleButtonEventGame,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 150,
      height = 75,
      cornerRadius = 12,
      labelColor = {default = {utils.hexToRGB("#ef4100")}, over = {utils.hexToRGB("#00aeef")}},
      fillColor = {default = {utils.hexToRGB("#00aeef")}, over = {utils.hexToRGB("#ef4100")}},
      strokeColor = {default = {0}, over = {0}},
      strokeWidth = 3
    }
  )
  -- Center the button
  game.x = display.contentCenterX + 200
  game.y = display.contentCenterY
  mainGroup:insert(game)

  encyclopedia =
    widget.newButton(
    {
      label = "Encyclopedia",
      fontSize = 40,
      onEvent = handleButtonEventEncyclopedia,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 275,
      height = 100,
      cornerRadius = 12,
      labelColor = {default = {utils.hexToRGB("#ef4100")}, over = {utils.hexToRGB("#00aeef")}},
      fillColor = {default = {utils.hexToRGB("#00aeef")}, over = {utils.hexToRGB("#ef4100")}},
      strokeColor = {default = {0}, over = {0}},
      strokeWidth = 3
    }
  )
  -- Center the button
  encyclopedia.x = display.contentCenterX
  encyclopedia.y = display.contentCenterY + 150
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

  local vibrate =
    widget.newSwitch(
    {
      left = 306,
      top = display.contentHeight - 150,
      style = "checkbox",
      id = "vibrate",
      width = 100,
      height = 100,
      initialSwitchState = db:getRows("Flags")[1].vibrate == 0 and true or false,
      onPress = onSwitchPress,
      sheet = settingButtonsSheet,
      frameOn = 5,
      frameOff = 6
    }
  )
  local music =
    widget.newSwitch(
    {
      left = 178,
      top = display.contentHeight - 150,
      style = "checkbox",
      id = "music",
      width = 100,
      height = 100,
      initialSwitchState = db:getRows("Flags")[1].music == 0 and true or false,
      onPress = onSwitchPress,
      sheet = settingButtonsSheet,
      frameOn = 1,
      frameOff = 2
    }
  )

  local sound =
    widget.newSwitch(
    {
      left = 50,
      top = display.contentHeight - 150,
      style = "checkbox",
      id = "sound",
      width = 100,
      height = 100,
      initialSwitchState = db:getRows("Flags")[1].sound == 0 and true or false,
      onPress = onSwitchPress,
      sheet = settingButtonsSheet,
      frameOn = 3,
      frameOff = 4
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
