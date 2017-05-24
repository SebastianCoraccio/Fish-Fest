-- Game Scene
-- Fish appear and the player can cast the rod and try to catch them

-- Require imports
local composer = require("composer")
local newFish = require("classes.fish").create
local newBobber = require("classes.bobber").create
local physics = require("physics")
local newModal = require("classes.modal").create
local newLocation = require("classes.location").create

-- Load the DB
-- local sqlite3 = require("sqlite3")
-- local path = system.pathForFile("database.db", system.DocumentsDirectory)
-- local db = sqlite3.open(path)

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

-- Location
-- TODO: Need to get users pick for location. Passed from composer scene
local location = newLocation('river')

-- Table to hold the fish
fishTable = {}

-- Add a new fish
function addFish()
    local fishToAdd = location.giveFish()
    local f = newFish({maxX=display.contentWidth, 
                        maxY=display.contentHeight - 150, 
                        minX=0, 
                        minY=-100,
                        fid=fishToAdd.fid})
    table.insert(fishTable, f)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    background = display.newImage("images/backgrounds/bg_sand.png")
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    water = display.newImage("images/backgrounds/bg_water.png")
    water.x = display.contentCenterX
    water.y = display.contentCenterY - 550

    -- Create the bobber
    bobber = newBobber(display.contentCenterX, display.contentCenterY + 500)

    -- Create the fish
    for i=1,3 do
        addFish()
    end

    -- Add catch event and related listeners
    Runtime:addEventListener("touch", bobber.catch)
    bobber.anim:addEventListener("catchEvent", scene.reelIn)
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
        self.fishUpdateTimer = timer.performWithDelay(3000, function()
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
    for i = #fishTable, 1, -1 do
        fishTable[i].update()
    end
    
    -- Check if adding a fish is needed, and try to do so it yes 
    -- TODO: Create an attributes table for each of the locations
    local MAX_FISH = 5
    local SPAWN_CHANCE = .25

    if #fishTable < MAX_FISH then
        if math.random() < SPAWN_CHANCE then
            addFish()
        end
    end
end

-- Checks if any fish were caught when the bobber was reeling in
function scene:reelIn()
    for i = #fishTable, 1, -1 do
        local caught = fishTable[i].checkCaught()
        if caught == 2 then
            timer.performWithDelay(250, function()
                -- Show modal
                newModal(fishTable[i].fid) 
                
                -- Remove fish from table
                table.remove(fishTable, i)
            end)
        elseif caught == 1 then
            timer.performWithDelay(250, function()
                print("Missed the fish, sucker.")
                -- Remove fish from table
                table.remove(fishTable, i)
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