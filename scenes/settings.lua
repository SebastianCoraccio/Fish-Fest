-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')
local widget = require("widget")
local utils = require("utils")

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local title
local musicText
local musicSwitch
local vibrationText
local vibrationSwitch
local soundEffectsText
local soundEffectsSwitch
local backButton

-- Keeps track of what scene to load based on the users swipe
local sceneToLoad
local slideDirection

-- Handle press events for the checkbox
local function onSwitchPress( event )
  local switch = event.target
  if (switch.isOn) then
    db:update("UPDATE Flags SET " .. switch.id .. " = 0;")
  else
    db:update("UPDATE Flags SET " .. switch.id .. " = 1;")
  end
  db:print()
end

-- Go to title
local function handleButtonEventBack(event)
  if (event.phase == "ended") then
    composer.gotoScene('scenes.title', {effect="slideUp", time=800, params={}})
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
   -- New display group
  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  -- Title text
  title = display.newText({
    text = "Settings",
    x = 150,
    y = 0,
	  fontSize = 50,
    align = "center"
  })
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Back button
  backButton = widget.newButton({
    label = "Back",
    fontSize = 40,
    onEvent = handleButtonEventBack,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 150,
    height = 75,
    cornerRadius = 12,
    labelColor = {default={utils.hexToRGB("#ef4100")}, over={utils.hexToRGB("#00aeef")}},
    fillColor = {default={utils.hexToRGB("#00aeef")}, over={utils.hexToRGB("#ef4100")}},
    strokeColor = {default={0}, over={0}},
    strokeWidth = 3
  })
  -- Center the button
  backButton.x = display.contentWidth - 100
  backButton.y = 0
  mainGroup:insert(backButton)

  -- Music Text
  musicText = display.newText({
    text = "Music: ",
    x = 50,
    y = 200,
    fontSize = 50,
    align = "center"
  })
  musicText.anchorX = 0
  musicText.anchorY = 0
  musicText:setFillColor(0)
  mainGroup:insert(musicText)

  -- Vibration
  -- Text
  vibrationText = display.newText({
    text = "Vibration: ",
    x = 50,
    y = 400,
    fontSize = 50,
    align = "center"
  })
  vibrationText.anchorX = 0
  vibrationText.anchorY = 0
  vibrationText:setFillColor(0)
  mainGroup:insert(vibrationText)

  -- Sound effects
  -- Text
  soundEffectsText = display.newText({
    text = "Sound effects: ",
    x = 50,
    y = 600,
    fontSize = 50,
    align = "center"
  })
  soundEffectsText.anchorX = 0
  soundEffectsText.anchorY = 0
  soundEffectsText:setFillColor(0)
  mainGroup:insert(soundEffectsText)

  -- Music Switch
  isSwitchOn = true
  if (db:getRows("Flags")[1].music == 0) then
    isSwitchOn = false
  end
  musicSwitch = widget.newSwitch({
    left = display.contentWidth - 200,
    top = musicText.y,
    style = "onOff",
    initialSwitchState = isSwitchOn,
    id = "music",
    onPress = onSwitchPress
  })
  musicSwitch.anchorX = 0
  musicSwitch.anchorY = 0
  musicSwitch:scale(2,2)
  mainGroup:insert(musicSwitch)

  -- Soundeffects Switch
  local isSwitchOn = true
  if (db:getRows("Flags")[1].soundEffects == 0) then
    isSwitchOn = false
  end
  soundEffectsSwitch = widget.newSwitch({
    left = display.contentWidth - 200,
    top = soundEffectsText.y,
    style = "onOff",
    initialSwitchState = isSwitchOn,
    id = "soundEffects",
    onPress = onSwitchPress
  })
  soundEffectsSwitch.anchorX = 0
  soundEffectsSwitch.anchorY = 0
  soundEffectsSwitch:scale(2,2)
  mainGroup:insert(soundEffectsSwitch)

  -- Vibration
  -- Switch
  isSwitchOn = true
  if (db:getRows("Flags")[1].vibration == 0) then
    isSwitchOn = false
  end
  vibrationSwitch = widget.newSwitch({
    left = display.contentWidth - 200,
    top = vibrationText.y,
    style = "onOff",
    initialSwitchState = isSwitchOn,
    id = "vibration",
    onPress = onSwitchPress
  })
  vibrationSwitch.anchorX = 0
  vibrationSwitch.anchorY = 0
  vibrationSwitch:scale(2,2)
  mainGroup:insert(vibrationSwitch)
end

-- show()
function scene:show(event)
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