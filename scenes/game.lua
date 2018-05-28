-- Game Scene
-- Fish appear and the player can cast the rod and try to catch them

-- Require imports
local composer = require("composer")
local newFish = require("classes.fish").create
local newBobber = require("classes.bobber").create
local physics = require("physics")
local newLocation = require("classes.location").create
local widget = require("widget")
local utils = require("utils")

-- Fish info
local fishInfo = require("data.fishInfo")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Start the physics with no gravity
-- physics.setDrawMode( "hybrid" )
physics.start()
physics.setGravity(0, 0)

-- This scene
local scene = composer.newScene()

-- assets
local background = nil
local water = nil

-- Bobber
local bobber = nil

-- Modal is showing
local modalIsShowing = false

-- Display groups
local backgroundGroup
local mainGroup
local uiGroup

local preCast = false
local preCatch = false
local postCatch = false
local spawnedInitialFish = false

-- Location
local location
local locationName

-- Table to hold the fish
fishTable = {}

-- Update timer
local fishUpdateTimer

-- Add a new fish
function addFish()
  local fishToAdd = location.giveFish()
  local f =
    newFish(
    {
      maxX = display.contentWidth,
      maxY = display.contentHeight - 150,
      minX = 0,
      minY = -100,
      fid = fishToAdd.fid,
      group = mainGroup
    }
  )
  uiGroup:toFront()
  table.insert(fishTable, f)
end

-- Back button
local function handleButtonEventBack(event)
  bobber.bringBack()
  if (event.phase == "ended") then
    composer.gotoScene("scenes.locations", {params = {}, effect = "slideRight", time = 600})
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  locationName = event.params.location
  -- Define groups
  backgroundGroup = display.newGroup()
  sceneGroup:insert(backgroundGroup)

  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  water = display.newImage(backgroundGroup, "assets/backgrounds/bg_" .. locationName .. ".png")
  water.x = display.contentCenterX
  water.y = display.contentCenterY - 550

  local sheetOptions = {
    width = 540,
    height = 960,
    numFrames = 8
  }

  local sheetFishAnim = graphics.newImageSheet("assets/backgrounds/water_anim.png", sheetOptions)

  local sequenceAnim = {
    {
      name = "stationary",
      start = 1,
      count = 8,
      time = 1600,
      loopDirection = "forward"
    }
  }

  texture = display.newSprite(mainGroup, sheetFishAnim, sequenceAnim)
  texture.anchorX = 0 
  texture.anchorY = 0 
  texture.xScale = 2
  texture.yScale = 2
  texture:setSequence("stationary")
  texture:play()

  -- Create the bobber
  bobber = newBobber(display.contentCenterX, display.contentHeight - 100 , uiGroup)

  -- Get location
  location = newLocation(event.params.location)

  -- Create back button
  backButton =
    widget.newButton(
    {
      x = 90,
      y = 90,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/back-button.png",
      overFile = "assets/buttons/back-button-pressed.png",
      onEvent = handleButtonEventBack,
    }
  )

  uiGroup:insert(backButton) -- Insert the button

  -- Create the fish
  for i = 1, 3 do
    addFish()
  end
  spawnedInitialFish = true

  -- Add catch event and related listeners
  Runtime:addEventListener("touch", bobber.catch)
  bobber.anim:addEventListener("catchEvent", scene.reelIn)
end

-- Pause the fish spawning and fish movement
function pauseGame()
  modalIsShowing = true
  bobber.setCast()
end

-- Custom function for resuming the game (from pause state)
function scene:resumeGame(final)
  modalIsShowing = false
  bobber.setCast()
end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  local the_fish = nil

  if (phase == "will") then
    -- Code here runs when the scene is first created but has not yet appeared on screen
    locationName = event.params.location

    water = display.newImage(backgroundGroup, "assets/backgrounds/bg_" .. locationName .. ".png")
    water.anchorX = 0
    water.anchorY = 0

    bobber:caught()
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    location = newLocation(event.params.location)

    -- Timer to spawn fish throughout
    -- TODO: Finalize time
    fishUpdateTimer =
      timer.performWithDelay(
      6500,
      function()
        self:updateFish()
      end,
      0
    )

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
    bobber:noCast()
    timer.cancel(fishUpdateTimer)
    -- Destroy the fish image objects and remove fish from table
    function removeFish(index)
      if (fishTable[index]) then
        fishTable[index]:destroy()
        table.remove(fishTable, index)
      else
        print("This is an error. We should fix this")
      end
    end

    if (spawnedInitialFish == false) then
      for i = #fishTable, 1, -1 do
        removeFish(i)
      end
      spawnedInitialFish = false
    end
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs prior to the removal of scene's view
  elseif (phase == "did") then
  -- Code here runs after scene is removed
  end
end

function scene:updateFish()
  if (modalIsShowing == false) then
    for i = #fishTable, 1, -1 do
      fishTable[i].update()
    end

    -- Check if adding a fish is needed, and try to do so it yes
    -- TODO: Create an attributes table for each of the locations
    local MAX_FISH = 5
    local SPAWN_CHANCE = 0.25
    if (#fishTable == 0) then
      SPAWN_CHANCE = 1
    end

    if #fishTable < MAX_FISH then
      if math.random() < SPAWN_CHANCE then
        addFish()
      end
    end
  end
end

-- Checks if any fish were caught when the bobber was reeling in
function scene:reelIn()
  -- Destroy the fish image objects and remove fish from table
  function removeFish(index)
    if (fishTable[index]) then
      fishTable[index]:destroy()
      table.remove(fishTable, index)
    else
      print("This is an error. We should fix this")
    end
  end

  -- Becomes true when a fish is caught and prevents multiple catchs
  fishCaught = false

  for i = #fishTable, 1, -1 do
    local caught = fishTable[i].checkCaught()
    local fid = fishTable[i].fid

    -- The fish is currently biting
    if caught == 2 then
      -- The fish was preparing to bite, or already bit
      -- Scatters and is removed
      -- TODO: Check bite timestamp and determine the fish that bit first
      -- If no fish have been caught yet then catch this one
      if not fishCaught then
        -- A fish has already been caught, so this fish scatters and is removed
        fishCaught = true

        -- TODO: Add in animation instead of just hiding the fish
        fishTable[i].anim.alpha = 0
        timer.performWithDelay(
          250,
          function()
            -- Show modal
            -- Options table for the overlay scene "modal.lua"
            pauseGame()
            local options = {
              isModal = true,
              effect = "fade",
              time = 400,
              params = {
                fid = fid,
                location = locationName
              }
            }
            composer.showOverlay("scenes.modal", options)
          end
        )

        -- Update DB and remove fish
        -- db:caughtFish(fid)
        removeFish(i)
      else
        fishTable[i].scatter()
        timer.performWithDelay(
          500,
          function()
            removeFish(i)
          end
        )
      end
    elseif caught == 1 then
      fishTable[i].scatter()
      --   if (fish) then    * David had this, not sure why. Nil value caused crashed? IDK
      timer.performWithDelay(
        1000,
        function()
          removeFish(i)
        end
      )
    end
  end
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
