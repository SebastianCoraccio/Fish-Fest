-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local title
local game
local store

-- Keeps track of what scene to load based on the users swipe
local sceneToLoad
local slideDirection

-- if this is true, tutorial mode engaged
local tutorial = false
local tutorialStore = false
local tutorialFrom = ""

-- Custom function for resuming the game (from pause state)
function scene:resumeGame(tutorial2)
  if (tutorial2) then
    if (tutorialFrom == "store") then
      tutorialStore = true
      tutorial = false
    else
      -- Code to resume game
      tutorial = true
    end
  end
end

-- Function to detect which way the user swiped
-- Loads corresponding 
local function handleSwipeEvent(event)
  if (event.phase == "moved") then
    local dX = event.x - event.xStart
    local dY = event.y - event.yStart
    if (dX > 200) then
      --swipe right
      sceneToLoad = 'store'
      slideDirection = 'Right'
    elseif (dX < -200) then
      --swipe left
      sceneToLoad = 'game'
      slideDirection = 'Left'
    elseif (dY > 200) then
      --swipe down
      sceneToLoad = 'up'
      slideDirection = "Top"
    elseif (dY < -200) then
      --swipe up
      sceneToLoad = 'down'
      slideDirection = "Bottom"
    end
  end

  if (event.phase == "ended") then
    -- Temporary if
    if (sceneToLoad == "game") and (tutorial == false) or (db:getRows("Flags")[1].watchedTutorial == 1) then 
      -- Decide if we want to use slide or from effect
      composer.gotoScene('scenes.' .. sceneToLoad, {params = {location='river', tutorial=tutorialStore}, effect="slide" .. slideDirection, time=800})
    elseif (sceneToLoad == "store") and (tutorialStore == false) then
      composer.gotoScene('scenes.' .. sceneToLoad, {effect="slide" .. slideDirection, time=800, params={tutorial=tutorial}})
    end
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
  local options = {
    text = "TNAC",
    x = display.contentCenterX,
    y = display.contentCenterY,
	  fontSize = 50,
    align = "center"
  }
  title = display.newText(options)
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Game
  options = {
    text = "Game",
    x = display.contentWidth - 100,
    y = display.contentCenterY,
    fontSize = 50,
    align = "center"
  }
  game = display.newText(options)
  game:setFillColor(0)
  mainGroup:insert(game)

  -- Store
  options = {
    text = "Store",
    x = 100,
    y = display.contentCenterY,
    fontSize = 50,
    align = "center"
  }
  store = display.newText(options)
  store:setFillColor(0)
  mainGroup:insert(store)

  -- Check if tutorial needs to be shown
  if (db:getRows("Flags")[1].watchedTutorial == 0) then
    composer.showOverlay("scenes.tutorialModal", {params = {text = 
      [[Welcome to TNAC! This is the title screen. To move from menu to menu, swipe in said direction. 
Hit next to try going to the store.]]}, 
      effect="fade", time=800})
  end
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
    tutorialFrom = event.params.tutorial
    if (tutorialFrom == "store") then
      composer.showOverlay("scenes.tutorialModal", {params = {text = 
      [[Lets move onto gameplay.
Hit next to try and swipe to the game.]]},
      effect="fade", time=800})
    end
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