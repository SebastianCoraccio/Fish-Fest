-- Game Scene
-- Fish appear and the player can cast the rod and try to catch them

-- Require imports
local composer = require("composer")
local newFish = require("classes.fish").create
local newBobber = require("classes.bobber").create
local physics = require("physics")
local newLocation = require("classes.location").create
local newBaitButton = require("classes.baitButton").create
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
local uiGroup
local baitButton
local backButton
-- tutorial
local tutorial = false
local preCast = false
local preCatch = false
local postCatch = false
local spawnedInitialFish = false

-- Location
local location

-- Table to hold the fish
fishTable = {}

-- Update timer
local fishUpdateTimer

-- Add a new fish
function addFish()
  local fishToAdd = location.giveFish()
  local f = newFish({maxX=display.contentWidth,
                     maxY=display.contentHeight - 150,
                     minX=0,
                     minY=-100,
                     fid=fishToAdd.fid,
                     group=mainGroup})
  uiGroup:toFront()
  table.insert(fishTable, f)
end

-- Back button
local function handleButtonEventBack(event)
  if (event.phase == "ended") and (db:getRows("Flags")[1].watchedTutorial == 1) then
    -- TODO: Change to location page when implemeneted
    -- composer.removeScene('scenes.game')
    composer.gotoScene('scenes.locations', {params = {}, effect="slideRight", time=600})
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  local locationName = event.params.location
  -- Define groups
  backgroundGroup = display.newGroup()
  sceneGroup:insert(backgroundGroup)

  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  -- Code here runs when the scene is first created but has not yet appeared on screen
  background = display.newImage(backgroundGroup, "images/backgrounds/bg_sand.png")
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  water = display.newImage(backgroundGroup, "images/backgrounds/bg_" .. locationName .. ".png")
  water.x = display.contentCenterX
  water.y = display.contentCenterY - 550

  -- Create the bobber
  bobber = newBobber(display.contentCenterX, display.contentCenterY + 500, uiGroup)

  -- Create bait button
  baitButton = newBaitButton(display.contentCenterX + display.contentWidth / 3, display.contentHeight, uiGroup, event.params.location)

  -- Get location
  location = newLocation(event.params.location)

  -- Create back button
  backButton = widget.newButton(
  {
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
  backButton.x = display.contentCenterX - display.contentWidth / 3
  backButton.y = display.contentHeight
  uiGroup:insert(backButton) -- Insert the button

  -- Create the fish
  if (db:getRows("Flags")[1].watchedTutorial == 1) then
    for i=1,3 do
      addFish()
    end
    spawnedInitialFish = true
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

  -- Check if tutorial is going on
  tutorial = event.params.tutorial

  -- Add catch event and related listeners
  Runtime:addEventListener("touch", bobber.catch)
  bobber.anim:addEventListener("catchEvent", scene.reelIn)
  bobber.anim:addEventListener("tutorialEvent", showCatchModal)
  baitButton.anim:addEventListener("pauseEvent", pauseGame)
end

-- Pause the fish spawning and fish movement
function pauseGame()
  modalIsShowing = true
  bobber.setCast()
end

-- Custom function for resuming the game (from pause state)
function scene:resumeGame(tutorial, final)
  -- Code to resume game
  -- If tutorial
  if (tutorial) then
    if (preCast == false) then
      timer.performWithDelay(500, function()
        pauseGame()
        composer.showOverlay("scenes.tutorialModal", {params = {text = 
        [[To cast, press and drag the bobber towards the direction you wish to cast. The more red the power meter, the further the bobber will go.
Hit next to try and cast!]]}, effect="fade", time=800, isModal=true})
        preCast = true
      end)
    elseif (preCatch == false) then
--     elseif (postCatch == false) then
--       composer.showOverlay("scenes.tutorialModal", {params = {text = 
--       [[Here is where you do all the fishing. You can hit the back button to go back to the title and hit the bait button to view, use, and buy baits.
-- Hit next to learn how to fish.]]}, effect="fade", time=800, isModal=true})
--       postCatch = true
    end
  else
    if (spawnedInitialFish == false) and (db:getRows("Flags")[1].watchedTutorial == 1) then
      for i=1,3 do
        addFish()
      end
      spawnedInitialFish = true
    end
  end
  -- If leaving bait modal
  modalIsShowing = false
  bobber.setCast()
  if (final) and (db:getRows("Flags")[1].watchedTutorial == 0) then
    pauseGame()
    composer.showOverlay("scenes.tutorialModal", {params = {text = 
    [[Congratulations! You completed the tutorial! Now go out there and try to catch every fish!!]], finishButton=true}, effect="fade", time=800, isModal=true})
  end
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  local the_fish = nil
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

    local locationName = event.params.location
    -- Code here runs when the scene is first created but has not yet appeared on screen
    background = display.newImage(backgroundGroup, "images/backgrounds/bg_sand.png")
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    water = display.newImage(backgroundGroup, "images/backgrounds/bg_" .. locationName .. ".png")
    water.x = display.contentCenterX
    water.y = display.contentCenterY - 550

    bobber:caught()
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
    if (tutorial) and (db:getRows("Flags")[1].watchedTutorial == 0) then
      pauseGame()
      composer.showOverlay("scenes.tutorialModal", {params = {text = 
      [[Here is where you do all the fishing. You can hit the back button to go back to the title and hit the chum button to view, use, and buy chums.
Hit next to learn how to fish.]]}, effect="fade", time=800, isModal=true})
    end

    location = newLocation(event.params.location)

    -- TODO: CHECK IF THIS WOKRS AND MODIFY SO PEOPLE DONT HACK
    if (spawnedInitialFish == false) and (db:getRows("Flags")[1].watchedTutorial == 1) then
      for i=1,3 do
        addFish()
      end
      spawnedInitialFish = true
    end

    -- Timer to spawn fish throughout
    -- TODO: Finalize time
    fishUpdateTimer = timer.performWithDelay(7000, function()
      self:updateFish()
    end, 0)
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
    bobber:noCast()
    timer.cancel(fishUpdateTimer)
    -- Destroy the fish image objects and remove fish from table
    function removeFish(index)
      if (fishTable[index]) then
        fishTable[index]:destroy()
        table.remove(fishTable, index)
      else
        print('This is an error. We should fix this')
      end
    end

    for i = #fishTable, 1, -1 do
      removeFish(i)
    end

    spawnedInitialFish = false

    bobber.bringBack()
  end
end

-- destroy()
function scene:destroy( event )

  local sceneGroup = self.view
  local phase = event.phase
  
  if ( phase == "will" ) then
    -- Code here runs prior to the removal of scene's view
  elseif ( phase == "did" ) then
    -- Code here runs after scene is removed
  end
end

function scene:updateFish()
  if (modalIsShowing == false) and (db:getRows("Flags")[1].watchedTutorial == 1) then
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
    local SPAWN_CHANCE = 0.25;
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

-- Function to show how to catch modal
function showCatchModal(event)
  pauseGame()
  composer.showOverlay("scenes.tutorialModal", {params = {text = 
  [[Congratulations! You just cast the bobber. Now, wait for a blue splash, vibration, and/or sound effect. Then tap the screen to reel in your fish!
Hit next to try to catch a fish!]]}, effect="fade", time=800, isModal=true})
  bobber.bringBack()
  bobber.setCast()
  for i=1,3 do
    addFish()
  end
  spawnedInitialFish = true
end

-- Checks if any fish were caught when the bobber was reeling in
function scene:reelIn()


  -- Destroy the fish image objects and remove fish from table
  function removeFish(index)
    if (fishTable[index]) then
      fishTable[index]:destroy()
      table.remove(fishTable, index)
    else
      print('This is an error. We should fix this')
    end
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
        -- db:caughtFish(fid)
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
