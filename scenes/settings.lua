-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')
local widget = require("widget")

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local title
local vibrationText
local vibrationSwitch
local soundEffectsText
local soundEffectsSwitch

-- Keeps track of what scene to load based on the users swipe
local sceneToLoad
local slideDirection

-- Function to detect which way the user swiped
-- Loads corresponding 
local function handleSwipeEvent(event)
  if (event.phase == "moved") then
    local dX = event.x - event.xStart
    local dY = event.y - event.yStart
    if (dY < -200) then
      --swipe up
      sceneToLoad = 'title'
      slideDirection = "Up"
    end
  end

  if (event.phase == "ended") then
    -- Temporary if
    if (sceneToLoad == "title") then
      composer.gotoScene('scenes.' .. sceneToLoad, {effect="slide" .. slideDirection, time=800, params={}})
    end
  end
end

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
    x = 50,
    y = 0,
	  fontSize = 50,
    align = "center"
  })
  title.anchorX = 0
  title.anchorY = 0
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Vibration
  -- Text
  vibrationText = display.newText({
    text = "Vibration: ",
    x = 50,
    y = 200,
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
    y = 400,
    fontSize = 50,
    align = "center"
  })
  soundEffectsText.anchorX = 0
  soundEffectsText.anchorY = 0
  soundEffectsText:setFillColor(0)
  mainGroup:insert(soundEffectsText)

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
    -- Swipe event
    -- Check if tutorial and returning from store

    -- Set tutorial from
    Runtime:addEventListener("touch", handleSwipeEvent)
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    Runtime:removeEventListener("touch", handleSwipeEvent)
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