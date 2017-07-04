-- Game Scene
-- Fish appear and the player can cast the rod and try to catch them

-- Require imports
local composer = require("composer")
local newFish = require("classes.fish").create
local newBobber = require("classes.bobber").create
local physics = require("physics")
local newLocation = require("classes.location").create
local newBaitButton = require("classes.baitButton").create

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

-- Images
local background = nil
local water = nil

-- Bobber
local bobber = nil

-- Modal is showing
local modalIsShowing = false

-- Display groups
local backgroundGroup
local mainGroup
local baitButton

-- Current rod upgrade
-- TODO: Decide how much we want to increase the timer per rod upgrade
local rod = db:getRows("StoreItems")[1].currentRodUpgrade * 150

-- Location
local location

-- Table to hold the fish
fishTable = {}

-- Add a new fish
function addFish()
  local fishToAdd = location.giveFish()
  local f = newFish({maxX=display.contentWidth,
                     maxY=display.contentHeight - 150,
                     minX=0,
                     minY=-100,
                     fid=fishToAdd.fid,
                     group=mainGroup,
                     rod=rod})
  table.insert(fishTable, f)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view

  -- Define groups
  backgroundGroup = display.newGroup()
  sceneGroup:insert(backgroundGroup)

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  -- Code here runs when the scene is first created but has not yet appeared on screen
  background = display.newImage(backgroundGroup, "images/backgrounds/bg_sand.png")
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  water = display.newImage(backgroundGroup, "images/backgrounds/bg_water.png")
  water.x = display.contentCenterX
  water.y = display.contentCenterY - 550

  -- Create the bobber
  bobber = newBobber(display.contentCenterX, display.contentCenterY + 500, mainGroup)

  -- Create bait button
  baitButton = newBaitButton(display.contentCenterX + display.contentWidth / 3, display.contentHeight, mainGroup, event.params.location)

  -- Get location
  location = newLocation(event.params.location)

  -- Create the fish
  for i=1,3 do
    addFish()
  end

-- TEST
-- local fishCount = {0,0,0,0,0,0,0,0,0,0,0,0}
-- for i=1,1000000 do
--     local f = location.giveFish()
--     if f.fid == 99 then
--       fishCount[#fishCount] = fishCount[#fishCount] + 1
--     else
--       fishCount[f.fid + 1] = fishCount[f.fid + 1] + 1
--     end
-- end
-- print("\n")
-- for i=1,#fishCount - 1 do
--     print(tostring(fishCount[i]/10000) .. "%\t : " .. fishInfo[i].name)
-- end
-- print(tostring(fishCount[#fishCount]/10000) .. "%\t : " .. fishInfo[#fishInfo].name)
-- END

    -- Add catch event and related listeners
  Runtime:addEventListener("touch", bobber.catch)
  bobber.anim:addEventListener("catchEvent", scene.reelIn)
  baitButton.anim:addEventListener("pauseEvent", pauseGame)
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  local the_fish = nil
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen

    -- Timer to spawn fish throughout
    -- TODO: Finalize time
    self.fishUpdateTimer = timer.performWithDelay(7000, function()
      self:updateFish()
    end, 0 )
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

function scene:updateFish()
  if (modalIsShowing == false) then
    for i = #fishTable, 1, -1 do
      fishTable[i].update()
    end

    -- Check if there is an active bait that needs to increase MAX_FISH
    local maxFishIncrease = 0
    local baits = db:getRows("baitUsages")
    for i=1,#baits do
      if (baits[i].location == location) then
        maxFishIncrease = baits[i].maxFish
        break
      end
    end

    -- Check if adding a fish is needed, and try to do so it yes
    -- TODO: Create an attributes table for each of the locations
    local MAX_FISH = 5 + maxFishIncrease
    local SPAWN_CHANCE = .25

    if #fishTable < MAX_FISH then
      if math.random() < SPAWN_CHANCE then
        addFish()
      end
    end
  end
end

-- Custom function for resuming the game (from pause state)
function scene:resumeGame()
  -- Code to resume game
  modalIsShowing = false
  bobber.setCast()
end

-- Pause the fish spawning and fish movement
function pauseGame()
  modalIsShowing = true
  bobber.setCast()
end

-- Checks if any fish were caught when the bobber was reeling in
function scene:reelIn()


  -- Destroy the fish image objects and remove fish from table
  function removeFish(index)
    -- print(index, #fishTable)
    fishTable[index]:destroy()
    table.remove(fishTable, index)
  end  

  -- Becomes true when a fish is caught and prevents multiple catchs
  fishCaught = false

  for i = #fishTable, 1, -1 do

    local caught = fishTable[i].checkCaught()
    local fid = fishTable[i].fid

    -- The fish is currently biting
    if caught == 2 then

      -- TODO: Check bite timestamp and determine the fish that bit first
      -- If no fish have been caught yet then catch this one
      if not fishCaught then
        fishCaught = true

        -- TODO: Add in animation instead of just hiding the fish
        fishTable[i].anim.alpha = 0
        timer.performWithDelay(250, function()
          -- Show modal
          -- Options table for the overlay scene "modal.lua"
          pauseGame()
          local options = {
              isModal = true,
              effect = "fade",
              time = 400,
              params = {
                  fid = fid
              }
          }
          composer.showOverlay("scenes.modal", options)
        end)

        -- Update DB and remove fish
        db:caughtFish(fid)
        removeFish(i)

        -- A fish has already been caught, so this fish scatters and is removed
      else
        fishTable[i].scatter()
        timer.performWithDelay(500, function()
          removeFish(i)
        end)
      end

      -- The fish was preparing to bite, or already bit
      -- Scatters and is removed
    elseif caught == 1 then
      fishTable[i].scatter()
    --   if (fish) then    * David had this, not sure why. Nil value caused crashed? IDK
      timer.performWithDelay(1000, function()
        removeFish(i)
      end)
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
