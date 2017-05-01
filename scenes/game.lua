-- Game Scene
-- Fish appear and the player can cast the rod and try to catch them

-- Require imports
local composer = require("composer")
local cast = require("classes.cast")
local newFish = require("classes.fish").create
local physics = require("physics")

-- Start the physics with no gravity
physics.start()
physics.setGravity(0, 0)

-- This scene
local scene = composer.newScene()
local background = nil
local water = nil
-- Bobber image
bobber = nil

fishTable = {}

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    background = display.newImage("images/backgrounds/bg_sand.png")
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    water = display.newImage("images/backgrounds/bg_water.png")
    water.x = display.contentCenterX
    water.y = display.contentCenterY - 550

    -- Create the bobber
    bobber = display.newCircle( display.contentCenterX, display.contentCenterY + 500, 25 )
    bobber:addEventListener( "touch", cast.doSwipe )
    physics.addBody(bobber, "dynamic")
    bobber.linearDamping = 1
    
    -- Create a fish
    for i=1,3 do
        local f = newFish(display.contentWidth - 100, display.contentHeight - 300, 100, display.contentCenterY - 400)
        table.insert(fishTable, f)
    end
    Runtime:addEventListener( "touch", cast.catch)

    -- Boolean to let bobber be cast
    bobber.canBeSwiped = true
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
        -- Add listener on bobber
        -- Spawn initial fish
        -- for i=1,3 do
        -- end
        -- Timer to spawn fish throughout
        -- TODO: Finalize time
        self.fishLoopTimer = timer.performWithDelay(4000, function()
            self:updateFish()
        end, 0 )
    end
end

-- hide()
function scene:hide( event )
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
        print("Fish " ..  i .. ": " .. fishTable[i].tostring())
        timer.performWithDelay(300, fishTable[i].update(), 0)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene